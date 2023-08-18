#!/bin/sh

set -x
set -e
echo ${USER_UID}
echo ${USER_GID}

chown ${USER_UID}:${USER_GID} -R ${SNOWMIRROR_DIR}

cap_prefix="-cap_"
caps="$cap_prefix$(seq -s ",$cap_prefix" 0 $(cat /proc/sys/kernel/cap_last_cap))"

export HOST_IP=$(hostname -I | awk '{print $1}')

#exec /opt/snowmirror/run.sh "$@"

# Start as SnowMirror user
echo ${USER_UID}
cd /opt/snowmirror
exec setpriv --reuid=${USER_UID} --regid=${USER_GID} --init-groups --inh-caps=$caps /opt/snowmirror/run.sh "$@"
