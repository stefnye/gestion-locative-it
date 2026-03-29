#!/usr/bin/env bash
set -euo pipefail

# Backup all Docker volumes for gestion-locative stack
# Usage: ./scripts/backup.sh [destination_dir]

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${1:-/opt/backups/gestion-locative}"
BACKUP_FILE="${BACKUP_DIR}/gestion-locative_${TIMESTAMP}.tar.gz"
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

log "Starting backup to ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# Stop services to ensure data consistency
log "Stopping services..."
docker compose -p "${COMPOSE_PROJECT}" stop

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

for vol in "${VOLUMES[@]}"; do
  full_vol="${COMPOSE_PROJECT}_${vol}"
  log "Backing up volume: ${full_vol}"
  docker run --rm \
    -v "${full_vol}:/data:ro" \
    -v "${TEMP_DIR}:/backup" \
    alpine tar czf "/backup/${vol}.tar.gz" -C /data .
done

log "Creating archive: ${BACKUP_FILE}"
tar czf "${BACKUP_FILE}" -C "${TEMP_DIR}" .

# Restart services
log "Restarting services..."
docker compose -p "${COMPOSE_PROJECT}" start

log "Backup complete: ${BACKUP_FILE}"
log "Size: $(du -h "${BACKUP_FILE}" | cut -f1)"
