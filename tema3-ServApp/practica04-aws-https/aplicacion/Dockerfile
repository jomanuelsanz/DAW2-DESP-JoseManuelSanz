FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Usuario sin privilegios
RUN useradd -m appuser
USER appuser

EXPOSE 5000

# Gunicorn escribe accesos y errores en la salida estandar (visibles con docker logs)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", \
     "--access-logfile", "-", "--error-logfile", "-", \
     "--access-logformat", "%({x-forwarded-for}i)s %(h)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\"", \
     "app:app"]