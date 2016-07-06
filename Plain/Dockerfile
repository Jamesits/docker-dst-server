FROM debian:latest
MAINTAINER James Swineson <jamesswineson@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 \
 	&& apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 wget tar expect \
 	&& apt-get clean \
 	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/src/steamcmd \
	&& wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz \
	&& tar -xvzf /tmp/steamcmd.tar.gz -C /usr/local/src/steamcmd
    
RUN mkdir -p /data/dst
VOLUME /data/dst

RUN mkdir -p /usr/local/src/dst_server \
	&& /usr/local/src/steamcmd/steamcmd.sh +login anonymous +force_install_dir "/usr/local/src/dst_server" +app_update 343050 validate +quit \
	&& cat /root/Steam/logs/stderr.txt \
    && ln -s /usr/local/src/dst_server/bin/dontstarve_dedicated_server_nullrenderer /usr/local/bin/dst-server \
# Generate default config
    && expect -c "spawn dst-server -persistent_storage_root /data -conf_dir dst -cluster Cluster_1 -shard Master; expect \"Your Server Will Not Start\"; abort" \
    && mkdir -p /data/default \
    && mv /data/dst/* /data/default

WORKDIR /usr/local/src/dst_server/bin

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "dst-server", "-port", "10999", "-persistent_storage_root", "/data", "-conf_dir", "dst", "-cluster", "Cluster_1", "-shard", "Master" ]
EXPOSE 10999/udp
