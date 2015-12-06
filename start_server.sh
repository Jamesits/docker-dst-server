#!/usr/bin/env bash
set -e

if [ "$1" = 'dst_server' ]; then
    mkdir -p $DST_DATA_DIR/DoNotStarveTogether
    if [ ! -f $DST_DATA_DIR/DoNotStarveTogether/server_token.txt ]; then
        echo $DST_SERVER_TOKEN > $DST_DATA_DIR/DoNotStarveTogether/server_token.txt
    fi
    
    cd $DST_INSTALLATION_DIR/bin
    exec ./dontstarve_dedicated_server_nullrenderer -port $PORT -persistent_storage_root $DST_DATA_DIR "$@"
fi

exec "$@"