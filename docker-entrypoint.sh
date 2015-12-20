#!/bin/sh -e

# Don't Starve Together Dedicated Server Docker Image
# Copyright (C) 2015 James Swineson
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
Copyright (C) 2015 James Swineson
Copyright (C) 2015 Mingye Wang (Arthur2e5)
This script comes with ABSOLUTELY NO WARRANTY. This is free software, and you 
are welcome to redistribute it under certain conditions;
visit https://github.com/Jamesits/Don-t-Starve-Together-Dedicated-Server/blob/master/LICENSE
for details.

Docker Hub: https://hub.docker.com/r/jamesits/don-t-starve-together-dedicated-server/
Github: https://github.com/Jamesits/Don-t-Starve-Together-Dedicated-Server
"

if [ "$1" = 'start' ]; then
    echo >&2 "Updating server..."
    "$STEAMCMD_INSTALLATION_DIR"/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "$DST_INSTALLATION_DIR" +app_update 343050 validate +quit \
            || { _ret=$?; cat >&2 /root/Steam/logs/stderr.txt; exit $_ret; }
    
    echo >&2 "Checking server token..."
    mkdir -p "$DST_DATA_DIR"/DoNotStarveTogether
    if [ ! -f "$DST_DATA_DIR"/DoNotStarveTogether/server_token.txt ]; then
        printf '%s\0' "$DST_SERVER_TOKEN" > "$DST_DATA_DIR"/DoNotStarveTogether/server_token.txt
    fi
    
    echo >&2 "Checking server mode settings..."
    if [ -f "$DST_DATA_DIR"/DoNotStarveTogether/dedicated_server_mods_setup.lua ]; then
        cp "$DST_DATA_DIR"/DoNotStarveTogether/dedicated_server_mods_setup.lua "$DST_INSTALLATION_DIR"/mods/
    else
        cp "$DST_INSTALLATION_DIR"/mods/dedicated_server_mods_setup.lua "$DST_DATA_DIR"/DoNotStarveTogether/
    fi
    
    echo >&2 "Starting server..."
    cd "$DST_INSTALLATION_DIR"/bin
    exec ./dontstarve_dedicated_server_nullrenderer \
        -port "$DST_PORT" \
        -persistent_storage_root "$DST_DATA_DIR" \
        "$@"
fi

exec "$@"
