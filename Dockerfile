FROM steamcmd/steamcmd:ubuntu
LABEL maintainer="James Swineson <docker@public.swineson.me>"

ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8

# install packages
# why libcurl-gnutls.so.4 in Ubuntu is packages in libcurl3-gnutls
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends libcurl3-gnutls:i386 supervisor \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# create data directory
RUN mkdir -p /data \
# Add unprivileged user
    && groupadd dst \
    && useradd -g dst -d /data dst \
    && chown -R dst:dst /data

# install helper tools
COPY supervisor /etc/supervisor/
COPY scripts_system /usr/local/bin/
COPY scripts_steam /opt/steamcmd_scripts/
RUN chmod +x /usr/local/bin/*

# install Don't Starve Together server
RUN mkdir -p /opt/dst_server \
    && rm -rf /root/Steam /root/.steam

# install default config
COPY dst_default_config /opt/dst_default_config/
RUN chown -R dst:dst /opt/dst_default_config

VOLUME [ "/data" ]

EXPOSE 10999-11000/udp 12346-12347/udp
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD [ "healthcheck.sh" ]
