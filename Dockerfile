FROM debian:latest
LABEL maintainer="James Swineson <docker@public.swineson.me>"

ARG DEBIAN_FRONTEND=noninteractive

# install packages
RUN dpkg --add-architecture i386 \
 	&& apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 wget tar supervisor \
 	&& apt-get clean \
 	&& rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install steamcmd
RUN mkdir -p /opt/steamcmd \
	&& wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz \
	&& tar -xvzf /tmp/steamcmd.tar.gz -C /opt/steamcmd \
    && ln -s /opt/steamcmd/steamcmd.sh /usr/local/bin/steamcmd

# install Don't Starve Together server
RUN mkdir -p /opt/dst_server \
	&& steamcmd +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/opt/dst_server" +app_update 343050 validate +quit \
    && ln -s /opt/dst_server/bin/dontstarve_dedicated_server_nullrenderer /usr/local/bin/dontstarve_dedicated_server_nullrenderer

# install helper tools
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY supervisor.conf /etc/supervisor/supervisor.conf

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK none