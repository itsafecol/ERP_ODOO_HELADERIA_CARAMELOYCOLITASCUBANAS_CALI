# Hardening Cloudflare + NPM + Odoo (Produccion)

## Alcance
Guia segura para publicar solo PRODUCCION sin exponer UAT/STAGING ni servicios internos.

## 1) Reglas base de exposicion
- Publicar solo `odoohdcaramelover18` (puerto 8006) por dominio.
- Mantener `UAT`, `STAGING`, `pgAdmin` en localhost/tunel.
- PostgreSQL nunca publico.

## 2) Cloudflare (recomendado)
### SSL/TLS
- Mode: `Full (strict)`.
- Always Use HTTPS: `On`.
- Minimum TLS: `1.2` (ideal `1.3` habilitado).
- HSTS: habilitar progresivo (iniciar con max-age bajo y luego subir).

### WAF y Bot
- Managed WAF: `On`.
- Bot Fight Mode: `On` (evaluar impacto con usuarios legitimos).
- Rate limit (ejemplo inicial):
  - `/web/login`: 10 req/min por IP.
  - `/web/database/*`: bloquear (si `list_db=False`, igual mantener bloqueo).

### Cache
- Bypass cache para `/web/*`, `/websocket*`, `/longpolling/*`.

## 3) Nginx Proxy Manager (host de produccion)
Configurar proxy host del dominio productivo apuntando a `IP_VPS:8006`.

### Custom Nginx (Advanced)
Usar este bloque en NPM para headers y forwarding:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Real-IP $remote_addr;
proxy_read_timeout 720s;
proxy_connect_timeout 60s;
proxy_send_timeout 720s;

add_header X-Frame-Options SAMEORIGIN always;
add_header X-Content-Type-Options nosniff always;
add_header Referrer-Policy strict-origin-when-cross-origin always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

Notas:
- `proxy_mode=True` ya está habilitado en Odoo.
- Si usas websocket/evented, validar forwarding correcto para `/websocket`.

## 4) Firewall del VPS
Permitir solo:
- 80/443 (NPM/edge)
- 22 (SSH)
- 8006 solo si realmente lo expones directo (ideal: solo por NPM interno)

Denegar publico:
- 5002, 8016, 18006, 5432.

## 5) Validacion post-hardening
1. Login por dominio carga con HTTPS valido.
2. `/web/database/selector` bloqueado en produccion.
3. UAT/STAGING no accesibles por internet.
4. Backup diario sigue generando `last_success`.
