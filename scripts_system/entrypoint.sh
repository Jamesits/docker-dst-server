#!/bin/bash
set -Eeuo pipefail

DIR_MODS_SYS="/opt/dst_server/mods"
DIR_MODS_USER="${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/mods"
FILE_CLUSTER_TOKEN="${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt"

# set -e error handler.
on_error() {
    echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
    exit "$2"
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" ] || [ "$1" == "supervisord" ]; then
    # create a default server config if there is none
    if [ ! -d "${DST_USER_DATA_PATH}/DoNotStarveTogether" ]; then
        echo "Creating default server config..."
	mkdir -p "${DST_USER_DATA_PATH}"
        cp -r /opt/dst_default_config/* "${DST_USER_DATA_PATH}"
        touch "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt"
    fi

    # fill cluster token from environment variable
    if [ ! -z "${DST_CLUSTER_TOKEN:-}" ]; then
	echo "Filling cluster token from environment variable"
	printf "%s" "${DST_CLUSTER_TOKEN}" > "${FILE_CLUSTER_TOKEN}"
    fi

    # check cluster token file format
    if [ ! -f "${FILE_CLUSTER_TOKEN}" ]; then
        >&2 echo "Please fill in \`DoNotStarveTogether/Cluster_1/cluster_token.txt\` with your cluster token and restart server!"
        exit
    else
        if [ -z "$(tail -c 1 "${FILE_CLUSTER_TOKEN}")" ]; then
            # the cluster_token.txt needs to be terminated without newline, try to fix
            mv "${FILE_CLUSTER_TOKEN}" /tmp/cluster_token.txt
            tr -d '\n' < /tmp/cluster_token.txt > "${FILE_CLUSTER_TOKEN}"
            rm -f /tmp/cluster_token.txt
        fi
    fi

    # fix config file permission
    chown -R "${DST_USER}:${DST_GROUP}" "${DST_USER_DATA_PATH}"

    # protect our mods dir
    # if the mods dir is already a symlink, then we temporary remove it to protect it, so that it survives a container restart
    if [[ -L "${DIR_MODS_SYS}" ]]; then
    	rm -f "${DIR_MODS_SYS}"
	cp -r /opt/dst_default_config/DoNotStarveTogether/Cluster_1/mods "${DIR_MODS_SYS}"
    fi

    # Update game
    # note that the update process modifies (resets) the mods folder so we symlink that later
    echo "Updating server..."
    steamcmd +runscript /opt/steamcmd_scripts/install_dst_server

    # if there are no mods config, use the one that comes with the server
    if [ ! -d "${DIR_MODS_USER}" ]; then
        echo "Creating default mod config..."
        mkdir -p "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1"
        cp -r "${DIR_MODS_SYS}" "${DIR_MODS_USER}"
    fi

    # override server mods folder with the user provided one
    rm -rf "${DIR_MODS_SYS}"
    ln -s "${DIR_MODS_USER}" "${DIR_MODS_SYS}"

    # update mods
    echo "Updating mods..."
    su --preserve-environment --group "${DST_GROUP}" -c "dontstarve_dedicated_server_nullrenderer -persistent_storage_root \"${DST_USER_DATA_PATH}\" -ugc_directory \"${DST_USER_DATA_PATH}\"/ugc -only_update_server_mods" "${DST_USER}"

    # remove any existing supervisor socket
    rm -f /var/run/supervisor.sock

    # create the unix socket file for supervisor
    touch /var/run/supervisor.sock
fi

exec "$@"
