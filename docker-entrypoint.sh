#!/bin/sh -e

# Don't Starve Together Dedicated Server Docker Image
# Copyright (C) 2015 James Swineson (Jamesits) <jamesswineson@gmail.com>
# Copyright (C) 2015 Mingye Wang (Arthur2e5) <arthur2e5@aosc.io>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

printf '%s\n' "
Don't Starve Together Dedicated Server Docker Startup Image, 
Copyright (C) 2015 James Swineson (Jamesits)
Copyright (C) 2015 Mingye Wang (Arthur2e5)
This script comes with ABSOLUTELY NO WARRANTY. This is free software, and you 
are welcome to redistribute it under certain conditions;
visit https://github.com/Jamesits/Don-t-Starve-Together-Dedicated-Server/blob/master/LICENSE
for details.

Docker Hub: https://hub.docker.com/r/jamesits/don-t-starve-together-dedicated-server/
Github: https://github.com/Jamesits/Don-t-Starve-Together-Dedicated-Server
"

##set -e error handler.
on_error() {
  echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
  echo "This error is triggered by \`sh -e' in the script; to override it, run `sh "$0"` instead."
  exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

##runs the specified steam cmds.
steam_eval(){
    _ret=0
    #>args.EACH {|cmd| -> steamcmd_args += shell_eval_expd("+#{cmd}")}
    #-array steamcmd_args as new args. inplace.
    for eval_cmd; do
        eval 'set -$- -- "$@" '"+$eval_cmd"
    done
    "$STEAMCMD_INSTALLATION_DIR"/steamcmd.sh \
        +@ShutdownOnFailedCommand 1 \
        +@NoPromptForPassword 1 \
        +login anonymous \
        +force_install_dir "$DST_INSTALLATION_DIR" "$@" +quit || _ret=$?
    cat >&2 /root/Steam/logs/stderr.txt || true
    return $_ret
}

##updates the server.
steam_update_dst(){
    echo >&2 "Updating server..."
    steam_eval 'app_update 343050 validate'
}

##Calls the DST binary in the right dir.
dst_bin(){
    pushd "$DST_INSTALLATION_DIR"/bin
    ./dontstarve_dedicated_server_nullrenderer "$@"
    popd
}

##Execs to the DST binary in the right dir.
exec_dst_bin(){
    cd "$DST_INSTALLATION_DIR"/bin
    exec ./dontstarve_dedicated_server_nullrenderer "$@"
}

##shorthand for a bunch of cp magic
copy(){ cp -a --reflink=auto "$@"; }

case "$1" in
start)
    shift
    steam_update_dst
    echo >&2 "Checking server token..."
    mkdir -p "$DST_DATA_DIR"/DoNotStarveTogether
    if [ ! -f "$DST_DATA_DIR"/DoNotStarveTogether/server_token.txt ]; then
        printf '%s\0' "$DST_SERVER_TOKEN" > "$DST_DATA_DIR"/DoNotStarveTogether/server_token.txt
    fi
    
    echo >&2 "Applying server mod settings..."
    if [ -f "$DST_DATA_DIR"/DoNotStarveTogether/dedicated_server_mods_setup.lua ]; then
        copy "$DST_DATA_DIR"/DoNotStarveTogether/dedicated_server_mods_setup.lua "$DST_INSTALLATION_DIR"/mods/
    else
        copy "$DST_INSTALLATION_DIR"/mods/dedicated_server_mods_setup.lua "$DST_DATA_DIR"/DoNotStarveTogether/
    fi
    
    echo >&2 "Applying user settings..."
    mkdir -p "$DST_DATA_DIR"/DoNotStarveTogether/save/
    copy "$DST_DATA_DIR"/DoNotStarveTogether/*list.txt "$DST_DATA_DIR"/DoNotStarveTogether/save/ || true
    
    echo >&2 "Starting server..."
    exec_dst_bin -port "$DST_PORT" -persistent_storage_root "$DST_DATA_DIR" "$@"
    ;;

reset)
    echo >&2 "Saving user settings..."
    copy "$DST_DATA_DIR"/DoNotStarveTogether/save/*list.txt "$DST_DATA_DIR"/DoNotStarveTogether/ || true
    
    echo >&2 "Deleting saved game..."
    rm -rf "$DST_DATA_DIR"/DoNotStarveTogether/save
    echo >&2 "Saved game deleted successfully."
    ;;

update)
    steam_update_dst    
    echo >&2 "Updating server mods..."
    dst_bin -only_update_server_mods
    echo >&2 "Server updated successfully."
    ;;

*)
    exec "$@"
    ;;
esac
