FROM debian:latest
MAINTAINER James Swineson "jamesswineson@gmail.com"

RUN dpkg --add-architecture i386 \
 	&&apt-get update -y && apt-get install -y \
		lib32gcc1 \
		lib32stdc++6 \
		libcurl4-gnutls-dev:i386 \
		wget \
		tar \
 	&& apt-get clean \
 	&& rm -rf /var/lib/apt/lists/*
	 
RUN mkdir -p /usr/local/src/steamcmd \
	&& wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz \
	&& tar -xvzf /tmp/steamcmd.tar.gz -C /usr/local/src/steamcmd
	
RUN mkdir -p /usr/local/src/dst_server \
	&& /usr/local/src/steamcmd/steamcmd.sh +login anonymous +force_install_dir /usr/local/src/dst_server +app_update 343050 validate +quit

RUN mkdir -p /data/DoNotStarveTogether
ENV SERVER_TOKEN_FILE=
ADD $SERVER_TOKEN_FILE /data/DoNotStarveTogether/server_token.txt
VOLUME ["/data"]
WORKDIR /usr/local/src/dst_server/bin/
ENTRYPOINT ["/usr/local/src/dst_server/bin/dontstarve_dedicated_server_nullrenderer", "-port", "10999", "-persistent_storage_root", "/data"]
EXPOSE 10999/udp