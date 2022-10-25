#!/bin/sh

set -x
set -e

export HOST_IP=$(hostname -I | awk '{print $1}')

# Start Snowmirror
#exec /opt/snowmirror/run.sh "$@"

# Start API as SnowMirror user
echo ${USER_UID}
exec setpriv --reuid=${USER_UID} --regid=${USER_GID} --init-groups --inh-caps=$caps /opt/snowmirror/run.sh "$@"