# Despliegue automatizado de Flask en AWS EC2 (Apache + mod_wsgi)

**Autor:** José Manuel Sanz (jms)  
**Módulo:** Despliegue de Aplicaciones Web · C.F.G.S. DAW  
**Práctica:** UT1-RA1 Arquitectura web

## Descripción

Script `user_data.sh` que, inyectado en el campo *User Data* de una instancia
Ubuntu en AWS EC2, instala y configura sin intervención manual (sin SSH) un
servidor Apache que sirve una aplicación Flask mediante `mod_wsgi`.

## Qué hace el script

1. Actualiza repositorios e instala `apache2`, `libapache2-mod-wsgi-py3` y `python3-flask`.
2. Crea `/var/www/flaskapp/` y asigna permisos a `www-data`.
3. Genera con bloques `cat << 'EOF'`:
   - `app.py`: aplicación Flask con mensaje personalizado.
   - `app.wsgi`: adaptador WSGI (añade la ruta a `sys.path` e importa `application`).
   - `flaskapp.conf`: VirtualHost con `WSGIScriptAlias / /var/www/flaskapp/app.wsgi`.
4. Habilita `flaskapp.conf`, deshabilita `000-default.conf` y recarga Apache.

## Configuración de la instancia EC2

| Parámetro | Valor |
|---|---|
| Nombre | jms-flaskapp-ut1 |
| AMI | Ubuntu Server 24.04 LTS |
| Tipo | t2.micro / t3.micro |
| Par de claves | jms-key-ut1 |
| Grupo de seguridad | jms-sg-flaskapp: SSH (22) y HTTP (80) |
| IP pública | Habilitada (auto-assign) |
| User Data | Contenido de `user_data.sh` |

## Uso

1. Lanzar la instancia pegando `user_data.sh` en *Advanced details → User data*.
2. Esperar 2-3 minutos.
3. Abrir `http://<IP_PUBLICA>` en el navegador.

## Depuración

- Log del script: `/var/log/user-data.log`
- Log de cloud-init: `/var/log/cloud-init-output.log`
- Errores de Apache: `/var/log/apache2/flaskapp_error.log`

## Resultado

IP pública de la instancia: `35.172.191.9`

## Historial de cambios

Ver `git log`.

