#!/bin/bash
set -eu

# set -e error handler.
on_error() {
    echo >&2 "Error on line ${1}${3+: ${3}}; RET ${2}."
    exit $2
}
trap 'on_error ${LINENO} $?' ERR 2>/dev/null || true # some shells don't have ERR trap.

if [ "$1" == "dontstarve_dedicated_server_nullrenderer" -o "$1" == "supervisord" ]; then
    # create default server config if there is none
    if [ ! -d "/data/DoNotStarveTogether" ]; then
        echo "Creating default server config..."
        cp -r /opt/dst_default_config/* /data
        touch /data/DoNotStarveTogether/Cluster_1/cluster_token.txt
        echo "Done, please fill in \`DoNotStarveTogether/Cluster_1/cluster_token.txt\` with your cluster token and restart server!"
        exit
    fi

    # override server mods folder with user provided one
    if [ ! -d "/data/DoNotStarveTogether/Cluster_1/mods" ]; then
        echo "Creating default mod config..."
        mkdir -p /data/DoNotStarveTogether/Cluster_1
        cp -r /opt/dst_server/mods /data/DoNotStarveTogether/Cluster_1
    fi
    rm -rf /opt/dst_server/mods
    ln -s /data/DoNotStarveTogether/Cluster_1/mods /opt/dst_server/mods

    # check cluster token
    if [ ! -f "/data/DoNotStarveTogether/Cluster_1/cluster_token.txt" ]; then
        >&2 echo "cluster_token.txt not found!"
    else
        # the cluster_token.txt needs to be terminated without newline, try to fix
        mv /data/DoNotStarveTogether/Cluster_1/cluster_token.txt /tmp/
        tr -d '\n' < /tmp/cluster_token.txt > /data/DoNotStarveTogether/Cluster_1/cluster_token.txt
        rm -f /tmp/cluster_token.txt
    fi

    # Update game
    echo "Updating server..."
    steamcmd +runscript /opt/steamcmd_scripts/install_dst_server
    echo "Updating mods..."
    dontstarve_dedicated_server_nullrenderer -only_update_server_mods

    # create unix socks server for supervisor
    touch /var/run/supervisor.sock
fi

exec "$@"
