#!/bin/bash

set -eo pipefail

HAPROXY="/usr/sbin/haproxy"
CONFD="/usr/local/sbin/confd"
PIDFILE="/var/run/haproxy.pid"
CONFIG_DIR="/opt/etc/haproxy"
CONFIG_FILE="$CONFIG_DIR/haproxy.cfg"
CONFIG_TEMPLATE="/etc/confd/conf.d/haproxy.toml"

[ -n "$ETCD" ] || (echo "[haproxy] ETCD variable is not set... exiting" && exit 1) 

mkdir -p $CONFIG_DIR

echo "[haproxy] booting container. ETCD: $ETCD."

# Try to make initial configuration every 5 seconds until successful
until $CONFD -onetime -node $ETCD -config-file $CONFIG_TEMPLATE; do
    echo "[haproxy] waiting for confd to create initial haproxy configuration."
    sleep 5
done

# Put a continual polling `confd` process into the background to watch
# for changes every 10 seconds
$CONFD -interval 10 -node $ETCD -config-file $CONFIG_TEMPLATE &
echo "[haproxy] confd is now monitoring etcd for changes..."

# Start the Nginx service using the generated config
echo "[haproxy] starting haproxy service..."
$HAPROXY -f $CONFIG_FILE -p $PIDFILE
