#!/usr/bin/env bash
set -euo pipefail

mkdir -p /backup/output/logs /backup/output/state
LOG_FILE="/backup/output/logs/backup.log"
LAST_ATTEMPT_FILE="/backup/output/state/last_attempt_date.txt"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$1" | tee -a "$LOG_FILE"
}

log "Scheduler de backup iniciado. Ejecuta a las 02:00 diariamente."

while true; do
  now_hm_num=$(date '+%H%M')
  today=$(date '+%F')
  last_attempt=$(cat "$LAST_ATTEMPT_FILE" 2>/dev/null || true)

  if [[ "$now_hm_num" -ge 200 && "$now_hm_num" -lt 205 && "$last_attempt" != "$today" ]]; then
    echo "$today" > "$LAST_ATTEMPT_FILE"
    if ! /bin/bash /backup/scripts/backup_all.sh; then
      log "ERROR: backup diario fallo. Se conserva backup previo."
    fi
  fi

  if [[ "$now_hm_num" -ge 205 && "$last_attempt" != "$today" ]]; then
    log "Ejecucion de recuperacion diaria (servicio reiniciado o ventana 02:00 perdida)."
    echo "$today" > "$LAST_ATTEMPT_FILE"
    if ! /bin/bash /backup/scripts/backup_all.sh; then
      log "ERROR: backup de recuperacion fallo. Se conserva backup previo."
    fi
  fi

  sleep 30
done
