DOCKER = docker run --rm -it  -v $$(pwd):/home/app -w /home/app
ELECTRON = $(DOCKER)  --env="ELECTRON_ENABLE_LOGGING=1" --net=host --env="DISPLAY" --volume="$$HOME/.Xauthority:/root/.Xauthority:rw" "gpenverne/electron"
NODE = $(DOCKER) "gpenverne/electron"
NPM = $(NODE) npm

#GRADLE = docker run --rm -v "$$(pwd)":/home/gradle/ -w /home/gradle gpenverne/android gradle

##
## DEV tools
## -------
##
build: ## Build the docker container and install nodejs dependencies
	docker build -t "gpenverne/electron" docker/electron
	$(ELECTRON) npm install --save-dev electron

install: ## Install dependencies
	$(NPM) install
	$(NODE) mv ./node_modules/angular/angular.min.js ./www/lib/
	$(NODE) mv ./node_modules/bootstrap/dist ./www/lib/bootstrap

package: ## Build a distruable binary
	$(ELECTRON) ./node_modules/.bin/electron-builder
	$(DOCKER) docker/android ./node_modules/.bin/cordova build

android: ## Add a cordova android platform
	docker build -t "gpenverne/android" docker/android
	$(DOCKER) docker/android ./node_modules/.bin/cordova platform add android

gui: ## Launch the GUI using docker
	$(ELECTRON) npm run gui

.DEFAULT_GOAL := help
help: Makefile
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
