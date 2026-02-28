#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="/backup/output"
SQL_DIR="$BACKUP_ROOT/sql"
LOG_DIR="$BACKUP_ROOT/logs"
STATE_DIR="$BACKUP_ROOT/state"
LOG_FILE="$LOG_DIR/backup.log"
TMP_DIR=""
umask 022

mkdir -p "$LOG_DIR" "$STATE_DIR" "$SQL_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$1" | tee -a "$LOG_FILE"
}

cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

DB_LIST=${DB_LIST:-""}
if [[ -z "$DB_LIST" ]]; then
  DB_LIST=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -tAc \
    "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname")
fi
TMP_DIR=$(mktemp -d "$BACKUP_ROOT/.tmp_backup_XXXXXX")

log "Inicio backup diario. DB_LIST=[$DB_LIST]"

for db in $DB_LIST; do
  exists=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${db}'" || true)
  if [[ "$exists" != "1" ]]; then
    log "Base no existe, se omite: $db"
    continue
  fi

  out_file="$TMP_DIR/${db}_$(date '+%Y-%m-%d_%H-%M').sql"
  log "Dump de $db -> $(basename "$out_file")"

  if ! pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db" --clean --if-exists --no-owner --no-acl > "$out_file"; then
    log "ERROR: fallo backup en $db. Se conserva backup anterior."
    exit 1
  fi
done

if ! ls "$TMP_DIR"/*.sql >/dev/null 2>&1; then
  log "ERROR: no se generaron archivos SQL. Se conserva backup anterior."
  exit 1
fi

globals_file="$TMP_DIR/postgresql_globals_$(date '+%Y-%m-%d_%H-%M').sql"
if ! pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" --globals-only > "$globals_file"; then
  log "ERROR: fallo backup de roles/globales. Se conserva backup anterior."
  exit 1
fi
log "Dump de globales -> $(basename "$globals_file")"

if [[ -d "$SQL_DIR" ]]; then
  rm -rf "$SQL_DIR.prev"
  mv "$SQL_DIR" "$SQL_DIR.prev"
fi

mv "$TMP_DIR" "$SQL_DIR"
TMP_DIR=""
rm -rf "$SQL_DIR.prev"

rm -rf "$BACKUP_ROOT/latest"
cp -a "$SQL_DIR" "$BACKUP_ROOT/latest"
chmod -R a+rX "$BACKUP_ROOT/latest" "$SQL_DIR" "$LOG_DIR" "$STATE_DIR"

echo "last_success=$(date '+%Y-%m-%d %H:%M:%S %Z')" > "$STATE_DIR/last_success.txt"
log "Backup finalizado OK. Solo queda la ultima version valida en $SQL_DIR"
