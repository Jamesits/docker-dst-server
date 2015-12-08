#!/usr/bin/env bash
set -e

echo "Don't Starve Together Dedicated Server Docker Image"
echo "By James Swineson"
echo "https://hub.docker.com/r/jamesits/don-t-starve-together-dedicated-server/"

if [ "$1" = 'start' ]; then
    echo "Updating server..."
    $STEAMCMD_INSTALLATION_DIR/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $DST_INSTALLATION_DIR +app_update 343050 validate +quit
    
    echo "Checking server token..."
    mkdir -p $DST_DATA_DIR/DoNotStarveTogether
    if [ ! -f $DST_DATA_DIR/DoNotStarveTogether/server_token.txt ]; then
        printf "%s\0" $DST_SERVER_TOKEN > $DST_DATA_DIR/DoNotStarveTogether/server_token.txt
    fi
    
    echo "Starting server..."
    cd $DST_INSTALLATION_DIR/bin
    exec ./dontstarve_dedicated_server_nullrenderer -port $DST_PORT -persistent_storage_root $DST_DATA_DIR "$@"
fi

exec "$@"