FROM debian:latest
MAINTAINER James Swineson "jamesswineson@gmail.com"
RUN dpkg --add-architecture i386
RUN apt-get -y update
RUN apt-get -y install lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 wget tar
RUN mkdir -p /usr/local/src/steamcmd
RUN wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz -O /tmp/steamcmd.tar.gz
RUN tar -xvzf /tmp/steamcmd.tar.gz -C /usr/local/src/steamcmd
RUN /usr/local/src/steamcmd/steamcmd.sh +login anonymous +app_update 343050 validate +quit
RUN apt-get -y install tree
RUN tree /usr/local/src/steamcmd/
RUN cd /usr/local/src/dst_server
CMD [ "/usr/local/src/dst_server/bin/dontstarve_dedicated_server_nullrenderer" ]
EXPOSE 10999/udp