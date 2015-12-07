#!/usr/bin/env bash
set -e

if [ "$1" = 'start' ]; then
    mkdir -p $DST_DATA_DIR/DoNotStarveTogether
    if [ ! -f $DST_DATA_DIR/DoNotStarveTogether/server_token.txt ]; then
        printf "%s\0" $DST_SERVER_TOKEN > $DST_DATA_DIR/DoNotStarveTogether/server_token.txt
    fi
    
    cd $DST_INSTALLATION_DIR/bin
    exec ./dontstarve_dedicated_server_nullrenderer -port $DST_PORT -persistent_storage_root $DST_DATA_DIR "$@"
fi

if [ "$1" = 'update' ]; then
    exec $STEAMCMD_INSTALLATION_DIR/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $DST_INSTALLATION_DIR +app_update 343050 validate +quit
    cd $DST_INSTALLATION_DIR/bin
    exec ./dontstarve_dedicated_server_nullrenderer -only_update_server_mods
fi

exec "$@"