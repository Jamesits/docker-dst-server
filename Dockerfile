FROM debian:latest
MAINTAINER James Swineson "jamesswineson@gmail.com"
RUN dpkg --add-architecture i386
RUN apt-get -y update
RUN apt-get -y install lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 wget tar
RUN useradd -m steam
RUN /usr/bin/env bash chmod a+rw `tty`
RUN su - steam
RUN mkdir ~/steamcmd
RUN cd ~/steamcmd
RUN wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
RUN tar -xvzf steamcmd_linux.tar.gz
RUN ./steamcmd.sh +login anonymous +force_install_dir /home/steam/dst_server +app_update 343050 validate +quit
RUN cd /home/steam/dst_server/bin/
CMD [ "/home/steam/dst_server/dontstarve_dedicated_server_nullrenderer" ]
EXPOSE 10999/udp