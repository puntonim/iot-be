- check all possible configs for gunicorn, for instance worker max requests

- rotating file handler in prod for gunicron logs (with python or logrotate)
- logs to include date and time, but there is a BUG: configuring the log format for Gunicorn 
  does not work, and the issue is with Uvicorn, see:
  https://github.com/encode/uvicorn/issues/527
  https://github.com/benoitc/gunicorn/issues/2404

