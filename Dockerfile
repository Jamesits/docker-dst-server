# Don't Starve Together Dedicated Server Docker Image
# Copyright (C) 2015 James Swineson
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

FROM debian:latest
MAINTAINER James Swineson "jamesswineson@gmail.com"

ENV STEAMCMD_INSTALLATION_DIR=/usr/local/src/steamcmd \
	DST_INSTALLATION_DIR=/usr/local/src/dst_server/ \
	DST_DATA_DIR=/data \
	DST_PORT=10999

ENV DEBIAN_FRONTEND noninteractive

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
	&& cat /root/Steam/logs/stderr.txt
	&& mkdir -p $DST_DATA_DIR/DoNotStarveTogether

COPY ./docker-entrypoint.sh $DST_DATA_DIR/docker-entrypoint.sh
RUN chmod a+x $DST_DATA_DIR/docker-entrypoint.sh
	
ENTRYPOINT [ "/data/docker-entrypoint.sh" ]
CMD [ "start" ]
EXPOSE 10999/udp