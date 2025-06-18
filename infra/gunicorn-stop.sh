#!/usr/bin/env bash

# ** Stop Gunicorn for IoT BE in PROD **
#
# Run this script as user nimiq (not root).
# Note: this script is used by Monit.

# CD into the dir where this file is located.
cd "$(dirname "$0")"
# CD into the repo root dir.
cd ..

# Stop Gunicorn.
# Mind the path of the PID file is also used in infra/iot-be.monit and
#  conf/settings_module.py (used in infra/gunicorn-conf.py).
# Do not put it in /var/run as you would need root access, so running Gunicorn
#  as root which would create .pyc files as root (before launching workers as
#  nimiq). And those files can't be deleted by nimiq in the next deployment (and we
# #  don't want to run deployments as root).
( cat infra/gunicorn.pid | xargs -I XXX kill -s SIGTERM XXX ) && rm -rf infra/gunicorn.pid
