#!/bin/bash
set -eu

# set -e error handler.
on_error() {
    echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
    exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

# override server mods folder with user provided one
if [ -d "/data/DoNotStarveTogether/Cluster_1/mods" ]; then
    mount --bind /data/DoNotStarveTogether/Cluster_1/mods /opt/dst_server/mods
fi

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" -o "$1" == "supervisord" ]; then
    # Update game
    steamcmd +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/opt/dst_server" +app_update 343050 +validate +quit
    dontstarve_dedicated_server_nullrenderer -only_update_server_mods
fi

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" ]; then
    # otherwise the game loader will not find some scripts
    cd /opt/dst_server/bin
fi

exec "$@"
