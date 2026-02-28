# Entorno Activo: PRODUCCION

- Rama: `PRODUCCION`
- Base de datos objetivo: `carameloycolitascubanas.com.co`
- URL esperada: `http://153.92.214.189:8006`
- Exposicion: publica (detras de proxy/NPM recomendado)
- Odoo config: `odoo/config_secure/odoo_prod.conf`

## Checklist rapido
1. `docker logs --tail 120 odoohdcaramelover18`
2. `curl -I http://127.0.0.1:8006/web/login`
3. Validar backup en `vol_backup_postgresql_hdcaramelo/sql`
