# Memoria - Práctica 3: Flask + Gunicorn + Nginx

**Alumno:** José Manuel Sanz (JMS) · DAW2 · Despliegue de Aplicaciones Web · Tema 3

Este documento amplía el análisis teórico de la práctica. La parte técnica (comandos, configuración y evidencias) está en [`README.md`](README.md).

---

## 1. Resumen del trabajo

Se ha desarrollado una aplicación web con **Flask** (`FlaskJMS`), ejecutada con **Gunicorn** y publicada mediante **Nginx** como Reverse Proxy, todo dentro de un contenedor Ubuntu con **systemd** que simula un servidor Linux. Gunicorn se ha configurado como servicio de systemd con arranque automático y reinicio ante fallos, y se han analizado los registros de Nginx, Gunicorn y systemd.

---

## 2. Análisis de componentes (Tarea 6)

### 2.1 Flask

- **Función principal:** microframework web de Python. Permite definir rutas (`@app.route`), procesar peticiones y construir respuestas (HTML con plantillas, JSON, texto) con muy poco código.
- **Uso dentro de la arquitectura:** es la **aplicación**. Contiene la lógica de `FlaskJMS` y no se encarga de gestionar conexiones de red de forma robusta; entrega una aplicación WSGI que Gunicorn ejecuta.
- **Servidor de desarrollo:** Flask incluye uno (Werkzeug), útil para probar, pero advierte de que no debe usarse en producción.

### 2.2 Gunicorn

- **Función principal:** servidor HTTP **WSGI** para Python con modelo de procesos (*pre-fork*): un proceso maestro supervisa varios *workers* que atienden las peticiones.
- **Diferencias respecto a Flask:** Flask es el *qué* (la lógica de la aplicación); Gunicorn es el *cómo se ejecuta* (procesos, concurrencia, timeouts, reinicio de workers, logs). Flask define la aplicación y Gunicorn la sirve de forma robusta.
- **WSGI:** estándar de Python que define cómo un servidor se comunica con una aplicación web. Es el equivalente conceptual de la API de Servlets en Java.

### 2.3 Nginx

- **Función principal:** servidor web de alto rendimiento y **Reverse Proxy**.
- **Ventajas de utilizar un Reverse Proxy:**
  - Punto único de entrada y ocultación de la infraestructura interna.
  - Gunicorn solo escucha en `127.0.0.1`: no es accesible desde fuera.
  - Gestión de TLS/HTTPS, ficheros estáticos, caché y compresión.
  - Posibilidad de balancear carga entre varias instancias.
  - Registros centralizados de acceso.
  - Gunicorn queda protegido frente a clientes lentos o conexiones maliciosas.

---

## 3. Comparación con Tomcat (Tarea 10)

```text
Práctica 2:   Cliente → Nginx → Tomcat   → Aplicación Java
Práctica 3:   Cliente → Nginx → Gunicorn → Flask
```

### 3.1 Similitudes

- Misma **arquitectura multicapa**: un servidor web frontal y un servidor de aplicaciones detrás.
- Nginx actúa como Reverse Proxy con `proxy_pass` y las mismas cabeceras `Host`, `X-Real-IP` y `X-Forwarded-*`.
- El servidor de aplicaciones **no se expone** al exterior (en la práctica 2, el puerto 8080 se dejó de publicar; aquí Gunicorn escucha solo en `127.0.0.1`).
- En ambos casos hay un **proceso supervisado** y logs en cada capa para trazar una petición.
- La aplicación ve la IP de Nginx y recibe la del cliente real por `X-Forwarded-For`.

### 3.2 Diferencias

| Aspecto | Tomcat | Gunicorn |
|---|---|---|
| Lenguaje y plataforma | Java (JVM) | Python |
| Estándar de aplicación | Jakarta Servlet / JSP | WSGI |
| Qué es | Contenedor de servlets completo (Catalina, Coyote, Jasper) | Servidor WSGI ligero |
| Artefacto desplegado | WAR | Código Python + entorno virtual |
| Despliegue | Copiar el WAR a `webapps`; despliegue en caliente | Arrancar el proceso (servicio) apuntando al módulo `app:app` |
| Concurrencia | Hilos en un proceso | Procesos *worker* |
| Configuración | `server.xml`, `web.xml`, `context.xml` | `gunicorn.conf.py` o parámetros de línea de comandos |
| Gestión del servicio | Scripts de Tomcat / contenedor | systemd |
| Varias aplicaciones | Varios WAR en el mismo servidor | Normalmente una aplicación (o proceso) por servicio |

### 3.3 Ventajas de cada tecnología

- **Tomcat:** ecosistema Java maduro y estandarizado, despliegue sencillo de aplicaciones empaquetadas, varias aplicaciones en un mismo servidor, herramientas de administración y gran rendimiento en aplicaciones Java empresariales.
- **Gunicorn + Flask:** puesta en marcha rápida, poco consumo de recursos, configuración sencilla y desarrollo ágil con Python; encaja bien con microservicios y se integra de forma natural con systemd.

---

## 4. Decisiones técnicas

- **Contenedor con systemd:** la Tarea 7 exige un servicio systemd y estos solo existen en sistemas con init. Un contenedor Ubuntu con systemd como PID 1 permite practicar con un servidor Linux realista sin instalar una máquina virtual.
- **Gunicorn en `127.0.0.1:8000`:** solo accesible desde dentro del servidor; el único punto de entrada es Nginx.
- **Entorno virtual en `/opt/venv-jms`:** aísla las dependencias de la aplicación y evita problemas de permisos con el volumen de Windows.
- **Usuario `www-data`:** el servicio no se ejecuta como root.
- **Logs en ficheros:** Gunicorn escribe en `/var/log/gunicorn` y Nginx en `/var/log/nginx`; systemd registra el ciclo de vida en el journal.
- **Puerto 8090:** evita el conflicto con los contenedores de la práctica 2.

---

## 5. Posibles mejoras

HTTPS con certificados, socket Unix entre Nginx y Gunicorn, `ProxyFix` en Flask, Nginx sirviendo estáticos, `logrotate`, limitación de peticiones, monitorización, Docker Compose con servicios separados y despliegue automatizado (CI/CD).

---

## 6. Aprendizajes

- Qué papel juega cada capa (aplicación, servidor de aplicaciones, servidor web) y cómo se comunican.
- Cómo se convierte un proceso en servicio con systemd y cómo se comprueba su ciclo de vida y su recuperación ante fallos.
- Cómo interpretar los registros de las distintas capas para diagnosticar un error (por ejemplo, el 502 de Nginx cuando Gunicorn está parado).
- Que una arquitectura profesional con Python es conceptualmente idéntica a la de Java: lo que cambia son la tecnología y el estándar de comunicación (Servlet/JSP frente a WSGI).