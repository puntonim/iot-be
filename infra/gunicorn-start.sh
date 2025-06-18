#!/usr/bin/env bash

# ** Start Gunicorn for IoT BE in PROD **
#
# Run this script as user nimiq (not root).
# Note: this script is used by Monit.

# CD into the dir where this file is located.
cd "$(dirname "$0")"
# CD into the repo root dir.
cd ..

# Run Gunicorn.
IOT_BE_ENV=PROD .venv/bin/gunicorn --config infra/gunicorn-conf.py iot_be.main:app
