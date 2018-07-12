#!/bin/bash
set -eu

# set -e error handler.
on_error() {
    echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
    exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

# override server mods folder with user provided one
if [ ! -d "/data/DoNotStarveTogether/Cluster_1/mods" ]; then
    mkdir -p /data/DoNotStarveTogether/Cluster_1
    cp -r /opt/dst_server/mods /data/DoNotStarveTogether/Cluster_1
fi
rm -rf /opt/dst_server/mods
ln -s /data/DoNotStarveTogether/Cluster_1/mods /opt/dst_server/mods

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" -o "$1" == "supervisord" ]; then
    # Update game
    steamcmd +runscript /opt/steamcmd_scripts/update_dst_server
    dontstarve_dedicated_server_nullrenderer -only_update_server_mods
fi

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" ]; then
    # otherwise the game loader will not find some scripts
    cd /opt/dst_server/bin
fi

exec "$@"
