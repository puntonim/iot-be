"""
 ** IoT BE **

The `app` var in this module is the entry point.

This project should be run with:
 - in DEV: make run-dev  # Or: fastapi dev iot_be/main.py
 - in PROD with Monit: sudo monit start gunicorn-iot-be

In DEV the BE is served with FastAPI directly.
In PROD the BE is served with Gunicorn + Uvicorn workers as recommended:
 https://www.uvicorn.org/#running-with-gunicorn
"""

from contextlib import asynccontextmanager

import datetime_utils
from fastapi import FastAPI


@asynccontextmanager
async def lifespan(app: FastAPI):
    # # Docs: https://fastapi.tiangolo.com/advanced/events/
    # # Do stuff before the app starts accepting requests.
    # #
    # # Serve the FE pages with FastAPI in DEV only (not in PROD). That is because
    # #  CORS doesn't work If you open index.html with a browser directly from the file
    # #  system.
    # if settings.ENV == EnvEnum.DEV:
    #     # If this mount was done at module level, then it should have come after all
    #     #  other routes defined (so at the bottom of this file).
    #     app.mount(
    #         "/", StaticFiles(directory=settings.FE_WWW_DIR, html=True), name="static"
    #     )

    yield  # Accept requests.

    # Do stuff before the app shuts down.


app = FastAPI(lifespan=lifespan)


@app.get("/iot/health")
async def health_endpoint():
    now = datetime_utils.now_utc().isoformat()
    return now
