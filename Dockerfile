FROM debian:latest
LABEL maintainer="James Swineson <docker@public.swineson.me>"

ARG DEBIAN_FRONTEND=noninteractive
ARG STEAMCMD_URL=http://media.steampowered.com/installer/steamcmd_linux.tar.gz

# install packages
RUN dpkg --add-architecture i386 \
 	&& apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 wget tar supervisor \
    && apt-get autoremove -y \
 	&& apt-get clean -y \
 	&& rm -rf /var/lib/apt/lists/*

# install steamcmd
RUN mkdir -p /opt/steamcmd \
	&& wget "${STEAMCMD_URL}" -O /tmp/steamcmd.tar.gz \
	&& tar -xvzf /tmp/steamcmd.tar.gz -C /opt/steamcmd

# install helper tools
COPY supervisor.conf /etc/supervisor/supervisor.conf
COPY entrypoint.sh /entrypoint.sh
COPY steamcmd /usr/local/bin/steamcmd
RUN chmod +x /entrypoint.sh \
    && chmod +x /usr/local/bin/steamcmd

# install Don't Starve Together server
RUN mkdir -p /opt/dst_server \
	&& steamcmd +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/opt/dst_server" +app_update 343050 validate +quit \
    && ln -s /opt/dst_server/bin/dontstarve_dedicated_server_nullrenderer /usr/local/bin/dontstarve_dedicated_server_nullrenderer

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK none