#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-altoupi}"
APP_DIR="${APP_DIR:-/var/www/$APP_NAME}"
REPO_DIR="${REPO_DIR:-$APP_DIR/repo}"
RELEASES_DIR="${RELEASES_DIR:-$APP_DIR/releases}"
SHARED_DIR="${SHARED_DIR:-$APP_DIR/shared}"
CURRENT_LINK="${CURRENT_LINK:-$APP_DIR/current}"
BRANCH="${BRANCH:-main}"
KEEP_RELEASES="${KEEP_RELEASES:-5}"
RUN_CHECKS="${RUN_CHECKS:-false}"
SYNC_ADMIN_PASSWORD="${SYNC_ADMIN_PASSWORD:-true}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@altoupi.fr}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Altoupb1226}"

if [[ "$EUID" -eq 0 ]]; then
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    echo "INFO: script started as root via sudo, switching to ${SUDO_USER}."
    exec sudo -iu "$SUDO_USER" \
      APP_NAME="$APP_NAME" \
      APP_DIR="$APP_DIR" \
      REPO_DIR="$REPO_DIR" \
      RELEASES_DIR="$RELEASES_DIR" \
      SHARED_DIR="$SHARED_DIR" \
      CURRENT_LINK="$CURRENT_LINK" \
      BRANCH="$BRANCH" \
      KEEP_RELEASES="$KEEP_RELEASES" \
      RUN_CHECKS="$RUN_CHECKS" \
      SYNC_ADMIN_PASSWORD="$SYNC_ADMIN_PASSWORD" \
      ADMIN_EMAIL="$ADMIN_EMAIL" \
      ADMIN_PASSWORD="$ADMIN_PASSWORD" \
      bash "$0"
  fi

  echo "ERROR: do not run as root directly. Run as a sudo-enabled user."
  exit 1
fi

timestamp="$(date +%Y%m%d%H%M%S)"
release_path="$RELEASES_DIR/$timestamp"

mkdir -p "$RELEASES_DIR" "$SHARED_DIR/config" "$SHARED_DIR/log" "$SHARED_DIR/tmp/pids" "$SHARED_DIR/tmp/sockets" "$SHARED_DIR/storage"

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "ERROR: missing git repo at $REPO_DIR"
  exit 1
fi

echo "==> Fetch latest code"
git -C "$REPO_DIR" fetch origin
git -C "$REPO_DIR" checkout "$BRANCH"
git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"

echo "==> Create new release"
mkdir -p "$release_path"
git -C "$REPO_DIR" archive "$BRANCH" | tar -x -C "$release_path"

echo "==> Link shared files"
ln -sfn "$SHARED_DIR/storage" "$release_path/storage"
ln -sfn "$SHARED_DIR/log" "$release_path/log"

if [[ -f "$SHARED_DIR/config/master.key" ]]; then
  ln -sfn "$SHARED_DIR/config/master.key" "$release_path/config/master.key"
else
  echo "WARNING: $SHARED_DIR/config/master.key missing."
fi

if [[ -f "$SHARED_DIR/config/.env.production" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$SHARED_DIR/config/.env.production"
  set +a
else
  echo "WARNING: $SHARED_DIR/config/.env.production missing."
fi

echo "==> Bundle install"
source /etc/profile.d/rbenv.sh
cd "$release_path"
bundle config set deployment true
bundle config set without "development:test"
bundle config set path "$SHARED_DIR/bundle"
bundle install --jobs 4 --retry 3

echo "==> Assets precompile"
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

echo "==> Database prepare"
RAILS_ENV=production bundle exec rails db:prepare

if [[ "$SYNC_ADMIN_PASSWORD" == "true" ]]; then
  echo "==> Sync admin account password"
  RAILS_ENV=production ADMIN_EMAIL="$ADMIN_EMAIL" ADMIN_PASSWORD="$ADMIN_PASSWORD" bundle exec rails runner '
    email = ENV.fetch("ADMIN_EMAIL")
    pwd = ENV.fetch("ADMIN_PASSWORD")
    admin = AdminUser.find_or_initialize_by(email: email)
    admin.password = pwd
    admin.password_confirmation = pwd
    admin.save!
    puts "Admin synced: #{email}"
  '
fi

if [[ "$RUN_CHECKS" == "true" ]]; then
  echo "==> Run quality and security checks"
  RAILS_ENV=test bundle exec rspec
  bin/rubocop
  bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
  bin/bundler-audit check --update
fi

echo "==> Switch current symlink"
ln -sfn "$release_path" "$CURRENT_LINK"

echo "==> Restart Puma"
sudo systemctl restart puma-$APP_NAME
sudo systemctl status puma-$APP_NAME --no-pager

echo "==> Cleanup old releases"
ls -1dt "$RELEASES_DIR"/* | tail -n +$((KEEP_RELEASES + 1)) | xargs -r rm -rf

echo "Deploy finished at $(date -Iseconds)"
