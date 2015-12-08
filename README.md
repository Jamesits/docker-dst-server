# Don't Starve Together Dedicated Server Docker Image

This is the Docker image for DST dedicated server, based on [`debian:latest`](https://hub.docker.com/_/debian/).

----------

## Project Status

It's been proved working on at least 2 servers with a customizes settings. There is currently no automated tests or CI. 

Functions: 

 * [x] Server up and running
 * [x] `server_token.txt` settings
 * [x] Data persistance
 * [ ] Backup and restore
 * [ ] Cave server
 * [ ] Switch saved status
 * [ ] Config via `ENV`
 * [ ] Cross-platform test

Tested environments: 
  
  * [x] An Antergos (based on Arch Linux)
    * System inside a Hyper-V Virtual Machine of Windows 8.1
    * 8GB RAM
    * running the `latest` tag of Docker Hub image, i.e. the most recent code from `master` of this Github repo
  * [x] An DaoCloud server
    * 1GB RAM
    * running the most recent tagged code in this Github repo
    * image built from DaoCloud custom mechanism

## Known Issues

 * There is currently no easy way to set up Cave server using this. Working in progress. 
 * On Docker environment which doesn't support UDP port forwarding, LAN only server cannot be used. (Still you can enable Steam punchthrough and search for your server in `Online` catalog. )
 * It should be cross-platform, but OS X and Windows haven't been fully tested. 
 
----------

## Install Using Docker Compose

It's the recommended way for those who are not familiar with Docker. 

Create a folder for storing DST server files, then put a `docker-compose.yml` inside it, paste the following content: 
```yaml
overworld-server:
  image: jamesits/don-t-starve-together-dedicated-server:latest
  restart: always
  ports:
  - 10999:10999/udp
  volumes:
  - ./server_config:/data/DoNotStarveTogether
```
Then use `docker-compose up` to bring up the server. You can change server config in `./server_config`.

To update image, use `docker-compose pull` to update automatically. 

## Manual Installation

Do this only if you know how to use Docker and know exactly what every command means. Data is invaluable. 

### Install from Docker Hub

```shell
docker pull jamesits/don-t-starve-together-dedicated-server
```

### Install from DaoCloud

Chinese users may experience a faster download speed in this way. I can't promise it will be available in a long time. 

```shell
docker pull daocloud.io/codevs/dst_server:master-init
```

Note: If you use Docker the VM way (i.e. running the image without `/data/DoNotStarveTogether` mounted to a volume or host), please be cautious:

  * All data (server settings, saved game status, etc.) will be **DELETED PERMANATELY** when deleting or updating image
  * You have to use the default server configuration or pass command line arguments by yourself

More Information please refer to [Docker Hub page](https://hub.docker.com/r/jamesits/don-t-starve-together-dedicated-server/).

----------

## Entrypoint Script Arguments

 * `start`: the default `CMD` to start server

## Instructions on Obtaining Server Token

Launch a steam client on a system with GUI, install Don't Starve Together, log in, press `~` button then type `TheNet:GenerateServerToken()` then press enter. You'll find a `server_token.txt` under your client config directory. (See ["References"](#references) section below for more detailed instructions. )

If you use the Docker Compose way, or have `/data/DoNotStarveTogether` mounted to your host machine, **copy the FILE** `server_token.txt` (not its content) to that folder. Also you may set token in `settings.ini`.

In other cases, you can set ENV `DST_SERVER_TOKEN` using the content of your `server_token.txt`. Just open it use any text editor and **copy the CONTENT**. Please note that if `server_token.txt` already exists, it won't be changed by startup script. 

## Modify Settings on a Volume You Don't Have Access To

 1. Create or use a Docker container which have SSH Daemon service (Like [`rastasheep/ubuntu-sshd`](https://registry.hub.docker.com/u/rastasheep/ubuntu-sshd/), but for security issues I recommend using your own image and use pubkey autiencation. )
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
 
## Thanks

 * [DaoCloud](https://daocloud.io)
 * [CodeVS](http://codevs.cn/)
 * [@m13253](https://github.com/m13253)
 * [@MephistoMMM](https://github.com/MephistoMMM)
 * [@wph95](https://github.com/wph95)
 
## License

This software is released under *GNU GENERAL PUBLIC LICENSE Version 2*.

## References

 * [Guides/Don’t Starve Together Dedicated Servers](http://dont-starve-game.wikia.com/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)
 * [[GUIDE] How to setup server dedicated cave on Linux](http://forums.kleientertainment.com/topic/59563-guide-how-to-setup-server-dedicated-cave-on-linux/)
 * [Run dedicated server in Docker](http://forums.kleientertainment.com/topic/60329-run-dedicated-server-in-docker/) (This post was written by me)