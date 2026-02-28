# Monitoreo Activo - HDCARAMELO

## Ejecucion manual
```bash
cd /ODOOVER18_PROYECTO_HDCARAMELO
./scripts/monitor_hdcaramelo.sh
```

## Cron recomendado (cada 10 minutos)
```bash
*/10 * * * * /ODOOVER18_PROYECTO_HDCARAMELO/scripts/monitor_hdcaramelo.sh >> /ODOOVER18_PROYECTO_HDCARAMELO/logs/monitor_hdcaramelo.log 2>&1
```

## Alertas criticas a vigilar
- `CRIT Contenedor ...`
- `CRIT Produccion no responde OK en 8006`
- `CRIT Backup antiguo`
