#!/bin/bash -e

##set -e error handler.
on_error() {
  echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
  exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

if [ "$1" -e "dst-server" ]; then
    shift
    # Update game
    /usr/local/src/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/usr/local/src/dst_server" +app_update 343050 +validate +quit
    dst-server -only_update_server_mods
    
    echo "Checking server token..."
    if [ ! -f /data/dst/server_token.txt ]; then
        printf '%s\0' "$DST_SERVER_TOKEN" > /data/dst/server_token.txt
    fi
    
    echo "Applying server mod settings..."
    if [ -f /data/dst/dedicated_server_mods_setup.lua ]; then
        cp /data/dst/dedicated_server_mods_setup.lua /usr/local/src/dst_server/mods/
    else
        cp /usr/local/src/dst_server/mods/dedicated_server_mods_setup.lua /data/dst/
    fi
    
    echo "Applying user settings..."
    mkdir -p /data/dst/save/
    copy /data/dst/*list.txt /data/dst/save/ || true
fi

exec "$@"
