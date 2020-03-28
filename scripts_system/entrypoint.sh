#!/bin/bash
set -Eeuo pipefail

# set -e error handler.
on_error() {
    echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
    exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" -o "$1" == "supervisord" ]; then
    # create default server config if there is none
    if [ ! -d "${DST_USER_DATA_PATH}/DoNotStarveTogether" ]; then
        echo "Creating default server config..."
	mkdir -p "${DST_USER_DATA_PATH}"
        cp -r /opt/dst_default_config/* "${DST_USER_DATA_PATH}"
        touch "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt"
    fi

    # override server mods folder with user provided one
    if [ ! -d "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/mods" ]; then
        echo "Creating default mod config..."
        mkdir -p "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1"
        cp -r /opt/dst_server/mods "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1"
    fi
    rm -rf /opt/dst_server/mods
    ln -s "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/mods" /opt/dst_server/mods

    # fill cluster token from environment variable
    if [ ! -z "${DST_CLUSTER_TOKEN:-}" ]; then
	echo "Filling cluster token from environment variable"
	printf "${DST_CLUSTER_TOKEN}" > "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt"
    fi

    # check cluster token
    if [ ! -f "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt" ]; then
        >&2 echo "Done, please fill in \`DoNotStarveTogether/Cluster_1/cluster_token.txt\` with your cluster token and restart server!"
        exit
    else
        if [ -z "$(tail -c 1 "/data/DoNotStarveTogether/Cluster_1/cluster_token.txt")" ]; then
            # the cluster_token.txt needs to be terminated without newline, try to fix
            mv "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt" /tmp/
            tr -d '\n' < /tmp/cluster_token.txt > "${DST_USER_DATA_PATH}/DoNotStarveTogether/Cluster_1/cluster_token.txt"
            rm -f /tmp/cluster_token.txt
        fi
    fi

    # fix permission
    chown -R "${DST_USER}:${DST_GROUP}" "${DST_USER_DATA_PATH}"

    # Update game
    echo "Updating server..."
    steamcmd +runscript /opt/steamcmd_scripts/install_dst_server
    echo "Updating mods..."
    su --login --group "${DST_GROUP}" -c "dontstarve_dedicated_server_nullrenderer -persistent_storage_root \"${DST_USER_DATA_PATH}\" -only_update_server_mods" "${DST_USER}"

    # create unix socks server for supervisor
    touch /var/run/supervisor.sock
fi

exec "$@"
