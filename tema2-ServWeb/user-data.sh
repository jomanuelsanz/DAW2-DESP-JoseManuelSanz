#!/bin/bash
# =====================================================================
# user-data.sh - Proxy inverso Nginx + SSL + Flask con Docker Compose
# Alumno: JMS (José Manuel Sanz) - UT2 Despliegue
# Se ejecuta como root en el primer arranque de la instancia (cloud-init)
# =====================================================================
set -euxo pipefail
exec > >(tee /var/log/user-data-custom.log) 2>&1

# ---------- Variables a personalizar ----------
ALUMNO="José Manuel Sanz"
CENTRO="IES Pío Baroja - 2º DAW"
APP_DIR="/opt/proxy-flask"

# ---------- 1. Instalación de Docker Engine + Docker Compose ----------
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ca-certificates curl gnupg openssl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
usermod -aG docker ubuntu

# ---------- 2. Estructura de directorios ----------
mkdir -p "$APP_DIR"/{flask,nginx,certs,certbot-www}
cd "$APP_DIR"

# ---------- 3. Aplicación Flask ----------
cat > flask/app.py <<'EOF'
import os
from flask import Flask, render_template_string

app = Flask(__name__)

PLANTILLA = """<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>UT2 - Proxy inverso Nginx</title>
  <style>
    body { font-family: Arial, sans-serif; background:#f4f6f8; display:flex;
           justify-content:center; align-items:center; height:100vh; margin:0; }
    .card { background:#fff; padding:2rem 3rem; border-radius:12px;
            box-shadow:0 4px 12px rgba(0,0,0,.15); }
    h1 { color:#2c6e49; margin-top:0; }
    p { font-size:1.1rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Despliegue Nginx + SSL + Flask</h1>
    <p><strong>Alumno:</strong> {{ alumno }}</p>
    <p><strong>Centro-ciclo-grupo:</strong> {{ centro }}</p>
    <p><strong>Fecha de despliegue:</strong> {{ fecha }}</p>
    <p><em>Servido por Flask detrás de Nginx (proxy inverso con HTTPS)</em></p>
  </div>
</body>
</html>"""

@app.route("/")
def index():
    return render_template_string(
        PLANTILLA,
        alumno=os.getenv("ALUMNO", "Sin definir"),
        centro=os.getenv("CENTRO", "Sin definir"),
        fecha=os.getenv("DEPLOY_DATE", "Sin definir"),
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

cat > flask/requirements.txt <<'EOF'
flask
gunicorn
EOF

cat > flask/Dockerfile <<'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
EOF

# ---------- 4. Configuración de Nginx ----------
cat > nginx/default.conf <<'EOF'
# --- Servidor HTTP (80): redirige todo a HTTPS ---
server {
    listen 80 default_server;
    server_name _;

    # Ruta usada por Let's Encrypt (bonus) para validar el dominio
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# --- Servidor HTTPS (443): termina TLS y hace de proxy inverso ---
server {
    listen 443 ssl default_server;
    http2 on;
    server_name _;

    ssl_certificate     /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

    # TLS 1.0 y 1.1 deshabilitados; solo TLS 1.2 y 1.3
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location / {
        proxy_pass http://flask:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# ---------- 5. Docker Compose ----------
cat > docker-compose.yml <<'EOF'
services:
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certs:/etc/nginx/certs:ro
      - ./certbot-www:/var/www/certbot:ro
    depends_on:
      - flask
    networks:
      - red_interna

  flask:
    build: ./flask
    container_name: flask-app
    restart: unless-stopped
    # Solo "expose": el puerto 5000 es visible dentro de la red Docker,
    # pero NO se publica en el host, así que no es accesible desde Internet.
    expose:
      - "5000"
    environment:
      ALUMNO: ${ALUMNO}
      CENTRO: ${CENTRO}
      DEPLOY_DATE: ${DEPLOY_DATE}
    networks:
      - red_interna

networks:
  red_interna:
    driver: bridge
EOF

# ---------- 6. Variables de la aplicación (.env) ----------
cat > .env <<EOF
ALUMNO="${ALUMNO}"
CENTRO="${CENTRO}"
DEPLOY_DATE="$(date '+%d/%m/%Y %H:%M:%S %Z')"
EOF

# ---------- 7. Certificado SSL autofirmado (para el SSL inicial) ----------
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 || true)
PUBLIC_IP=${PUBLIC_IP:-127.0.0.1}

openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout certs/privkey.pem -out certs/fullchain.pem \
  -subj "/C=ES/ST=La Rioja/O=DAW2/CN=${PUBLIC_IP}" \
  -addext "subjectAltName=IP:${PUBLIC_IP}"
chmod 644 certs/*.pem

# ---------- 8. Script del bonus (Let's Encrypt) ----------
cat > enable-letsencrypt.sh <<'EOF'
#!/bin/bash
# Uso: sudo ./enable-letsencrypt.sh midominio.duckdns.org mi@correo.com
set -euo pipefail
DOMAIN="${1:?Uso: $0 dominio email}"
EMAIL="${2:?Uso: $0 dominio email}"
cd /opt/proxy-flask

docker run --rm \
  -v /opt/proxy-flask/letsencrypt:/etc/letsencrypt \
  -v /opt/proxy-flask/certbot-www:/var/www/certbot \
  certbot/certbot certonly --webroot -w /var/www/certbot \
  -d "$DOMAIN" --email "$EMAIL" --agree-tos --no-eff-email \
  --non-interactive --keep-until-expiring

cp -L "letsencrypt/live/$DOMAIN/fullchain.pem" certs/fullchain.pem
cp -L "letsencrypt/live/$DOMAIN/privkey.pem"   certs/privkey.pem
docker compose exec nginx nginx -s reload
echo "Certificado de Let's Encrypt instalado para $DOMAIN"
EOF
chmod +x enable-letsencrypt.sh

# ---------- 9. Arranque de los contenedores ----------
docker compose up -d --build

echo "=== Despliegue completado ==="