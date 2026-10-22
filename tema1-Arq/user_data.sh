#!/bin/bash
# =============================================================
# user_data.sh - Despliegue automatizado de Flask + Apache + WSGI
# Autor: Jose Manuel Sanz (jms)
# Se ejecuta como root en el primer arranque de la instancia EC2
# =============================================================

# Registro de toda la salida para poder depurar sin SSH:
# /var/log/user-data.log
exec > >(tee /var/log/user-data.log) 2>&1
set -e

echo "=== [1/4] Actualizacion e instalacion de paquetes ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apache2 libapache2-mod-wsgi-py3 python3-flask

echo "=== [2/4] Estructura de directorios ==="
mkdir -p /var/www/flaskapp

echo "=== [3/4] Generacion de ficheros ==="

# ---------- app.py ----------
cat << 'EOF' > /var/www/flaskapp/app.py
from flask import Flask

app = Flask(__name__)

@app.route("/")
def inicio():
    return (
        "<h1>Aplicaci&oacute;n Flask en AWS de "
        "Jos&eacute; Manuel Sanz (jms) - 02/10/2026 "
        "desplegada autom&aacute;ticamente en AWS</h1>"
    )

if __name__ == "__main__":
    app.run()
EOF

# ---------- app.wsgi ----------
cat << 'EOF' > /var/www/flaskapp/app.wsgi
import sys

sys.path.insert(0, "/var/www/flaskapp")

from app import app as application
EOF

# ---------- flaskapp.conf ----------
cat << 'EOF' > /etc/apache2/sites-available/flaskapp.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/flaskapp

    WSGIScriptAlias / /var/www/flaskapp/app.wsgi

    <Directory /var/www/flaskapp>
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/flaskapp_error.log
    CustomLog ${APACHE_LOG_DIR}/flaskapp_access.log combined
</VirtualHost>
EOF

# Permisos: propietario www-data (usuario de Apache)
chown -R www-data:www-data /var/www/flaskapp
chmod 755 /var/www/flaskapp
chmod 644 /var/www/flaskapp/app.py /var/www/flaskapp/app.wsgi

echo "=== [4/4] Activacion del sitio ==="
a2ensite flaskapp.conf
a2dissite 000-default.conf
apache2ctl configtest
systemctl reload apache2

echo "=== Despliegue completado ==="






