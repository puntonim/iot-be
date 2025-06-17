PYTHON_VERSION := "3.13"


.PHONY: default
default: test ;


.PHONY : poetry-create-env
poetry-create-env:
	pyenv local $(PYTHON_VERSION) # It creates `.python-version`, to be git-ignored.
	poetry env use $$(pyenv which python) # It creates the env via pyenv.
	poetry install


.PHONY : poetry-destroy-env
poetry-destroy-env:
	rm -f poetry.lock
	@echo "Removing: $$(poetry run which python | tail -n 1)"
	poetry env remove $$(poetry run which python | tail -n 1)


.PHONY : poetry-destroy-and-recreate-env
poetry-destroy-and-recreate-env: poetry-destroy-env poetry-create-env


.PHONY : pyclean
pyclean:
	find . -name *.pyc -delete
	rm -rf *.egg-info build
	rm -rf coverage.xml .coverage
	find . -name .pytest_cache -type d -exec rm -rf "{}" +
	find . -name __pycache__ -type d -exec rm -rf "{}" +	


.PHONY : clean
clean: pyclean
	rm -rf build
	rm -rf dist


.PHONY : pip-clean
pip-clean:
	#rm -rf ~/Library/Caches/pip  # macOS.
	#rm -rf ~/.cache/pip  # linux.
	rm -rf $$(pip cache dir)  # Cross platform.


.PHONY : pip-uninstall-all
pip-uninstall-all:
	pip freeze | pip uninstall -y -r /dev/stdin


.PHONY : run-dev
run-dev:
	fastapi dev iot_be/main.py


.PHONY : test
test:
	poetry run pytest -s tests/ -v -n auto --durations=25


.PHONY : format
format:
	isort .
	black .


.PHONY : format-check
format-check:
	isort --check-only .
	black --check .


.PHONY : deploy
deploy:
	@echo
	@echo "$$(tput bold)$$(tput setab 7)  ** DEPLOYING IoT-BE TO 192.168.1.251 **  $$(tput sgr0)"
	@echo
	@echo "$$(tput sitm)$$(tput setaf 11)If you edited reqs (so the file poetry.lock has changed) then you need to rebuild the virtual env$$(tput sgr0)"
	@/bin/echo -n "$$(tput setab 11)Rebuild the remote virtual env and install reqs? [y/N] $$(tput sgr0)"
	@read line; \
	if [ "$$line" == "" ] || [ "$$line" == "N" ] || [ "$$line" == "n" ] ; \
	then echo; $(MAKE) _deploy-using-existing-venv ; \
	else echo; $(MAKE) _deploy-and-rebuild-venv ; \
	fi


.PHONY : _deploy-using-existing-venv
_deploy-using-existing-venv:
	@echo "$$(tput smul)>> Deploying using the $$(tput smso)EXISTING venv$$(tput rmso) to 192.168.1.251...$$(tput sgr0)"
	@echo
	@$(MAKE) _build
	@echo
	@$(MAKE) _upload

	@echo 
	@echo "$$(tput smul)>> Unzipping deploy.zip and restarting uvicorn in 192.168.1.251 in /home/nimiq/workspace/iot-be...$$(tput sgr0)"
	@ssh nimiq@192.168.1.251 ' \
		source /home/nimiq/.profile && \
		cd /home/nimiq/workspace/ && \
		rm -rf .deploy && \
		echo Unzipping deploy.zip... && \
		unzip deploy.zip && \
		rm -rf deploy.zip && \
		\
		NEW_DIR_NAME="iot-be-$$(date -Is | tr : -)" && \
		echo Creating new dir /home/nimiq/workspace/$${NEW_DIR_NAME}... && \
		mkdir /home/nimiq/workspace/$${NEW_DIR_NAME} && \
		mkdir /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		\
		echo Copying .venv/*, infra/logs/*, infra/*.pid from /home/nimiq/workspace/iot-be to $${NEW_DIR_NAME}... && \
		cd /home/nimiq/workspace/iot-be && \
		cp -R .venv /home/nimiq/workspace/$${NEW_DIR_NAME} && \
		cp -R infra/logs /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		cp -R infra/*.pid /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		\
		echo Moving all deployment files from .deploy to /home/nimiq/workspace/$${NEW_DIR_NAME}... && \
		cd /home/nimiq/workspace/.deploy/iot-be && \
		ls -A | grep -v .venv | grep -v infra | xargs -I XXX mv XXX /home/nimiq/workspace/$${NEW_DIR_NAME} && \
		ls -A infra | grep -v logs | grep -v .pid | xargs -I XXX mv infra/XXX /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		\
		echo Cleaning up /home/nimiq/workspace/.deploy... && \
		rm -rf /home/nimiq/workspace/.deploy && \
		\
		echo Updating symlink /home/nimiq/workspace/iot-be to point to $${NEW_DIR_NAME}... && \
		rm -rf /home/nimiq/workspace/iot-be && \
		ln -s /home/nimiq/workspace/$${NEW_DIR_NAME} /home/nimiq/workspace/iot-be && \
		\
		echo Deleting older deployment dirs and keeping only the most recent 10... && \
		cd /home/nimiq/workspace && \
		ls -d */ | grep -E "^iot-be-[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}\+[0-9:]{5}/?$$" | sort -r | tail -n +11 | xargs -I XXX rm -rf XXX'
	@echo

	@$(MAKE) _restart_uvicorn

	@echo
	@echo "$$(tput bold)$$(tput setab 10)DONE!!$$(tput sgr0)"


.PHONY : _deploy-and-rebuild-venv
_deploy-and-rebuild-venv:
	@echo "$$(tput smul)>> Deploying creating a $$(tput smso)NEW venv$$(tput rmso) to 192.168.1.251...$$(tput sgr0)"
	@$(MAKE) _build
	@echo
	@$(MAKE) _upload

	@echo 
	@echo "$$(tput smul)>> Unzipping deploy.zip and restarting uvicorn in 192.168.1.251 in /home/nimiq/workspace/iot-be...$$(tput sgr0)"
	@ssh nimiq@192.168.1.251 ' \
		source /home/nimiq/.profile && \
		cd /home/nimiq/workspace/ && \
		rm -rf .deploy && \
		echo Unzipping deploy.zip... && \
		unzip deploy.zip && \
		rm -rf deploy.zip && \
		\
		NEW_DIR_NAME="iot-be-$$(date -Is | tr : -)" && \
		echo Creating new dir /home/nimiq/workspace/$${NEW_DIR_NAME}... && \
		mkdir /home/nimiq/workspace/$${NEW_DIR_NAME} && \
		mkdir /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		\
		echo Copying infra/logs/*, infra/*.pid from /home/nimiq/workspace/iot-be to $${NEW_DIR_NAME}... && \
		cd /home/nimiq/workspace/iot-be && \
		cp -R infra/logs /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		cp -R infra/*.pid /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		\
		echo Moving all deployment files from .deploy to /home/nimiq/workspace/$${NEW_DIR_NAME}... && \
		cd /home/nimiq/workspace/.deploy/iot-be && \
		ls -A | grep -v .venv | grep -v infra | xargs -I XXX mv XXX /home/nimiq/workspace/$${NEW_DIR_NAME} && \
		ls -A infra | grep -v logs | grep -v .pid | xargs -I XXX mv infra/XXX /home/nimiq/workspace/$${NEW_DIR_NAME}/infra && \
		\
		echo Cleaning up /home/nimiq/workspace/.deploy... && \
		rm -rf /home/nimiq/workspace/.deploy && \
		\
		echo Building the new venv in /home/nimiq/workspace/iot-be/.venv... && \
		echo Hack: the new venv should be built in the REAL path /home/nimiq/workspace/iot-be, and not a symlink, so we can copy it over when deploying without rebuilding the venv... && \
		rm -rf /home/nimiq/workspace/iot-be && \
		mv /home/nimiq/workspace/$${NEW_DIR_NAME} /home/nimiq/workspace/iot-be && \
		cd /home/nimiq/workspace/iot-be && \
		POETRY_VIRTUALENVS_IN_PROJECT=true poetry env use $$(pyenv which python) && \
		poetry install && \
		mv /home/nimiq/workspace/iot-be /home/nimiq/workspace/$${NEW_DIR_NAME} && \
		\
		echo Updating symlink /home/nimiq/workspace/iot-be to point to $${NEW_DIR_NAME}... && \
		rm -rf /home/nimiq/workspace/iot-be && \
		ln -s /home/nimiq/workspace/$${NEW_DIR_NAME} /home/nimiq/workspace/iot-be && \
		\
		echo Deleting older deployment dirs and keeping only the most recent 10... && \
		cd /home/nimiq/workspace && \
		ls -d */ | grep -E "^iot-be-[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}\+[0-9:]{5}/?$$" | sort -r | tail -n +11 | xargs -I XXX rm -rf XXX'
	@echo

	@$(MAKE) _restart_uvicorn

	@echo
	@echo "$$(tput bold)$$(tput setab 10)DONE!!$$(tput sgr0)"


.PHONY : _build
_build:
	@echo "$$(tput smul)>> Creating .deploy dir...$$(tput sgr0)"
	@rm -rf .deploy
	@mkdir .deploy

	@echo 
	@echo "$$(tput smul)>> Copying all non git-ignored files to .deploy...$$(tput sgr0)"
	@cp -R ../iot-be .deploy
	@for file in $$(git status --ignored --porcelain | grep '!!' | cut -c 4-) ; do \
		rm -rf .deploy/iot-be/$${file}; \
	done
	@rm -rf .deploy/iot-be/.git

	@echo 
	@echo "$$(tput smul)>> Zipping the dir .deploy/src...$$(tput sgr0)"
	@zip -r .deploy/deploy.zip .deploy/iot-be


.PHONY : _upload
_upload:
	@echo "$$(tput smul)>> Upload .deploy/deploy.zip to 192.168.1.251 in /home/nimiq/workspace/deploy.zip...$$(tput sgr0)"
	@scp .deploy/deploy.zip nimiq@192.168.1.251:/home/nimiq/workspace/deploy.zip

	@echo 
	@echo "$$(tput smul)>> Cleanup local .deploy dir...$$(tput sgr0)"
	@rm -rf .deploy


.PHONY : _restart_uvicorn
_restart_uvicorn:
	@echo "$$(tput smul)Restarting uvicorn in 192.168.1.251...$$(tput sgr0)"
	@ssh nimiq@192.168.1.251 '\
		source /home/nimiq/.profile && \
		sudo monit restart gunicorn-iot-be'
		@ # In order to run monit with no sudo I had to add this to visudo:
		@ #  nimiq ALL=NOPASSWD: /sbin/reboot,/sbin/poweroff,/usr/bin/monit
