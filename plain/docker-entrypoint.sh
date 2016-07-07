#!/bin/bash
set -e

##set -e error handler.
on_error() {
  echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
  exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

if [ "$1" == "dst-server" ]; then
    # Copy default config
    cp -rn /data/empty/* /data/dst
    cp -rn /data/default/* /data/dst
    
    # Apply mods list
    touch /data/dst/dedicated_server_mods_setup.lua
    ln -s /data/dst/dedicated_server_mods_setup.lua /usr/local/src/dst_server/mods/

    # Update game
    /usr/local/src/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "/usr/local/src/dst_server" +app_update 343050 +validate +quit
    dst-server -only_update_server_mods
fi

exec "$@"
