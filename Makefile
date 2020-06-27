default: build

build:
	@echo "Building Hugo Builder container..."
	@docker build -t vadimturkov/hugo-builder .
	@echo "Hugo Builder container built!"
	docker images vadimturkov/hugo-builder

build-website:
	@echo "Building OrgDocs website..."
	@docker run --rm -it -v ${PWD}/orgdocs:/src -u hugo vadimturkov/hugo-builder hugo

serve-website:
	@echo "Serving OrgDocs website..."
	@docker run --rm -it -v ${PWD}/orgdocs:/src -u hugo -p 1313:1313 vadimturkov/hugo-builder hugo server -w --bind=0.0.0.0

lint:
	@echo "Linting Dockerfile..."
	@docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: build build-website serve-website lint
