FROM cm2network/steamcmd:root
LABEL maintainer="James Swineson <docker@public.swineson.me>"

ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8

# install packages
RUN dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends libcurl4-gnutls-dev:i386 supervisor \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# create data directory
RUN mkdir -p /data \
    && chown -R steam:steam /data

# install helper tools
COPY supervisor /etc/supervisor/
COPY scripts_system /usr/local/bin/
COPY scripts_steam /opt/steamcmd_scripts/
RUN chmod +x /usr/local/bin/*

# install Don't Starve Together server
RUN mkdir -p /opt/dst_server \
    && chown steam:steam /opt/dst_server \
    && steamcmd +runscript /opt/steamcmd_scripts/install_dst_server_initial \
    && rm -rf /root/Steam /root/.steam

# install default config
COPY dst_default_config /opt/dst_default_config/
RUN chown -R steam:steam /opt/dst_default_config

VOLUME [ "/data" ]

EXPOSE 10999-11000/udp 12346-12347/udp
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD [ "healthcheck.sh" ]
