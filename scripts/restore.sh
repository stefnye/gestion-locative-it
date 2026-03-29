#!/usr/bin/env bash
set -euo pipefail

# Restore Docker volumes from a backup archive
# Usage: ./scripts/restore.sh /path/to/backup.tar.gz

BACKUP_FILE="${1:?Usage: restore.sh /path/to/backup.tar.gz}"
COMPOSE_PROJECT="gestion-locative-it"

VOLUMES=(
  "postgres_data"
  "redis_data"
  "firefly_upload"
  "paperless_data"
  "paperless_media"
  "nocodb_data"
  "vikunja_data"
)

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

if [[ ! -f "${BACKUP_FILE}" ]]; then
  log "ERROR: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

log "Restoring from: ${BACKUP_FILE}"

# Stop services
log "Stopping services..."
docker compose -p "${COMPOSE_PROJECT}" stop

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

log "Extracting archive..."
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

for vol in "${VOLUMES[@]}"; do
  full_vol="${COMPOSE_PROJECT}_${vol}"
  vol_archive="${TEMP_DIR}/${vol}.tar.gz"

  if [[ ! -f "${vol_archive}" ]]; then
    log "WARNING: Volume archive not found, skipping: ${vol}"
    continue
  fi

  log "Restoring volume: ${full_vol}"
  docker run --rm \
    -v "${full_vol}:/data" \
    -v "${TEMP_DIR}:/backup:ro" \
    alpine sh -c "rm -rf /data/* && tar xzf /backup/${vol}.tar.gz -C /data"
done

# Restart services
log "Restarting services..."
docker compose -p "${COMPOSE_PROJECT}" start

log "Restore complete."
