# Version 0.0.3
FROM debian:latest
MAINTAINER James Swineson "jamesswineson@gmail.com"

ENV STEAMCMD_INSTALLATION_DIR=/usr/local/src/steamcmd \
	DST_INSTALLATION_DIR=/usr/local/src/dst_server/ \
	DST_DATA_DIR=/data \
	DST_PORT=10999

RUN dpkg --add-architecture i386 \
 	&&apt-get update -y && apt-get install -y \
		lib32gcc1 \
		lib32stdc++6 \
		libcurl4-gnutls-dev:i386 \
		wget \
		tar \
 	&& apt-get clean \
 	&& rm -rf /var/lib/apt/lists/*
	 
RUN mkdir -p $STEAMCMD_INSTALLATION_DIR \
	&& wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz \
	&& tar -xvzf /tmp/steamcmd.tar.gz -C $STEAMCMD_INSTALLATION_DIR
	
RUN mkdir -p $DST_INSTALLATION_DIR \
	&& $STEAMCMD_INSTALLATION_DIR/steamcmd.sh +login anonymous +force_install_dir $DST_INSTALLATION_DIR +app_update 343050 validate +quit \
	&& mkdir -p $DST_DATA_DIR/DoNotStarveTogether

COPY ./docker-entrypoint.sh $DST_DATA_DIR/docker-entrypoint.sh
RUN chmod a+x $DST_DATA_DIR/docker-entrypoint.sh
	
ENTRYPOINT [ "/data/docker-entrypoint.sh" ]
CMD [ "start" ]
EXPOSE 10999/udp