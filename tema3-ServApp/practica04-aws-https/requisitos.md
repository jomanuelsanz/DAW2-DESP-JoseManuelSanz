# Práctica 04. Despliegue en AWS EC2 con HTTPS y Certificados SSL/TLS de una aplicación Flask con Gunicorn y Nginx

## Criterios de evaluación

- d) Configurar y gestionar mecanismos de seguridad.
- f) Realizar el despliegue de aplicaciones sobre el servidor de aplicaciones.
- i) Aplicar procedimientos de despliegue utilizando tecnologías de virtualización y contenedores.

---

# Objetivo

Desplegar en Internet una aplicación Flask utilizando AWS EC2, Gunicorn y Nginx.

La configuración inicial de la instancia deberá automatizarse mediante AWS User Data utilizando un script `user-data.sh`.

Posteriormente se configurará HTTPS mediante certificados SSL/TLS para proteger las comunicaciones.

---

# Arquitectura objetivo

```text
Internet
    │
 HTTPS
    │
    ▼
 Nginx
 (Reverse Proxy)
    │
    ▼
 Gunicorn
    │
    ▼
 Flask
```

---

# Objetivos de aprendizaje

Al finalizar esta práctica el alumnado será capaz de:

- Crear instancias EC2 en AWS.
- Configurar grupos de seguridad.
- Utilizar User Data para automatizar servidores.
- Conectarse mediante SSH.
- Desplegar aplicaciones Flask.
- Utilizar Gunicorn como servidor WSGI.
- Configurar Nginx como Reverse Proxy.
- Implementar HTTPS mediante SSL/TLS.
- Analizar logs de Nginx y Gunicorn.
- Documentar despliegues profesionales.

---

# Requisitos previos

Antes de comenzar:

✅ AWS Academy operativo.

✅ Learner Lab iniciado.

✅ Aplicación Flask funcional de la práctica anterior.

✅ Git instalado.

✅ Visual Studio Code instalado.

✅ Acceso SSH disponible.

---

# Estructura del repositorio

Crear la siguiente estructura:

```text
practica04-aws-https/
│
├── requisitos-practica04-aws-https.md
├── README.md
│
├── aplicacion/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── configuracion/
│   ├── user-data.sh
│   ├── nginx.conf
│   ├── certificado.crt
│   ├── clave.key
│   └── instrucciones.txt
│
├── capturas/
│
└── docs/
    └── arquitectura.png
```

---

# TAREA 1. Iniciar AWS Academy

## Paso 1. Iniciar laboratorio

Acceder a:

```text
AWS Academy
```

---

## Paso 2. Abrir Learner Lab

Pulsar:

```text
Start Lab
```

Esperar hasta que aparezca:

```text
AWS Console
```

---

## Paso 3. Abrir la consola AWS

Acceder a:

```text
AWS Console
```

### Captura obligatoria

```text
capturas/01-lab-iniciado.png
```

---

# TAREA 2. Crear una instancia EC2

## Paso 1. Abrir EC2

Buscar:

```text
EC2
```

en la barra superior.

Seleccionar el servicio.

### Captura obligatoria

```text
capturas/02-panel-ec2.png
```

---

## Paso 2. Crear una instancia

Pulsar:

```text
Launch Instance
```

---

## Paso 3. Configuración básica

### Nombre

```text
practica04-flask
```

### Sistema operativo

```text
Ubuntu Server 24.04 LTS
```

### Tipo

```text
t2.micro
```

---

## Paso 4. Crear clave SSH

Crear:

```text
practica04.pem
```

Guardar el fichero en el equipo local.

### Captura obligatoria

```text
capturas/03-keypair.png
```

---

# TAREA 3. Automatización mediante User Data

## Objetivo

Automatizar la preparación inicial del servidor.

AWS ejecutará automáticamente este script durante el primer arranque de la instancia.

---

## Paso 1. Crear user-data.sh

Crear:

```text
configuracion/user-data.sh
```

Contenido:

```bash
#!/bin/bash

apt update -y

apt install -y \
docker.io \
git \
curl

systemctl enable docker

systemctl start docker

mkdir -p /opt/practica04
```

---

## Paso 2. Analizar el script

Crear:

```text
configuracion/instrucciones.txt
```

Explicando:

```text
apt update

docker.io

git

curl

systemctl

mkdir
```

---

## Paso 3. Añadir User Data a la instancia

Durante la creación de la instancia:

```text
Advanced Details
```

Localizar:

```text
User Data
```

Pegar el contenido de:

```text
user-data.sh
```

### Captura obligatoria

```text
capturas/04-user-data-configurado.png
```

---

## Paso 4. Crear la instancia

Pulsar:

```text
Launch Instance
```

Esperar a que el estado sea:

```text
Running
```

### Captura obligatoria

```text
capturas/05-instancia-running.png
```

---

# TAREA 4. Configurar Security Group

Permitir los siguientes puertos:

## SSH

```text
22
```

## HTTP

```text
80
```

## HTTPS

```text
443
```

### Captura obligatoria

```text
capturas/06-security-group.png
```

---

# TAREA 5. Conectarse por SSH

## Paso 1. Obtener IP pública

Localizar:

```text
Public IPv4 Address
```

### Captura obligatoria

```text
capturas/07-ip-publica.png
```

---

## Paso 2. Abrir PowerShell

Situarse en la carpeta donde está:

```text
practica04.pem
```

---

## Paso 3. Conectar

```powershell
ssh -i practica04.pem ubuntu@IP_PUBLICA
```

Ejemplo:

```powershell
ssh -i practica04.pem ubuntu@3.85.xxx.xxx
```

---

## Paso 4. Verificar acceso

Debe aparecer:

```text
Welcome to Ubuntu
```

### Captura obligatoria

```text
capturas/08-ssh-conectado.png
```

---

# TAREA 6. Verificar automatización

## Comprobar Docker

```bash
docker --version
```

---

## Verificar servicio

```bash
systemctl status docker
```

---

## Comprobar directorio

```bash
ls /opt
```

Debe aparecer:

```text
practica04
```

### Captura obligatoria

```text
capturas/09-docker-instalado-automaticamente.png
```

---

# TAREA 7. Subir la aplicación Flask

## Paso 1. Crear carpeta

```bash
cd /opt/practica04
```

---

## Paso 2. Copiar la aplicación

Subir:

```text
app.py

requirements.txt

Dockerfile
```

mediante:

```text
scp
```

o Visual Studio Code.

### Captura obligatoria

```text
capturas/10-aplicacion-subida.png
```

---

# TAREA 8. Construir la imagen Docker

## Construir imagen

```bash
docker build -t flask-app .
```

### Captura obligatoria

```text
capturas/11-build-docker.png
```

---

# TAREA 9. Ejecutar Flask mediante Gunicorn

## Ejecutar contenedor

```bash
docker run -d \
-p 5000:5000 \
--name flask-app \
flask-app
```

---

## Verificar contenedor

```bash
docker ps
```

### Captura obligatoria

```text
capturas/12-contenedor-flask.png
```

---

# TAREA 10. Comprobar Gunicorn

## Mostrar logs

```bash
docker logs flask-app
```

Identificar:

```text
Gunicorn

Listening at

Worker
```

### Captura obligatoria

```text
capturas/13-gunicorn-operativo.png
```

---

# TAREA 11. Acceder directamente a Flask

Abrir:

```text
http://IP_PUBLICA:5000
```

La aplicación debe responder correctamente.

### Captura obligatoria

```text
capturas/14-flask-directo.png
```

---

# TAREA 12. Instalar Nginx

## Instalar

```bash
sudo apt install nginx -y
```

---

## Verificar

```bash
systemctl status nginx
```

### Captura obligatoria

```text
capturas/15-nginx-instalado.png
```

---

# TAREA 13. Configurar Reverse Proxy

## Editar configuración

```bash
sudo nano /etc/nginx/sites-available/default
```

---

## Configurar

Investigar y utilizar:

```text
proxy_pass
```

para reenviar el tráfico hacia:

```text
localhost:5000
```

---

## Reiniciar Nginx

```bash
sudo systemctl restart nginx
```

### Captura obligatoria

```text
capturas/16-reverse-proxy.png
```

---

# TAREA 14. Verificar acceso mediante Nginx

Abrir:

```text
http://IP_PUBLICA
```

La aplicación deberá mostrarse correctamente.

### Captura obligatoria

```text
capturas/17-nginx-flask.png
```

---

# TAREA 15. Generar certificados SSL/TLS

## Paso 1. Crear carpeta

```bash
mkdir certificados

cd certificados
```

---

## Paso 2. Generar certificado

```bash
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout clave.key \
-out certificado.crt
```

---

## Paso 3. Copiar certificados

Guardar:

```text
certificado.crt

clave.key
```

en:

```text
configuracion/
```

### Captura obligatoria

```text
capturas/18-certificados-generados.png
```

---

# TAREA 16. Configurar HTTPS

## Objetivo

Modificar Nginx para aceptar conexiones seguras.

---

## Investigar

Añadir configuración relacionada con:

```text
listen 443 ssl;

ssl_certificate

ssl_certificate_key
```

---

## Reiniciar servicio

```bash
sudo systemctl restart nginx
```

### Captura obligatoria

```text
capturas/19-configuracion-https.png
```

---

# TAREA 17. Verificar HTTPS

Abrir:

```text
https://IP_PUBLICA
```

Comprobar:

✅ Certificado activo.

✅ Aplicación accesible.

✅ Puerto 443 operativo.

### Captura obligatoria

```text
capturas/20-https-funcionando.png
```

---

# TAREA 18. Análisis de logs

## Logs Nginx

```bash
sudo cat /var/log/nginx/access.log
```

### Captura obligatoria

```text
capturas/21-logs-nginx.png
```

---

## Logs Gunicorn

```bash
docker logs flask-app
```

### Captura obligatoria

```text
capturas/22-logs-gunicorn.png
```

---

# TAREA 19. Análisis de la arquitectura

Explicar:

## AWS EC2

Función de la máquina virtual.

---

## User Data

Ventajas de automatización.

---

## Flask

Función de la aplicación.

---

## Gunicorn

Función como servidor WSGI.

---

## Nginx

Función de Reverse Proxy.

---

## HTTPS

Ventajas de SSL/TLS.

---

# README.md

El README deberá incluir:

```text
1. Introducción.

2. Objetivos.

3. Arquitectura utilizada.

4. AWS EC2.

5. User Data.

6. Flask.

7. Gunicorn.

8. Nginx.

9. HTTPS.

10. Evidencias obtenidas.

11. Problemas encontrados.

12. Soluciones aplicadas.

13. Conclusiones.
```

---

# Estructura mínima obligatoria de entrega

```text
practica04-aws-https/
│
├── requisitos.md
├── README.md
│
├── aplicacion/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── configuracion/
│   ├── user-data.sh
│   ├── nginx.conf
│   ├── certificado.crt
│   ├── clave.key
│   └── instrucciones.txt
│
├── capturas/
│   ├── 01-lab-iniciado.png
│   ├── ...
│   └── 22-logs-gunicorn.png
│
└── docs/
    └── arquitectura.png
```

---
 