"""
A very basic settings manager. I chose this because this app requires only a few
 settings and no special features.

A better alternative, in case the app requires more settings and advanced features,
 is Dynaconf.
"""

import sys
from enum import StrEnum
from pathlib import Path

import settings_utils

CONF_DIR = Path(__file__).parent  # iot-be/iot_be/conf
REPO_ROOT_DIR = CONF_DIR.parent.parent  # iot-be


class EnvEnum(StrEnum):
    DEV = "DEV"
    PROD = "PROD"
    PYTEST = "PYTEST"


class settings:
    """
    Usage:
        from conf import settings
        print(setting.APP_NAME)
    """

    CONF_DIR = CONF_DIR
    REPO_ROOT_DIR = REPO_ROOT_DIR

    APP_NAME = "IoT BE"
    IS_TEST = False
    ENV = None

    SERVER_HOST = "127.0.0.1"
    SERVER_PORT = 7777

    GUNICORN_WORKERS = 2

    # TODO it's temporary until we implement an actual DB.
    CSV_DB_PATH = REPO_ROOT_DIR / "db.csv"

    ## TODO delete me?
    # It's the log config for Uvicorn but then I switched to Gunicorn + Uvicorn workers.
    # Src:
    #  - https://github.com/encode/uvicorn/issues/491#issuecomment-2244299487
    #  - https://github.com/encode/uvicorn/blob/b54e24874d3765c21f193e2da4c2ac5e6d3f51fe/uvicorn/config.py#L82
    # UVICORN_LOG_CONFIG = {
    #     "version": 1,
    #     "disable_existing_loggers": False,
    #     "formatters": {
    #         "default": {
    #             "()": "uvicorn.logging.DefaultFormatter",
    #             "fmt": "%(levelprefix)s [%(asctime)s] %(message)s",
    #             "use_colors": None,
    #             "datefmt": "%d-%m-%Y %H:%M:%S",
    #         },
    #         "access": {
    #             "()": "uvicorn.logging.AccessFormatter",
    #             "fmt": '%(levelprefix)s [%(asctime)s] %(client_addr)s - "%(request_line)s" %(status_code)s',
    #             "datefmt": "%d-%m-%Y %H:%M:%S",
    #         },
    #     },
    #     "handlers": {
    #         "default": {
    #             "formatter": "default",
    #             "class": "logging.StreamHandler",
    #             "stream": "ext://sys.stderr",
    #         },
    #         "access": {
    #             "formatter": "access",
    #             "class": "logging.StreamHandler",
    #             "stream": "ext://sys.stdout",
    #         },
    #     },
    #     "loggers": {
    #         "uvicorn": {
    #             "handlers": [
    #                 "default",
    #             ],
    #             "level": "INFO",
    #             "propagate": False,
    #         },
    #         "uvicorn.error": {
    #             "level": "INFO",
    #         },
    #         "uvicorn.access": {
    #             "handlers": [
    #                 "access",
    #             ],
    #             "level": "INFO",
    #             "propagate": False,
    #         },
    #     },
    # }


class _prod_settings:
    ENV = EnvEnum.PROD

    SERVER_HOST = "192.168.1.251"
    SERVER_PORT = 7777

    GUNICORN_ACCESS_LOG_PATH = REPO_ROOT_DIR / "infra" / "logs" / "gunicorn-access.log"
    GUNICORN_ERROR_LOG_PATH = REPO_ROOT_DIR / "infra" / "logs" / "gunicorn-error.log"
    # Mind the path of the PID file is also used in infra/iot-be.monit and
    #  infra/gunicorn-stop.sh.
    # Do not put it in /var/run as you would need root access, so running Gunicorn
    #  as root which would create .pyc files as root (before launching workers as
    #  nimiq). And those files can't be deleted by nimiq in the next deployment (and we
    # #  don't want to run deployments as root).
    GUNICORN_PID_FILE_PATH = REPO_ROOT_DIR / "infra" / "gunicorn.pid"


class _dev_settings:
    ENV = EnvEnum.DEV


class _pytest_settings:
    ENV = EnvEnum.PYTEST
    IS_TEST = True


def _copy_settings(from_settings):
    # Copy all test settings to settings.
    attr_names = [
        attr
        for attr in dir(from_settings)
        if not callable(getattr(from_settings, attr)) and not attr.startswith("__")
    ]
    for attr_name in attr_names:
        attr_value = getattr(from_settings, attr_name)
        global settings
        setattr(settings, attr_name, attr_value)


ENV = settings_utils.get_string_from_env("IOT_BE_ENV", None)
if "pytest" in sys.modules:
    ENV = EnvEnum.PYTEST
if ENV is None:
    ENV = EnvEnum.DEV
if ENV not in tuple(EnvEnum):
    raise RuntimeError(
        f"Env var IOT_BE_ENV invalid ({ENV}), accepted values: DEV, PROD, PYTEST"
    )
if ENV == EnvEnum.PROD:
    _copy_settings(_prod_settings)
elif ENV == EnvEnum.DEV:
    _copy_settings(_dev_settings)
elif ENV == EnvEnum.PYTEST:
    _copy_settings(_pytest_settings)
else:
    raise RuntimeError(f"Cannot determine what settings to use")
