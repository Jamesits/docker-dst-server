FROM debian:latest
LABEL maintainer="James Swineson <docker@public.swineson.me>"

ARG DEBIAN_FRONTEND=noninteractive
ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz

# install packages
RUN dpkg --add-architecture i386 \
     && apt-get update -y \
    && apt-get install -y --no-install-recommends ca-certificates lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 wget tar supervisor \
    && apt-get autoremove -y \
     && apt-get clean -y \
     && rm -rf /var/lib/apt/lists/*

# Add unprivileged user
RUN groupadd dst && useradd -g dst -d /home/dst dst

# install steamcmd
RUN mkdir -p /opt/steamcmd \
    && wget "${STEAMCMD_URL}" -O /tmp/steamcmd.tar.gz \
    && tar -xvzf /tmp/steamcmd.tar.gz -C /opt/steamcmd \
    && rm -rf /tmp/*

# install helper tools
COPY supervisor.conf /etc/supervisor/
COPY entrypoint.sh /
COPY healthcheck.sh /
COPY steamcmd /usr/local/bin/
COPY dontstarve_dedicated_server_nullrenderer /usr/local/bin/
COPY install_dst_server /opt/steamcmd_scripts/
COPY install_dst_server_initial /opt/steamcmd_scripts/
RUN chmod +x /entrypoint.sh /healthcheck.sh /usr/local/bin/steamcmd /usr/local/bin/dontstarve_dedicated_server_nullrenderer

# create data directory
RUN mkdir -p /data

# install Don't Starve Together server
RUN mkdir -p /opt/dst_server \
    && steamcmd +runscript /opt/steamcmd_scripts/install_dst_server_initial \
    && rm -rf /root/Steam /root/.steam

# install default config
COPY dst_default_config /opt/dst_default_config/

EXPOSE 10999-11000/udp 12346-12347/udp
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD [ "/healthcheck.sh" ]
