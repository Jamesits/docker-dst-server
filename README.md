# Don't Starve Together Dedicated Server Docker Image

They write their server setup instructions like sh*t, so we made this Docker image to simplify things.

Please read the whole document before putting your hands on your server. 

[![Build Status](https://dev.azure.com/nekomimiswitch/General/_apis/build/status/docker-dst-server?branchName=master)](https://dev.azure.com/nekomimiswitch/General/_build/latest?definitionId=80&branchName=master)

----------

## Versioning

The DST server code changes a lot. We offer multiple variants (tags) on [Docker Hub](https://hub.docker.com/r/jamesits/dst-server/):

* `latest` or `vanilla` are less frequently updated images, recommended for day-to-day use
* `nightly` is a nightly built image, so it (hopefully) comes with the latest server code
* `steamcmd-rebase` works the same way as `latest` but is based on [`cm2network/steamcmd:root`](https://hub.docker.com/r/cm2network/steamcmd)

All variants except `nightly` also have a `-slim` tagged version which does not come with DST server pre-installed; required files will be downloaded every time the container is launched. The `-slim` versions cannot be launched offline.

## Running

### Prerequisites

 * Linux x86_64 and runs Docker (18.05.0-ce or later).
 * You may need a public IP to make your server accessable from Internet. 
 * You need 4 UDP ports exposed to the public network. (See FAQ for details.)
 * CPU: 1 core is somewhat enough for a small-scale server (but don't try 60 ticks, start from 15 or 30).
 * Memory: We recommend reserving 1GiB Memory for the server, plus 60MiB per active user.
 * Disk size: the Docker image takes 1.5GiB, and you need at least another 5MiB for maps, configs and logs. 4GiB available disk space is recommended.

### Start server

Let's assume you are saving your server config and status to `${HOME}/.klei/DoNotStarveTogether`. (This is the default location when it is running outside Docker, so we'll use this as an example. If you want to save it to other location, just mount that directory read-write to the /data folder of the container.)

Start server:

```shell
docker run -v ${HOME}/.klei/DoNotStarveTogether:/data -p 10999-11000:10999-11000/udp -p 12346-12347:12346-12347/udp -e "DST_SERVER_ARCH=amd64" -it jamesits/dst-server:latest
```

If you use `docker-compose`, an [example config](https://github.com/Jamesits/docker-dst-server/blob/master/docker-compose.yml) is provided.

### Stop server

Just press `Ctrl+C` and wait a little while to let itself spin down. (If the server is saving data, don't press ^C twice to force kill the server.)

To programmatically shut down the server, send a SIGINT to the `supervisord` process. 

Note: the server may take up to ~5min to save map and fully shut down.
 
## Server Configuration

If you don't already have a set of server config in your data directory, we will generate one for you. Start server once using the command above, and you will see:
```
Creating default server config...
Please fill in `DoNotStarveTogether/Cluster_1/cluster_token.txt` with your cluster token and restart server!
```

To generate a cluster token (as of 2019-11-02):

1. Open a genuine copy of Don't Starve Together client and log in
2. Click "Play" to go to the main menu
3. click "account" button on the bottom left of the main menu
4. In the popup browser, click "GAMES" on the top nav bar
5. Click "Don't Starve Toegther Servers" button on the top right
6. Scroll down to "ADD NEW SERVER" section, fill in a server name (it is not important), and copy the generated token

The token looks like `pds-g^aaaaaaaaa-q^jaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=`. Then either set `DST_CLUSTER_TOKEN` environment variable during `docker run`, or paste the token into `your_data_directory/DoNotStarveTogether/Cluster_1/cluster_token.txt`.

If you need to add mods, change world generation config, etc., please do it now. Don't forget to edit `your_data_directory/DoNotStarveTogether/Cluster_1/cluster.ini` and get your server an unique name!

After you finish this, re-run start server command, and the server should be running.

## Build Docker image locally

(In most cases you don't need this; just pull the prebuilt image from Docker Hub.)

```shell
git clone https://github.com/Jamesits/docker-dst-server.git docker-dst-server
cd docker-dst-server
docker build . -t dst-server:latest
```

There are some arguments you can set via `--build-arg`:

* `BASE_IMAGE`: the `FROM` image (recent Debian or Ubuntu based images are supported)
* `STEAMCMD_PATH`: where is `steamcmd.sh` in the base image
* `DST_DOWNLOAD`: set to `1` to embed DST server into the image
* `DST_USER`: the user to run server as (inside container)
* `DST_GROUP`: the group to run server as (inside container)


## Known Issues

 * On Docker environment which doesn't support UDP port forwarding, LAN only server cannot be used. (Still you can enable Steam punchthrough and search for your server in `Online` catalog. )
 * Docker IPv6 support is another sh\*t and we currently don't have any idea on it. Help and advices are always welcomed. (see [#7](https://github.com/Jamesits/docker-dst-server/issues/7).)

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

#### Error! App '343050' state is 0x602 after update job.

Usually there is a file system permission issue preventing steamcmd from writing to your game installation directory.

#### Client high latency or lagging

Possible causes:

* High packet drop rate
* High server tick rate with low-performance clients (e.g. notebook users with tick rate 60) 

#### How can I copy local data to server?

Local data is stored in `<User Documents>\Klei\DoNotStarveTogether\<Random Number>`.

There are two situations:
1. Local data has cave enabled.\
Just copy the `Cluster_X` to server and rename to `Cluster_1`, then it should work.
2. Local data has no cave.\
Copy everything in `client_save` except `session` and `Cluster_X/save/session` to server `Cluster_1/save`.\
If your local data is not in slot 1, you also have to modify `saveindex` because the server recognize only the first slot.\
The server will create a cave for you. If you don't want the cave, you have to modify `supervisor.conf` to disable cave server.

#### How can I enable mods after copy local data to server?

Open `Cluster_X/Master/modoverrides.lua` and you will see something like `workshop-XXXXX` where `XXXXX` is a number.\
Open `Cluster_1/mods/dedicated_server_mods_setup.lua` on server and write `ServerModSetup("XXXXX")`.

## Maintainer

 * [James Swineson](https://swineson.me)
 
## Thanks

 * [Mingye Wang](https://github.com/Arthur2e5)
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
