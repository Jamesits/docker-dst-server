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
	&& tar -xvzf /tmp/steamcmd.tar.gz -C /usr/local/src/steamcmd \
    && echo "#!/bin/bash\nexec /usr/local/src/steamcmd/steamcmd.sh #@"> /usr/local/bin/steamcmd \
    && chmod +x /usr/local/bin/steamcmd
    
RUN mkdir -p /data/dst
VOLUME /data/dst

RUN mkdir -p /usr/local/src/dst_server \
	&& steamcmd +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/usr/local/src/dst_server" +app_update 343050 validate +quit \
    && ln -s /usr/local/src/dst_server/bin/dontstarve_dedicated_server_nullrenderer /usr/local/bin/dst-server
    
# Generate default config
RUN expect -c "spawn dst-server -persistent_storage_root /data -conf_dir dst -cluster Cluster_1 -shard Master; expect \"Your Server Will Not Start\"; abort" \
    && mkdir -p /data/default \
    && mv /data/dst/* /data/default

WORKDIR /usr/local/src/dst_server/bin

COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 10999/udp
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "dst-server", "-port", "10999", "-persistent_storage_root", "/data", "-conf_dir", "dst", "-cluster", "Cluster_1", "-shard", "Master" ]
