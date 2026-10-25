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
