"""Aplicación Flask + MariaDB - Práctica 5 (DAW2 - Despliegue de Aplicaciones Web)."""
import os
import socket
import time
from datetime import datetime

import pymysql
from flask import Flask, jsonify, render_template_string, request

app = Flask(__name__)
app.json.ensure_ascii = False

ALUMNO = "José Manuel Sanz (JMS)"
PRACTICA = "Práctica 5 - Docker Compose, MariaDB, persistencia y copias de seguridad"

DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "mariadb"),
    "port": int(os.environ.get("DB_PORT", "3306")),
    "user": os.environ.get("DB_USER", "jms_user"),
    "password": os.environ.get("DB_PASSWORD", ""),
    "database": os.environ.get("DB_NAME", "practica05JMS"),
    "charset": "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor,
    "connect_timeout": 5,
}

PLANTILLA = """<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Tareas JMS - MariaDB</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 900px; margin: 40px auto; padding: 0 16px; color: #222; }
    h1 { color: #2b5aa8; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
    th, td { border: 1px solid #ccc; padding: 6px 10px; text-align: left; }
    th { background: #f0f4fa; }
    .error { background: #fde8e8; border: 1px solid #c0392b; padding: 12px; border-radius: 6px; }
    .pendiente { color: #b8860b; } .en_progreso { color: #2b5aa8; } .completada { color: #2e7d32; }
  </style>
</head>
<body>
  <h1>Lista de tareas (Flask + MariaDB)</h1>
  <p><strong>Alumno:</strong> {{ alumno }}<br>
     <strong>Práctica:</strong> {{ practica }}</p>
  <p>Arquitectura: Nginx (HTTPS) &rarr; Flask/Gunicorn &rarr; MariaDB (volumen persistente).<br>
     Contenedor Flask: <code>{{ hostname }}</code> · Base de datos: <code>{{ db }}</code> en <code>{{ dbhost }}</code> ·
     Protocolo visto por Flask: <code>{{ proto }}</code></p>

  {% if error %}
  <div class="error"><strong>No se pudieron obtener las tareas:</strong> {{ error }}</div>
  {% else %}
  <p><strong>Total de tareas:</strong> {{ tareas|length }} · Consulta realizada: {{ ahora }}</p>
  <table>
    <tr><th>ID</th><th>Título</th><th>Descripción</th><th>Estado</th><th>Creada</th></tr>
    {% for t in tareas %}
    <tr>
      <td>{{ t.id }}</td><td>{{ t.titulo }}</td><td>{{ t.descripcion }}</td>
      <td class="{{ t.estado }}">{{ t.estado }}</td><td>{{ t.fecha_creacion }}</td>
    </tr>
    {% endfor %}
  </table>
  {% endif %}
  <p>Rutas: <a href="/api/tareas">/api/tareas</a> · <a href="/salud">/salud</a></p>
</body>
</html>
"""


def conectar(reintentos=3, espera=2):
    """Abre una conexión con MariaDB (con reintentos por si aún está arrancando)."""
    ultimo_error = None
    for _ in range(reintentos):
        try:
            return pymysql.connect(**DB_CONFIG)
        except pymysql.MySQLError as exc:
            ultimo_error = exc
            time.sleep(espera)
    raise ultimo_error


def obtener_tareas():
    conexion = conectar()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                "SELECT id, titulo, descripcion, estado, fecha_creacion FROM tareas ORDER BY id"
            )
            return cursor.fetchall()
    finally:
        conexion.close()


@app.route("/")
def inicio():
    tareas, error, codigo = [], None, 200
    try:
        tareas = obtener_tareas()
    except pymysql.MySQLError as exc:
        error, codigo = str(exc), 503
    pagina = render_template_string(
        PLANTILLA,
        alumno=ALUMNO,
        practica=PRACTICA,
        hostname=socket.gethostname(),
        db=DB_CONFIG["database"],
        dbhost=DB_CONFIG["host"],
        proto=request.headers.get("X-Forwarded-Proto", "-"),
        ahora=datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
        tareas=tareas,
        error=error,
    )
    return pagina, codigo


@app.route("/api/tareas")
def api_tareas():
    try:
        return jsonify(obtener_tareas())
    except pymysql.MySQLError as exc:
        return jsonify(error=str(exc)), 503


@app.route("/salud")
def salud():
    try:
        conexion = conectar(reintentos=1)
        with conexion.cursor() as cursor:
            cursor.execute("SELECT 1")
        conexion.close()
        return "OK\n", 200, {"Content-Type": "text/plain; charset=utf-8"}
    except pymysql.MySQLError as exc:
        return f"ERROR: {exc}\n", 503, {"Content-Type": "text/plain; charset=utf-8"}