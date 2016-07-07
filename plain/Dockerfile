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
	&& /usr/local/src/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/usr/local/src/dst_server" +app_update 343050 validate +quit \
    && ln -s /usr/local/src/dst_server/bin/dontstarve_dedicated_server_nullrenderer /usr/local/bin/dst-server
WORKDIR /usr/local/src/dst_server/bin

# Generate empty config
RUN expect -c "spawn dst-server -persistent_storage_root /data -conf_dir dst -cluster Cluster_1 -shard Master; expect \"Your Server Will Not Start\" { sleep 1; close };" \
    && mkdir -p /data/empty \
    && mv /data/dst/* /data/empty

# Copy default config
RUN mkdir -p /data/default
COPY config/* /data/default

COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 10999/udp
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "dst-server", "-port", "10999", "-persistent_storage_root", "/data", "-conf_dir", "dst", "-cluster", "Cluster_1", "-shard", "Master" ]
