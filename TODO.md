- Make it a monorepo with the code for arduino

- Store data in SQLite with PeeWee
  Then remove all I've writte with "db.csv" in source code and Makefile.

- OAuth2 client credentials
  Vedi qd
  Docs sul password flow: https://fastapi.tiangolo.com/tutorial/security/
  Vedi del codice qui: https://github.com/fastapi/fastapi/discussions/7846
  E qs implementaz: https://medium.com/@ksrivastava.sumit/implement-oauth2-client-credentials-flow-for-microservices-with-fastapi-832b1ba484bb

- check all possible configs for gunicorn, for instance worker max requests

- rotating file handler in prod for gunicron logs (with python or logrotate)
- logs to include date and time, but there is a BUG: configuring the log format for Gunicorn 
  does not work, and the issue is with Uvicorn, see:
  https://github.com/encode/uvicorn/issues/527
  https://github.com/benoitc/gunicorn/issues/2404

- Monit: monitorare altri processi come in https://mmonit.com/monit/img/screenshots/1.png

