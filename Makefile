IMAGE     ?= ghcr.io/fabiocicerchia/security-scanner-toolbox
VERSION   ?= 1.0.0
PLATFORMS ?= linux/amd64,linux/arm64
# Stamped into the -db image. It is the only thing that distinguishes two builds
# of the same tag from each other, since the tool pins are identical by design.
BUILD_DATE ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
BUILD_ARGS = $(shell sed -n 's/^\([A-Z_]*\)=\(.*\)/--build-arg \1=\2/p' versions.env)

.PHONY: build build-db lint test test-db push release release-db help

.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

build: ## Build the image locally
	docker build $(BUILD_ARGS) -t $(IMAGE):$(VERSION) .

build-db: build ## ...and the -db variant, with the vuln databases baked in
	docker build -f Dockerfile.db \
		--build-arg BASE_IMAGE=$(IMAGE):$(VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(IMAGE):$(VERSION)-db .

lint: ## Lint the Dockerfiles and shell scripts
	docker run --rm -i hadolint/hadolint < Dockerfile
	docker run --rm -i hadolint/hadolint < Dockerfile.db
	shellcheck scan-image test.sh test-offline.sh

test: build ## Build, then run the smoke tests
	./test.sh $(IMAGE):$(VERSION)

test-db: build-db ## ...and prove the -db variant scans with the network off
	./test.sh $(IMAGE):$(VERSION)-db
	./test-offline.sh $(IMAGE):$(VERSION)-db

push: build ## Push the tagged image
	docker push $(IMAGE):$(VERSION)

release: ## Multi-arch buildx build and push (version + latest)
	docker buildx build --platform $(PLATFORMS) $(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .

release-db: ## Multi-arch build and push of the -db variant
	docker buildx build --platform $(PLATFORMS) -f Dockerfile.db \
		--build-arg BASE_IMAGE=$(IMAGE):$(VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(IMAGE):$(VERSION)-db -t $(IMAGE):latest-db --push .
