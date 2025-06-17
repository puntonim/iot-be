**IoT BACKEND**
===============

An IoT Backend, with Python and FastAPI.


Usage
=====

---

IoT BE api:
 - http://192.168.1.251:7777/iot/health
 - http://192.168.1.251:7777/docs

Monit: http://192.168.1.251:2812/ (password in Keepass).


Infra
=====

---

Development env
---------------
The app is served with FastAPI directly.

Production env
--------------
Deployed to a Raspberry Pi 2 model B in LAN 192.168.1.251.
With OS Alpine Linux 3.22.

The app is served with **Gunicorn** + Uvicorn workers as recommended:
 https://www.uvicorn.org/#running-with-gunicorn
Available at:
 - http://192.168.1.251:7777/iot/health
 - http://192.168.1.251:7777/docs
To know how to use Gunicorn, see: [gunicorn-conf.py](./infra/gunicorn-conf.py)

**Monit** is used to monitor Gunicorn: http://192.168.1.251:2812/ (password in Keepass).
Creds are defined in `/etc/monitrc`.
To know how to use Monit, see: [iot-be.monit](./infra/iot-be.monit)


Monit is a service managed by OpenRC, which is Alpine's init system.
```sh
$ sudo rc-service monit status  # Or start, stop, restart.
```


Development setup
=================

---

1 - System requirements
----------------------

**Python 3.13**\
The target is Python 3.13 as it is the latest atm.\
Install it with pyenv:
```sh
$ pyenv install -l  # List all available versions.
$ pyenv install 3.13.1
```

**Poetry**\
Pipenv is used to manage requirements (and virtual environments).\
Read more about Poetry [here](https://python-poetry.org/). \
Follow the [install instructions](https://python-poetry.org/docs/#osx--linux--bashonwindows-install-instructions).

**Pre-commit**\
Pre-commit is used to format the code with black before each git commit:
```sh
$ pip install --user pre-commit
# On macOS you can also:
$ brew install pre-commit
```

2 - Virtual environment and requirements
----------------------------------------

Create a virtual environment and install all deps with one Make command:
```sh
$ make poetry-create-env
# Or to recreate:
$ make poetry-destroy-and-recreate-env
# Then you can activate the virtual env with:
$ eval $(poetry env activate)
# And later deactivate the virtual env with:
$ deactivate
```

Without using Makefile the full process is:
```sh
# Activate the Python version for the current project:
$ pyenv local 3.13.1  # It creates `.python-version`, to be git-ignored.
$ pyenv which python
~/.pyenv/versions/3.13.1/bin/python

# Now create a venv with poetry:
$ poetry env use ~/.pyenv/versions/3.13.1/bin/python
# Now you can open a shell and/or install:
$ eval $(poetry env activate)
# And finally, install all requirements:
$ poetry install
# And later deactivate the virtual env with:
$ deactivate
```

To add a new requirement:
```sh
$ poetry add requests
$ poetry add pytest --dev  # Dev only.
$ poetry add requests[security,socks]  # With extras.
$ poetry add git+https://github.com/puntonim/sport-monorepo#subdirectory=libs/strava-client  # From git.
$ poetry add "git+https://github.com/puntonim/sport-monorepo#subdirectory=libs/strava-client[aws-parameter-store]"  # From git with extras.
```

3 - Pre-commit
--------------

```sh
$ pre-commit install
```


Deployment
==========

---

To deploy to the Raspberry at 192.168.1.251 from LAN:
```sh
$ make deploy
```
Then choose if rebuilding the remote virtual env (and install reqs) or not.
Sometimes this can take long minutes.
If you did not edit reqs (so the file poetry.lock has not changed) then you don't need
 to rebuild the virtual env.


Copyright
=========

---

Copyright puntonim (https://github.com/puntonim). No License.
