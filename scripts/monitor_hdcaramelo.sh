#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/ODOOVER18_PROYECTO_HDCARAMELO"
BACKUP_STATE_FILE="$BASE_DIR/vol_backup_postgresql_hdcaramelo/state/last_success.txt"
BACKUP_LOG_FILE="$BASE_DIR/vol_backup_postgresql_hdcaramelo/logs/backup.log"
MAX_BACKUP_AGE_HOURS=30

containers=(
  postgresqlhdcaramelover18
  odoohdcaramelover18
  odoohdcaramelo_uat_ver18
  odoohdcaramelo_staging_ver18
  backuphdcaramelover18
)

echo "[INFO] $(date '+%F %T %Z') - Verificacion HDCARAMELO"

for c in "${containers[@]}"; do
  status=$(docker inspect -f '{{.State.Status}}' "$c" 2>/dev/null || echo "missing")
  if [[ "$status" != "running" ]]; then
    echo "[CRIT] Contenedor $c en estado: $status"
  else
    echo "[OK] Contenedor $c running"
  fi
done

http_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 12 http://127.0.0.1:8006/web/login || echo 000)
if [[ "$http_code" != "200" ]]; then
  echo "[CRIT] Produccion no responde OK en 8006 (HTTP $http_code)"
else
  echo "[OK] Produccion responde HTTP 200 en 8006"
fi

if [[ -f "$BACKUP_STATE_FILE" ]]; then
  ts=$(sed -n 's/^last_success=//p' "$BACKUP_STATE_FILE" | tail -n1)
  if [[ -n "$ts" ]]; then
    now_epoch=$(date +%s)
    last_epoch=$(date -d "$ts" +%s 2>/dev/null || echo 0)
    if [[ "$last_epoch" -gt 0 ]]; then
      age_h=$(( (now_epoch - last_epoch) / 3600 ))
      if [[ "$age_h" -gt "$MAX_BACKUP_AGE_HOURS" ]]; then
        echo "[CRIT] Backup antiguo: ${age_h}h (max ${MAX_BACKUP_AGE_HOURS}h)"
      else
        echo "[OK] Backup vigente: ${age_h}h"
      fi
    else
      echo "[WARN] No se pudo parsear last_success"
    fi
  else
    echo "[WARN] last_success vacio"
  fi
else
  echo "[CRIT] No existe $BACKUP_STATE_FILE"
fi

if [[ -f "$BACKUP_LOG_FILE" ]]; then
  last_err=$(tail -n 200 "$BACKUP_LOG_FILE" | rg -n "ERROR" -m1 || true)
  if [[ -n "$last_err" ]]; then
    echo "[WARN] Ultimo ERROR en backup.log:"
    echo "$last_err"
  else
    echo "[OK] Sin errores recientes en backup.log"
  fi
fi

du -sh "$BASE_DIR/vol_backup_postgresql_hdcaramelo" 2>/dev/null | sed 's/^/[INFO] Uso backup: /'
