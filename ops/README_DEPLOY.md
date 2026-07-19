# Deployment Guide (Ubuntu + Nginx + Puma)

This folder contains production deployment automation for a VM/server accessible through SSH with sudo.

## Files

- `ops/provision_ubuntu_rails.sh`: full server provisioning (Ruby, Node, Yarn, PostgreSQL, Nginx, Certbot, app user, permissions).
- `ops/nginx/altoupi.conf`: Nginx virtual host template.
- `ops/systemd/puma-altoupi.service`: Puma systemd service template.
- `ops/deploy_altoupi.sh`: full app deployment script.
- `ops/run_quality_checks.sh`: RSpec + RuboCop + Brakeman + Bundler Audit.
- `ops/backup_prod_data.sh`: production backup (PostgreSQL dumps + shared storage/config).

## Zero-loss deployment checklist

Before every production deploy, always take a backup from the server.

### A) Backup data/files on the server (run as your sudo user)

```bash
cd /var/www/altoupi/repo
sudo -E bash ops/backup_prod_data.sh
```

This backup includes:
- PostgreSQL dumps for `altoupi_production`, `altoupi_production_cache`, `altoupi_production_queue`, `altoupi_production_cable`
- Uploaded files from `/var/www/altoupi/shared/storage`
- App shared config from `/var/www/altoupi/shared/config`

Optional: download backup locally

```bash
scp -r deploy@YOUR_SERVER_IP:/var/www/altoupi/backups/<TIMESTAMP> ./prod-backup-<TIMESTAMP>
```

### B) Push code changes

From local machine:

```bash
git add .
git commit -m "Your deploy message"
git push origin main
```

### C) Deploy safely on server

```bash
cd /var/www/altoupi/repo
sudo -E APP_NAME=altoupi \
APP_DIR=/var/www/altoupi \
BRANCH=main \
SYNC_ADMIN_PASSWORD=false \
bash ops/deploy_altoupi.sh
```

`SYNC_ADMIN_PASSWORD=false` avoids resetting the admin password unexpectedly.

## 1) Provision the server (run as root)

```bash
sudo -E APP_NAME=altoupi \
  APP_USER=deploy \
  APP_DIR=/var/www/altoupi \
  REPO_URL=git@github.com:YOUR_ORG/YOUR_REPO.git \
  SERVER_NAME=altoupi.fr \
  LETSENCRYPT_EMAIL=contact@altoupi.fr \
  DB_USER=altoupi \
  DB_PASSWORD='CHANGE_ME_STRONG_PASSWORD' \
  bash ops/provision_ubuntu_rails.sh
```

The script creates these PostgreSQL DBs used by current `config/database.yml`:
- `altoupi_production`
- `altoupi_production_cache`
- `altoupi_production_queue`
- `altoupi_production_cable`

## 2) Add secrets on server

Copy your Rails master key:

```bash
sudo mkdir -p /var/www/altoupi/shared/config
sudo nano /var/www/altoupi/shared/config/master.key
sudo chown deploy:deploy /var/www/altoupi/shared/config/master.key
sudo chmod 600 /var/www/altoupi/shared/config/master.key
```

Edit env file:

```bash
sudo nano /var/www/altoupi/shared/config/.env.production
sudo chown deploy:deploy /var/www/altoupi/shared/config/.env.production
sudo chmod 640 /var/www/altoupi/shared/config/.env.production
```

## 3) Install Nginx and systemd templates

```bash
sudo cp ops/nginx/altoupi.conf /etc/nginx/sites-available/altoupi.conf
sudo ln -sfn /etc/nginx/sites-available/altoupi.conf /etc/nginx/sites-enabled/altoupi.conf
sudo nginx -t && sudo systemctl reload nginx

sudo cp ops/systemd/puma-altoupi.service /etc/systemd/system/puma-altoupi.service
sudo systemctl daemon-reload
sudo systemctl enable puma-altoupi
```

## 4) Deploy app (run as your sudo user)

```bash
sudo -E APP_NAME=altoupi \
APP_DIR=/var/www/altoupi \
BRANCH=main \
SYNC_ADMIN_PASSWORD=true \
ADMIN_EMAIL=admin@altoupi.fr \
ADMIN_PASSWORD='Altoupb1226' \
bash ops/deploy_altoupi.sh
```

## 5) Run quality/security checks

```bash
bash ops/run_quality_checks.sh
```

## Recommended verification

```bash
systemctl status puma-altoupi --no-pager
systemctl status nginx --no-pager
curl -I https://altoupi.fr/up
```
