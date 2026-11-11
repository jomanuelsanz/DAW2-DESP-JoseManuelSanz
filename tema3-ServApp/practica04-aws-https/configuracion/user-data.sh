#!/bin/bash
# user-data.sh - Practica 04 (Jose Manuel Sanz - JMS)
export DEBIAN_FRONTEND=noninteractive

apt update -y

apt install -y \
docker.io \
git \
curl

systemctl enable docker

systemctl start docker

mkdir -p /opt/practica04

# Anadido: permitir usar Docker sin sudo y subir ficheros por scp
usermod -aG docker ubuntu
chown ubuntu:ubuntu /opt/practica04