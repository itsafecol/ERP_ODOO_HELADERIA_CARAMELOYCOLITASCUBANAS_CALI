# README Operacion - HDCARAMELO

## Objetivo
Operacion segura de la instancia `ODOOVER18_PROYECTO_HDCARAMELO` con ambientes PRODUCCION, UAT y STAGING.

## Servicios
- `postgresqlhdcaramelover18`
- `odoohdcaramelover18` (PROD: `8006`)
- `odoohdcaramelo_uat_ver18` (UAT local: `127.0.0.1:8016`)
- `odoohdcaramelo_staging_ver18` (STAGING local: `127.0.0.1:18006`)
- `pgadminhdcaramelover18` (local: `127.0.0.1:5002`)
- `backuphdcaramelover18`

## Checklist Diario
1. Validar servicios arriba:
   - `docker ps | rg hdcaramelo`
2. Validar backup del dia:
   - `ls -la vol_backup_postgresql_hdcaramelo/sql`
3. Revisar errores de backup:
   - `tail -n 80 vol_backup_postgresql_hdcaramelo/logs/backup.log`
4. Validar acceso PROD por dominio/puerto productivo.

## Checklist Semanal
1. Probar restauracion en ambiente UAT (no en PROD).
2. Revisar tamano de backups y espacio en disco.
3. Rotar/revisar llaves y credenciales de acceso administrativo.
4. Validar actualizaciones de seguridad de host y contenedores.

## Comandos de Operacion
- Levantar stack:
  - `docker compose up -d`
- Reiniciar un servicio:
  - `docker compose restart odoo_prod`
- Ver logs de Odoo PROD:
  - `docker logs --tail 200 odoohdcaramelover18`
- Ejecutar backup inmediato:
  - `docker exec backuphdcaramelover18 /bin/bash /backup/scripts/backup_all.sh`

## Operacion por archivo (recomendado por ambiente)
- Produccion:
  - `docker compose -f docker-compose.prod.yml up -d`
  - `docker compose -f docker-compose.prod.yml down`
- UAT:
  - `docker compose -f docker-compose.uat.yml up -d`
  - `docker compose -f docker-compose.uat.yml down`
- STAGING:
  - `docker compose -f docker-compose.staging.yml up -d`
  - `docker compose -f docker-compose.staging.yml down`

Nota: no ejecutes simultaneamente estos archivos separados si comparten los mismos `container_name`. Para operacion simultanea de los tres ambientes, usa `docker-compose.yml` (archivo completo).

## Politica de Cambios
- Desarrollo nuevo -> STAGING
- Validacion funcional -> UAT
- Aprobado -> PRODUCCION

## Politica de Seguridad
- `list_db=False` y `dbfilter` por ambiente.
- UAT/STAGING/pgAdmin solo localhost.
- Publicar solo PRODUCCION detras de proxy seguro (NPM + Cloudflare recomendado).
