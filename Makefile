default: build 

build:
	@echo "Building Hugo Builder container..."
	@docker build \
		--build-arg CREATE_DATE=`date -u +'%Y-%m-%dT%H:%M:%SZ'` \
    --build-arg REVISION=`git rev-parse HEAD` \
    --build-arg BUILD_VERSION=1.0.0 \
		-t vadimturkov/hugo-builder .
	@echo "Hugo Builder container built!"
	@docker images vadimturkov/hugo-builder

lint:
	@echo "Linting the Hugo Builder container..."
	@docker run --rm -i hadolint/hadolint:v1.18.0 hadolint --ignore DL3018 - < Dockerfile
	@echo "Linting completed!"

check-policies:
	@echo "Checking FinShare Container policies..."
	@docker run -it --rm --mount type=bind,src=${PWD},dst=/root projectatomic/dockerfile-lint \
		dockerfile_lint -r policies/all_policy_rules.yml
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
	@echo "\nmaintainer: \c"
	@docker inspect -f '{{index .Config.Labels "maintainer"}}' hugo_server
	@echo "create_date: \c"
	@docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.create_date" }}' hugo_server
	@echo "title: \c"
	@docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.title" }}' hugo_server
	@echo "source: \c"
	@docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.source" }}' hugo_server
	@echo "revision: \c"
	@docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.revision" }}' hugo_server
	@echo "version: \c"
	@docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.version" }}' hugo_server
	@echo "licenses: \c"
	@docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.licenses" }}' hugo_server
	@echo "hugo_version: \c"
	@docker inspect -f '{{ index .Config.Labels "hugo_version"}}' hugo_server
	@echo "\nLabels inspected!"

clair-scan:
	@echo "Scanning the Hugo Builder Container Image..."
	@docker network create clair-scanning > /dev/null
	@docker run -d --name clair-db -p 5432:5432 --net=clair-scanning arminc/clair-db:latest > /dev/null
	@docker run -d --name clair -p 6060:6060 \
		--net=clair-scanning --link clair-db:postgres arminc/clair-local-scan:latest > /dev/null
	@docker run --name=scanner --net=clair-scanning --link=clair:clair \
		-v '/var/run/docker.sock:/var/run/docker.sock' \
		objectiflibre/clair-scanner --clair="http://clair:6060" --ip="scanner" vadimturkov/hugo-builder || true
	@docker container rm -f clair clair-db scanner > /dev/null
	@docker network rm clair-scanning > /dev/null
	@echo "Scan of the Hugo Builder Container completed!"

bom:
	@echo "Creating Bill of Materials..."
	@sh ./scripts/build_ternd.sh
	@docker run --rm --privileged \
  	-v /var/run/docker.sock:/var/run/docker.sock \
    --mount type=bind,source=${PWD}/tmp/,target=/hostmount \
    ternd -q report -f spdxtagvalue -i vadimturkov/hugo-builder:latest > bom.spdx
	@echo "Bill of Materials created!"

clean:
	@rm -rf tmp/
	@docker image prune -f > /dev/null
	@docker container prune -f	> /dev/null
	@docker volume prune -f > /dev/null

.PHONY: 
	build 
	lint 
	check-policies
	build-site 
	start-server 
	stop-server 
	health-check 
	inspect-labels 
	clair-scan
	bom
	clean
