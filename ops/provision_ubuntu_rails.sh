#!/usr/bin/env bash
set -euo pipefail

# Idempotent Ubuntu provisioning for Al Toupi Rails app.

APP_NAME="${APP_NAME:-altoupi}"
APP_USER="${APP_USER:-deploy}"
APP_GROUP="${APP_GROUP:-$APP_USER}"
APP_DIR="${APP_DIR:-/var/www/$APP_NAME}"
REPO_URL="${REPO_URL:-}"
RUBY_VERSION="${RUBY_VERSION:-3.4.2}"
NODE_MAJOR="${NODE_MAJOR:-20}"
DB_NAME="${DB_NAME:-altoupi_production}"
DB_CACHE_NAME="${DB_CACHE_NAME:-altoupi_production_cache}"
DB_QUEUE_NAME="${DB_QUEUE_NAME:-altoupi_production_queue}"
DB_CABLE_NAME="${DB_CABLE_NAME:-altoupi_production_cable}"
DB_USER="${DB_USER:-altoupi}"
DB_PASSWORD="${DB_PASSWORD:-change_me_now}"
SERVER_NAME="${SERVER_NAME:-example.com}"
LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-admin@example.com}"

if [[ -z "$REPO_URL" ]]; then
  echo "ERROR: REPO_URL is required."
  echo "Example: REPO_URL=git@github.com:org/altoupi.git sudo -E bash ops/provision_ubuntu_rails.sh"
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: run as root (sudo)."
  exit 1
fi

echo "==> Updating apt"
apt-get update -y

echo "==> Installing base packages"
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl gnupg2 ca-certificates lsb-release software-properties-common \
  build-essential git libssl-dev zlib1g-dev libreadline-dev libyaml-dev \
  libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libffi-dev libgdbm-dev \
  libncurses5-dev libpq-dev postgresql postgresql-contrib nginx certbot \
  python3-certbot-nginx imagemagick libvips chromium-driver

echo "==> Installing Node.js ${NODE_MAJOR}"
if ! command -v node >/dev/null 2>&1 || [[ "$(node -v | cut -d. -f1 | tr -d 'v')" != "$NODE_MAJOR" ]]; then
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
  DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
fi

echo "==> Enabling Corepack (Yarn)"
corepack enable || true
corepack prepare yarn@stable --activate || true

echo "==> Installing rbenv + ruby-build"
if [[ ! -d "/opt/rbenv" ]]; then
  git clone https://github.com/rbenv/rbenv.git /opt/rbenv
fi
if [[ ! -d "/opt/rbenv/plugins/ruby-build" ]]; then
  git clone https://github.com/rbenv/ruby-build.git /opt/rbenv/plugins/ruby-build
fi

cat >/etc/profile.d/rbenv.sh <<'RBENV'
export RBENV_ROOT="/opt/rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init - bash)"
RBENV

export RBENV_ROOT="/opt/rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init - bash)"

if ! rbenv versions --bare | grep -qx "$RUBY_VERSION"; then
  rbenv install "$RUBY_VERSION"
fi
rbenv global "$RUBY_VERSION"
gem update --system
gem install bundler --no-document
rbenv rehash

echo "==> Creating application user/group"
if ! getent group "$APP_GROUP" >/dev/null 2>&1; then
  groupadd --system "$APP_GROUP"
fi
if ! id "$APP_USER" >/dev/null 2>&1; then
  useradd --system --create-home --home-dir "/home/$APP_USER" --gid "$APP_GROUP" --shell /bin/bash "$APP_USER"
fi

echo "==> Creating app directories"
mkdir -p "$APP_DIR"/{releases,shared/{config,log,tmp/{pids,sockets,cache},storage}}
chown -R "$APP_USER:$APP_GROUP" "$APP_DIR"

echo "==> Configuring PostgreSQL role and databases"
sudo -u postgres psql <<SQL
DO
\$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN
      CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}';
   ELSE
      ALTER ROLE ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
   END IF;
END
\$\$;
SQL

for db in "$DB_NAME" "$DB_CACHE_NAME" "$DB_QUEUE_NAME" "$DB_CABLE_NAME"; do
  sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '$db'" | grep -q 1 || \
    sudo -u postgres createdb -O "$DB_USER" "$db"
done

echo "==> Cloning repository"
if [[ ! -d "$APP_DIR/repo/.git" ]]; then
  sudo -u "$APP_USER" git clone "$REPO_URL" "$APP_DIR/repo"
else
  sudo -u "$APP_USER" git -C "$APP_DIR/repo" fetch --all --prune
fi

echo "==> Writing default env file"
if [[ ! -f "$APP_DIR/shared/config/.env.production" ]]; then
  cat >"$APP_DIR/shared/config/.env.production" <<ENVFILE
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
APP_HOST=${SERVER_NAME}
FORCE_SSL=true
ASSUME_SSL=true
ALTOUPI_DATABASE_PASSWORD=${DB_PASSWORD}
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@127.0.0.1:5432/${DB_NAME}
ENVFILE
  chmod 640 "$APP_DIR/shared/config/.env.production"
  chown "$APP_USER:$APP_GROUP" "$APP_DIR/shared/config/.env.production"
fi

echo "==> Installing Ruby dependencies in repo"
sudo -u "$APP_USER" bash -lc "source /etc/profile.d/rbenv.sh && cd '$APP_DIR/repo' && bundle config set path vendor/bundle && bundle install"

echo "==> Nginx baseline config"
cat >/etc/nginx/sites-available/${APP_NAME}.conf <<NGINXCONF
server {
  listen 80;
  listen [::]:80;
  server_name ${SERVER_NAME};

  root ${APP_DIR}/current/public;
  client_max_body_size 20m;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_redirect off;
    proxy_pass http://unix:${APP_DIR}/shared/tmp/sockets/puma.sock;
  }

  location /assets {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location /packs {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location = /up {
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://unix:${APP_DIR}/shared/tmp/sockets/puma.sock;
  }
}
NGINXCONF

ln -sf /etc/nginx/sites-available/${APP_NAME}.conf /etc/nginx/sites-enabled/${APP_NAME}.conf
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
systemctl enable nginx

echo "==> Creating systemd service"
cat >/etc/systemd/system/puma-${APP_NAME}.service <<SYSTEMD
[Unit]
Description=Puma HTTP Server for ${APP_NAME}
After=network.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${APP_DIR}/current
Environment=HOME=/home/${APP_USER}
EnvironmentFile=${APP_DIR}/shared/config/.env.production
ExecStart=/bin/bash -lc 'source /etc/profile.d/rbenv.sh && bundle exec puma -e production --bind unix://${APP_DIR}/shared/tmp/sockets/puma.sock --pidfile ${APP_DIR}/shared/tmp/pids/puma.pid'
ExecReload=/bin/kill -USR1 \$MAINPID
Restart=always
RestartSec=5
StandardOutput=append:${APP_DIR}/shared/log/puma.stdout.log
StandardError=append:${APP_DIR}/shared/log/puma.stderr.log

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable puma-${APP_NAME}

echo "==> Certbot setup"
if [[ "$SERVER_NAME" != "example.com" && "$LETSENCRYPT_EMAIL" != "admin@example.com" ]]; then
  certbot --nginx -d "$SERVER_NAME" --non-interactive --agree-tos -m "$LETSENCRYPT_EMAIL" --redirect || true
fi

echo "Provisioning finished."
echo "Next: run deployment script to create current release and start Puma."
