# Don't Starve Together Dedicated Server Docker Image

They write their server setup instructions like sh*t, so we made this Docker image to simplify things.

Please read the whole document before putting your hands on your server.

----------

## Running

### Prerequisites

 * Linux (4.4.0 tested) and runs Docker (18.05.0-ce tested).
 * You may need a public IP to make your server accessable from Internet. Also latency matters. You need 4 UDP ports exposed to the public network. (See FAQ for details.)
 * CPU: 1 core is somewhat enough for a small-scale server (but don't try 60 ticks, start from 15 or 30).
 * Memory: We recommend reserving 1GiB Memory for the server, plus 60MiB per active user.
 * Disk size: the Docker image takes 1.5GiB, and you need at least another 5MiB for maps, configs and logs. 4GiB available disk space is recommended.

### Start server

Let's assume you are saving your server config and status to `${HOME}/.klei/DoNotStarveTogether`. (This is the default location when it is running outside Docker, so we'll use this as an example. If you want to save it to other location, just mount that directory read-write to the /data folder of the container.)

Start server:

```shell
docker run -v ${HOME}/.klei/DoNotStarveTogether:/data -p 10999-11000:10999-11000/udp -p 12346-12347:12346-12347/udp -it jamesits/dst-server:latest
```

If you use `docker-compose`, an example config is provided.

### Stop server

Just press `Ctrl+C` and wait a little while to let itself spin down. (If the server is saving data, don't press ^C twice to force kill the server.)

To programmatically shut down the server, send a SIGINT to the `supervisord` process. 

Note: the server may take up to ~5min to save map and fully shut down.
 
## Server Configuration

If you don't already have a set of server config in your data directory, we will generate one for you. Start server once using the command above, and you will see:
```
Creating default server config...
Done, please fill in `DoNotStarveTogether/Cluster_1/cluster_token.txt` with your cluster token and restart server!
```

Open a genius copy of Don't Starve Together client, log in, click "account" button on the bottom left of the main menu, and generate a new token from the pop-up web page. Then open `your_data_directory/DoNotStarveTogether/Cluster_1/cluster_token.txt` on your server using any text editor, paste the token, save.

Don't forget to edit `your_data_directory/DoNotStarveTogether/Cluster_1/cluster.ini` and get your server an unique name!

After you finish this, re-run start server command, and the server should be running.

## Build Docker image locally

(In most cases you don't need this; just pull the prebuilt image from Docker Hub.)

```shell
git clone https://github.com/Jamesits/docker-dst-server.git docker-dst-server
cd docker-dst-server
docker build . -t dst-server:latest
```

## Known Issues

 * On Docker environment which doesn't support UDP port forwarding, LAN only server cannot be used. (Still you can enable Steam punchthrough and search for your server in `Online` catalog. )

## FAQ

#### How to update server or mods?

Restart the server. Updates will be downloaded automatically.

#### How to connect to a LAN only server?

Run `c_connect("IP address", port)` or `c_connect("IP address", port, "password")` in client console.

#### How to check if the server is online?

You can try the 3rd party website [Don't Starve Together Server List](https://dstserverlist.appspot.com).

#### What port does this server require?

You need to expose UDP 10999 (master) and 11000 (caves) for client to connect; udp 12346 and 12347 for steam connection. Don't NAT these ports to different port numbers.

The server use another 2 high UDP ports for unknown communication, and UDP 10998 (listen on localhost) for communication between cluster servers.

Here is a `netstat -tulpn` output on our test server:
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
udp        0      0 0.0.0.0:12346           0.0.0.0:*                           54/./dontstarve_ded 
udp        0      0 0.0.0.0:12347           0.0.0.0:*                           53/./dontstarve_ded 
udp        0      0 0.0.0.0:38223           0.0.0.0:*                           53/./dontstarve_ded 
udp        0      0 0.0.0.0:36517           0.0.0.0:*                           54/./dontstarve_ded 
udp        0      0 127.0.0.1:10998         0.0.0.0:*                           54/./dontstarve_ded 
udp        0      0 0.0.0.0:10999           0.0.0.0:*                           54/./dontstarve_ded 
udp        0      0 0.0.0.0:11000           0.0.0.0:*                           53/./dontstarve_ded 
```

#### Error! App '343050' state is 0x202 after update job.

Your disk is full.

----------

## Maintainer

 * [James Swineson](https://swineson.me)
 * [Mingye Wang](https://github.com/Arthur2e5)
 
## Thanks

 * [@MephistoMMM](https://github.com/MephistoMMM)
 * [@m13253](https://github.com/m13253)
 * [@wph95](https://github.com/wph95)
 * [DaoCloud](https://daocloud.io)
 * [CodeVS](http://codevs.cn/)
 * [I Choose Death Too](https://steamcommunity.com/id/ichoosedeathtoo/)
 
## License

    Don't Starve Together Dedicated Server Docker Image
    Copyright (C) 2015-2018 James Swineson (Jamesits) and Mingye Wang (Arthur2e5)

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

 * [How to setup dedicated server with cave on Linux](https://steamcommunity.com/sharedfiles/filedetails/?id=590565473)
 * [How to install,configure and update mods on Dedicated Server](https://steamcommunity.com/sharedfiles/filedetails/?id=591543858)
 * [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD)