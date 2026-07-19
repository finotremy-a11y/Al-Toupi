#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-altoupi}"
APP_DIR="${APP_DIR:-/var/www/$APP_NAME}"
SHARED_DIR="${SHARED_DIR:-$APP_DIR/shared}"
BACKUP_ROOT="${BACKUP_ROOT:-$APP_DIR/backups}"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-altoupi}"

DB_PRIMARY="${DB_PRIMARY:-altoupi_production}"
DB_CACHE="${DB_CACHE:-altoupi_production_cache}"
DB_QUEUE="${DB_QUEUE:-altoupi_production_queue}"
DB_CABLE="${DB_CABLE:-altoupi_production_cable}"

if [[ "$EUID" -eq 0 ]]; then
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    echo "INFO: script started as root via sudo, switching to ${SUDO_USER}."
    exec sudo -iu "$SUDO_USER" \
      APP_NAME="$APP_NAME" \
      APP_DIR="$APP_DIR" \
      SHARED_DIR="$SHARED_DIR" \
      BACKUP_ROOT="$BACKUP_ROOT" \
      DB_HOST="$DB_HOST" \
      DB_PORT="$DB_PORT" \
      DB_USER="$DB_USER" \
      DB_PRIMARY="$DB_PRIMARY" \
      DB_CACHE="$DB_CACHE" \
      DB_QUEUE="$DB_QUEUE" \
      DB_CABLE="$DB_CABLE" \
      bash "$0"
  fi

  echo "ERROR: do not run as root directly. Run as a sudo-enabled user."
  exit 1
fi

timestamp="$(date +%Y%m%d%H%M%S)"
backup_dir="$BACKUP_ROOT/$timestamp"

mkdir -p "$backup_dir"

if [[ -f "$SHARED_DIR/config/.env.production" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$SHARED_DIR/config/.env.production"
  set +a
fi

if [[ -z "${ALTOUPI_DATABASE_PASSWORD:-}" ]]; then
  echo "ERROR: ALTOUPI_DATABASE_PASSWORD is not set."
  echo "Check $SHARED_DIR/config/.env.production"
  exit 1
fi

echo "==> Backup directory: $backup_dir"

echo "==> Dump PostgreSQL databases"
export PGPASSWORD="$ALTOUPI_DATABASE_PASSWORD"
for db in "$DB_PRIMARY" "$DB_CACHE" "$DB_QUEUE" "$DB_CABLE"; do
  echo "   - $db"
  pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -Fc "$db" > "$backup_dir/${db}.dump"
done
unset PGPASSWORD

echo "==> Archive shared files (storage + config)"
tar -czf "$backup_dir/shared_storage.tar.gz" -C "$SHARED_DIR" storage
tar -czf "$backup_dir/shared_config.tar.gz" -C "$SHARED_DIR" config

echo "==> Write metadata"
cat > "$backup_dir/INFO.txt" <<INFO
Created at: $(date -Iseconds)
Host: $(hostname)
App: $APP_NAME
App dir: $APP_DIR
Databases:
  - $DB_PRIMARY
  - $DB_CACHE
  - $DB_QUEUE
  - $DB_CABLE
INFO

echo "==> SHA256 checksums"
sha256sum "$backup_dir"/* > "$backup_dir/SHA256SUMS.txt"

echo "Backup completed: $backup_dir"
ls -lh "$backup_dir"