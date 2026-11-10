# Configuración de Gunicorn - FlaskJMS (José Manuel Sanz - JMS)
bind = "127.0.0.1:8000"
workers = 2
worker_class = "sync"
timeout = 30
loglevel = "info"

accesslog = "/var/log/gunicorn/access.log"
errorlog = "/var/log/gunicorn/error.log"
# Primer campo: IP real del cliente (cabecera X-Forwarded-For puesta por Nginx)
access_log_format = '%({x-forwarded-for}i)s %(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'