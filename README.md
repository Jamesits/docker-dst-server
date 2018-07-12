# Don't Starve Together Dedicated Server Docker Image

This is the Docker image for DST dedicated server, based on [`debian:latest`](https://hub.docker.com/_/debian/).

----------

## Project Status

***Working on new features, document not ready. Anything below is outdated.***

## Known Issues

 * On Docker environment which doesn't support UDP port forwarding, LAN only server cannot be used. (Still you can enable Steam punchthrough and search for your server in `Online` catalog. )
 * Cave server are not tested.
 * If you forward port 10999/udp to another port, clients may not connect. 
 
# Recommended Hardware

 * 1GB base RAM, plus 60MB per user.
 
----------

## Install Using Docker Compose

Create a folder for storing DST server files, then put a `docker-compose.yml` inside it, paste the following content: 
```yaml
overworld-server:
  image: jamesits/dst-server:plain
  restart: always
  ports:
  - 10999:10999/udp
  volumes:
  - ./server_config:/data/dst
```
Then use `docker-compose up` to bring up the server. You can change server config in `./server_config`.

To update image, use `docker-compose pull` to update automatically. 

## Manual Installation

### Install from Docker Hub

```shell
docker pull jamesits/dst-server
```

Note: If you use Docker the VM way (i.e. running the image without `/data/dst` mounted to a volume or host), please be cautious:

  * All data (server settings, saved game status, etc.) will be **DELETED PERMANATELY** when deleting or updating image
  * You have to use the default server configuration or pass command line arguments by yourself

More Information please refer to [Docker Hub page](https://hub.docker.com/r/jamesits/don-t-starve-together-dedicated-server/).

### Build Docker image locally

```shell
git clone https://github.com/Jamesits/docker-dst-server.git docker-dst-server
cd docker-dst-server
docker build . -t dst-server:latest
```

----------
 
## Server Settings

All persist server settings can be found under `./server_config` by default. 

## Instructions on Obtaining Server Token

Launch a steam client on a system with GUI, install Don't Starve Together, log in, press `~` button then type `TheNet:GenerateClusterToken()` then press enter. You'll find a `cluster_token.txt` under your client config directory. (See ["References"](#references) section below for more detailed instructions. )

If you use the Docker Compose way, or have `/data/dst` mounted to your host machine, **copy the FILE** `server_token.txt` (not its content) to that folder. Also you may set token in `settings.ini`.

In other cases, you can set ENV `DST_CLUSTER_TOKEN` using the content of your `cluster_token.txt`. Just open it use any text editor and **copy the CONTENT**.

## Modify Settings on a Volume You Don't Have Access To

 1. Create or use a Docker container which have SSH Daemon service (Like [`rastasheep/ubuntu-sshd`](https://registry.hub.docker.com/u/rastasheep/ubuntu-sshd/), but for security issues I recommend using your own image and use pubkey authencation. )
 2. Mount your server config volume to some place of our SSH Daemon container
 3. SSH into daemon container and change settings
 4. Restart game server using `docker-compose restart`
 
Sample `docker-compose.yml` which can be appended after original one: 
```yaml
manager:
  image: rastasheep/ubuntu-sshd
  restart: always
  ports:
  - 22
  volumes:
  - ./server_config:/mnt/DoNotStarveTogether
```

----------

## Maintainer

 * [James Swineson](https://swineson.me)
 * [@Arthur2e5](https://github.com/Arthur2e5)
 
## Thanks

 * [@MephistoMMM](https://github.com/MephistoMMM)
 * [@m13253](https://github.com/m13253)
 * [@wph95](https://github.com/wph95)
 * [DaoCloud](https://daocloud.io)
 * [CodeVS](http://codevs.cn/)
 
## License

    Don't Starve Together Dedicated Server Docker Image
    Copyright (C) 2015 James Swineson (Jamesits)
    Copyright (C) 2015 Mingye Wang (Arthur2e5)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

## References

 * [Guides/Don’t Starve Together Dedicated Servers](http://dont-starve-game.wikia.com/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)
 * [[GUIDE] How to setup server dedicated cave on Linux](http://forums.kleientertainment.com/topic/59563-guide-how-to-setup-server-dedicated-cave-on-linux/)
 * [Run dedicated server in Docker](http://forums.kleientertainment.com/topic/60329-run-dedicated-server-in-docker/) (This post was written by me)
 * [Guides by ToNiO in Steam community](https://steamcommunity.com/id/ToNiO44/myworkshopfiles/?section=guides&appid=322330)