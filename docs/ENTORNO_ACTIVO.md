# Entorno Activo: UAT

- Rama: `UAT`
- Base de datos objetivo: `HDCARAMELO_UAT`
- URL esperada: `http://127.0.0.1:8016`
- Exposicion: solo local/tunel
- Odoo config: `odoo/config_secure/odoo_uat.conf`

## Checklist rapido
1. `docker logs --tail 120 odoohdcaramelo_uat_ver18`
2. `curl -I http://127.0.0.1:8016/web/login`
3. Validacion de negocio/aprobacion antes de PRODUCCION
