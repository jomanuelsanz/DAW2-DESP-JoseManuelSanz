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
