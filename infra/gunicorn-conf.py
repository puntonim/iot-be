"""
** Gunicorn CONFIG **

Docs: https://docs.gunicorn.org/en/latest/settings.html

With Monit
----------
Gunicorn should be run and monitored with Monit.
The monit file is iot-be/infra/iot-be.monit and it is symlinked in /etc/monit.d.

Start and monitor Gunicorn with **Monit**:
 $ sudo monit start gunicorn-iot-be
Stop and un-monitor Gunicorn with **Monit**:
 $ sudo monit stop gunicorn-iot-be

Without Monit
-------------
Manually start Gunicorn, without Monit:
 $ ~/workspace/iot-be/infra/gunicorn-start.sh
Note: this will also write its PID to infra/gunicorn.pid so Monit will start monitoring it.

Manually stop Gunicorn, without Monit:
 $ sudo rc-service monit stop  # Stop Monit.
 $ ~/workspace/iot-be/infra/gunicorn-stop.sh
Alternative, after stopping Monit:
 $ pkill -f gunicorn
 $ rm -rf /home/nimiq/workspace/iot-be/infra/gunicorn.pid
Later, you should restart Monit and it will take care of starting Gunicorn again:
 $ sudo rc-service monit start
"""

from iot_be.conf import settings

bind = f"{settings.SERVER_HOST}:{settings.SERVER_PORT}"
workers = settings.GUNICORN_WORKERS

# The recommended way to run a FastAPI app in prod is with Gunicorn + Uvicorn:
#  https://www.uvicorn.org/#running-with-gunicorn
worker_class = "uvicorn.workers.UvicornWorker"

pidfile = str(settings.GUNICORN_PID_FILE_PATH.resolve())
daemon = True
chdir = str(settings.REPO_ROOT_DIR.resolve())
user = "nimiq"

accesslog = str(settings.GUNICORN_ACCESS_LOG_PATH.resolve())
errorlog = str(settings.GUNICORN_ERROR_LOG_PATH.resolve())

# TODO Configuring the log format does not work, and the issue is with Uvicorn, see:
# https://github.com/encode/uvicorn/issues/527
# https://github.com/benoitc/gunicorn/issues/2404
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
