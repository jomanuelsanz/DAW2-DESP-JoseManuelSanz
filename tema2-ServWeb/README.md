# UT2 - Proxy inverso Nginx con terminación SSL en AWS EC2 (Docker Compose)

Alumno: José Manuel Sanz (JMS)

## Arquitectura
Usuario → Internet → HTTPS 443 → EC2 (Ubuntu) → Nginx (proxy inverso, termina TLS)
→ HTTP interno (red Docker `red_interna`) → Flask (puerto 5000, no expuesto).

## Ficheros
| Fichero | Descripción |
|---|---|
| `user-data.sh` | Script de primer arranque: instala Docker y Compose, crea los ficheros, genera el certificado y levanta los contenedores |
| `docker-compose.yml` | Define Nginx (80/443), Flask (solo `expose` 5000) y la red privada |
| `nginx/default.conf` | Redirección HTTP→HTTPS, TLS 1.2/1.3 y proxy inverso |
| `flask/` | Código de la aplicación (`app.py`, `Dockerfile`, `requirements.txt`) |
| `enable-letsencrypt.sh` | Bonus: certificado válido con Let's Encrypt |

## Uso
1. Crear una instancia Ubuntu 24.04 con un Security Group que permita TCP 22, 80 y 443.
2. Pegar `user-data.sh` en *Advanced details → User data*.
3. Esperar unos minutos y abrir `https://IP_PUBLICA`.

## Comprobaciones
    curl -k -I https://IP_PUBLICA                      # HTTP/1.1 200 OK
    curl -I http://IP_PUBLICA                          # 301 Moved Permanently
    openssl s_client -connect IP_PUBLICA:443 -tls1     # debe fallar
    openssl s_client -connect IP_PUBLICA:443 -tls1_2   # debe conectar

## Bonus: Let's Encrypt
    sudo ./enable-letsencrypt.sh DOMINIO EMAIL
    curl -Iv https://DOMINIO