# Don't Starve Together Dedicated Server Docker Image

This is the Docker image for DST dedicated server, based on [`debian:latest`](https://hub.docker.com/_/debian/).

## Install Using Docker Compose

Create a folder for storing DST server files, then put a `docker-compose.yml` inside it, paste the following content: 
```yaml
server:
  image: jamesits/don-t-starve-together-dedicated-server:latest
  restart: always
  ports:
  - 10999:10999/udp
  volumes:
  - ./server_config:/data/DoNotStarveTogether
```
Then use `docker-compose up` to bring up the server. 

## Manual Installation

```shell
docker pull jamesits/don-t-starve-together-dedicated-server
```
Note: If you use Docker the VM way (i.e. running the image without `/data/DoNotStarveTogether` mounted to host), please be cautious:
  * all data will be **DELETED PERMANATELY** when deleting or updating image
  * you have to use the default server configuration or pass command line arguments by yourself

More Information please refer to [Docker Hub page](https://hub.docker.com/r/jamesits/don-t-starve-together-dedicated-server/).

## Entrypoint Script Arguments

 * `start`: the default `CMD` to start server
 * `update`: call SteamCMD to update server file, then tell server to update mods (Not fully tested)

## Instructions on Obtaining Server Token

Launch a steam client on a system with GUI, install Don't Starve Together, log in, press `~` button then type `TheNet:GenerateServerToken()` then press enter. You'll find a `server_token.txt` under your client config directory. (See ["References"](#References) section below for more detailed instructions. )

If you use the Docker Compose way, or have `/data/DoNotStarveTogether` mounted to your host machine, **copy the FILE** `server_token.txt` (not its content) to that folder.

In other cases, you can set ENV `DST_SERVER_TOKEN` using the content of your `server_token.txt`. Just open it use any text editor and **copy the CONTENT**. 

## Maintainer

 * [James Swineson](https://swineson.me)
 
## License

This software is released under *GNU GENERAL PUBLIC LICENSE Version 2*.

## References

 * [Guides/Don’t Starve Together Dedicated Servers](http://dont-starve-game.wikia.com/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)
 * [[GUIDE] How to setup server dedicated cave on Linux](http://forums.kleientertainment.com/topic/59563-guide-how-to-setup-server-dedicated-cave-on-linux/)
 