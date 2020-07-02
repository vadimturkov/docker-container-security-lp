default: build hadolint dockerfile-lint

build:
	@echo "Building Hugo Builder container..."
	@docker build -t vadimturkov/hugo-builder .
	@echo "Hugo Builder container built!"
	@docker images vadimturkov/hugo-builder

hadolint:
	@echo "Linting Dockerfile by hadolint..."
	@docker run --rm -i hadolint/hadolint:v1.18.0 hadolint --ignore DL3018 - < Dockerfile
	@echo "Linting completed!"

dockerfile-lint:
	@echo "Linting Dockerfile by dockerfile_lint..."
	@docker run -it --rm --mount type=bind,src=${PWD},dst=/root projectatomic/dockerfile-lint \
		dockerfile_lint -r policies/all_rules.yml
	@echo "Linting completed!"

build-site:
	@echo "Building the OrgDocs site..."
	@docker run --rm -it --mount type=bind,src=${PWD}/orgdocs,dst=/src -u hugo vadimturkov/hugo-builder hugo
	@echo "OrgDocs website built!"

start-server:
	@echo "Serving the OrgDocs site..."
	@docker run --rm -itd --name hugo_server --mount type=bind,src=${PWD}/orgdocs,dst=/src \
		-u hugo -p 1313:1313 vadimturkov/hugo-builder hugo server -w --bind=0.0.0.0
	@echo "OrgDocs site being served!"
	@docker ps -f name=hugo_server

stop-server:
	@echo "Stopping the OrgDocs site..."
	@docker stop hugo_server
	@echo "OrgDocs site stopped!"

health-check:
	@echo "Checking the health of the Hugo server..."
	@docker inspect -f '{{json .State.Health}}' hugo_server

inspect-labels:
	@echo "Inspecting container labels..."
	@echo "Maintainer: \c"
	@docker inspect -f '{{index .Config.Labels "maintainer"}}' hugo_server
	@echo "Labels inspected!"

.PHONY: build hadolint dockerfile-lint build-site start-server stop-server health-check inspect-labels
