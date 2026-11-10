"""Aplicación Flask - Práctica 3 (DAW2 - Despliegue de Aplicaciones Web)."""
import platform
import socket
from datetime import datetime

from flask import Flask, jsonify, render_template_string, request

app = Flask(__name__)
app.json.ensure_ascii = False

ALUMNO = "José Manuel Sanz (JMS)"
PRACTICA = "Práctica 3 - Despliegue de una aplicación Flask con Gunicorn y Nginx"
MODULO = "Despliegue de Aplicaciones Web (DAW2) - Tema 3: Servidores de Aplicaciones"

PLANTILLA = """<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>FlaskJMS</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 760px; margin: 40px auto; padding: 0 16px; color: #222; }
    h1 { color: #2b5aa8; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
    td { border: 1px solid #ccc; padding: 6px 10px; }
    td:first-child { background: #f0f4fa; font-weight: bold; width: 40%; }
  </style>
</head>
<body>
  <h1>¡Bienvenido a FlaskJMS!</h1>
  <p><strong>Alumno:</strong> {{ alumno }}</p>
  <p><strong>Práctica:</strong> {{ practica }}</p>
  <p><strong>Módulo:</strong> {{ modulo }}</p>
  <p>Arquitectura: Nginx (Reverse Proxy) &rarr; Gunicorn (servidor WSGI) &rarr; Flask.</p>

  <h2>Datos del servidor</h2>
  <table>
    {% for clave, valor in servidor.items() %}
    <tr><td>{{ clave }}</td><td>{{ valor }}</td></tr>
    {% endfor %}
  </table>

  <h2>Datos de la petición recibida por Flask</h2>
  <table>
    {% for clave, valor in peticion.items() %}
    <tr><td>{{ clave }}</td><td>{{ valor }}</td></tr>
    {% endfor %}
  </table>
  <p>Rutas disponibles: <a href="/info">/info</a> · <a href="/salud">/salud</a> · <a href="/error">/error</a> (provoca un error 500 a propósito)</p>
</body>
</html>
"""


def datos_servidor():
    return {
        "hostname": socket.gethostname(),
        "python": platform.python_version(),
        "sistema": platform.platform(),
        "hora": datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
    }


def datos_peticion():
    return {
        "metodo": request.method,
        "ruta": request.path,
        "ip que ve Flask (remote_addr)": request.remote_addr,
        "Host": request.headers.get("Host"),
        "X-Forwarded-For": request.headers.get("X-Forwarded-For"),
        "X-Real-IP": request.headers.get("X-Real-IP"),
        "X-Forwarded-Proto": request.headers.get("X-Forwarded-Proto"),
    }


@app.route("/")
def inicio():
    return render_template_string(
        PLANTILLA,
        alumno=ALUMNO,
        practica=PRACTICA,
        modulo=MODULO,
        servidor=datos_servidor(),
        peticion=datos_peticion(),
    )


@app.route("/info")
def info():
    return jsonify(
        alumno=ALUMNO,
        practica=PRACTICA,
        servidor=datos_servidor(),
        peticion=datos_peticion(),
    )


@app.route("/salud")
def salud():
    return "OK\n", 200, {"Content-Type": "text/plain; charset=utf-8"}


@app.route("/error")
def error():
    # Error intencionado para generar un 500 y una traza en los logs
    return str(1 / 0)


if __name__ == "__main__":
    # Servidor de desarrollo de Flask: SOLO para pruebas
    app.run(host="0.0.0.0", port=5000)