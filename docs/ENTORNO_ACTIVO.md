# Entorno Activo: STAGING

- Rama: `STAGING`
- Base de datos objetivo: `HDCARAMELO_STAGING`
- URL esperada: `http://127.0.0.1:18006`
- Exposicion: solo local/tunel
- Odoo config: `odoo/config_secure/odoo_staging.conf`

## Checklist rapido
1. `docker logs --tail 120 odoohdcaramelo_staging_ver18`
2. `curl -I http://127.0.0.1:18006/web/login`
3. Ejecutar pruebas funcionales antes de promover a UAT
