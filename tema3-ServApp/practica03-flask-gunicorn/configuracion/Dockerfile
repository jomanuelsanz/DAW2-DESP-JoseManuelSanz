FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        systemd systemd-sysv dbus \
        nginx \
        python3 python3-venv python3-pip \
        curl iproute2 procps nano less ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/journal && \
    systemctl mask getty.target console-getty.service

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]