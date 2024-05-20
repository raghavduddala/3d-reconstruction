SHELL := /bin/bash

PACKAGE=camera-docker-image
VERSION:=0.0.1
REPO:=ghcr.io/raghavduddala
TAG:=$(REPO)/${PACKAGE}:${VERSION}
WORKSPACE=/opt/code
XSOCK := /tmp/.X11-unix


.PHONY: help
help: ## Show help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: version
version: ## Print the package version
	@echo $(VERSION)

.PHONY: tag
tag: ## print the image tag
	@echo $(TAG)

# X11 - UNIX SOCKET for network over the container
# XAUTH - authorizing other users to run graphical applications 
# CUDA Development
.PHONY: cuda-dev
cuda-dev: ## runs the env with the gpus and cuda runtime 
	@xhost +local:root
	@docker run --rm -it \
		--device  /dev:/dev \
		--env="DISPLAY" \
		--env="QT_X11_NO_MITSHM=1" \
		--env="TERM=xterm-256color" \
		--gpus all \
		--mount="type=bind,source="/tmp",target=/tmp:rw" \
		--privileged \
		--network host \
		--volume="$(HOME)/.Xauthority:/root/.Xauthority:rw" \
		--volume $(PWD):/workspace/ \
		--volume $(XSOCK):$(XSOCK) \
		--runtime nvidia \
		--name ${PACKAGE} \
		${TAG} \
		/bin/bash
	@xhost -local:root

.PHONY: shell
shell: ## get shell into running container
	docker exec -it ${PACKAGE} \
		/bin/bash

.PHONY: image
image: ## builds the container image
	@DOCKER_BUILDKIT=1 docker build \
		--progress plain \
		--build-arg WORKSPACE=${WORKSPACE} \
		--tag $(TAG) \
		.

.PHONY: new-image
new-image: ## builds the container image without cache
	@DOCKER_BUILDKIT=1 docker build \
		--pull \
		--no-cache \
		--progress plain \
		--build-arg WORKSPACE=${WORKSPACE} \
		--tag $(TAG) \
		.
