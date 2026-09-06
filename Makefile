IMAGE     ?= ghcr.io/fabiocicerchia/security-scanner-toolbox
VERSION   ?= 1.0.0
PLATFORMS ?= linux/amd64,linux/arm64
# Stamped into the -db image. It is the only thing that distinguishes two builds
# of the same tag from each other, since the tool pins are identical by design.
BUILD_DATE ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
BUILD_ARGS = $(shell sed -n 's/^\([A-Z_]*\)=\(.*\)/--build-arg \1=\2/p' versions.env)

# Every verb this repository exposes lives here; `make` on its own prints them.
# FC-GEN-057: the same eight verbs in every repo, each either wired or a
# declared no-op that says why. None of them exit 0 quietly.

.PHONY: help setup install build test lint run format analyze push release

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

lint: ## Run the whole gate — every hook, every file
	pre-commit run --all-files

test: build ## Build, then run the smoke tests
	./test.sh $(IMAGE):$(VERSION)

test-db: build-db ## ...and prove the -db variant scans with the network off
	./test.sh $(IMAGE):$(VERSION)-db
	./test-offline.sh $(IMAGE):$(VERSION)-db

setup: ## Install the pre-commit hook
	pre-commit install

install: ## Pull the published image onto this machine
	docker pull $(IMAGE):$(VERSION)

run: build ## Run the image (ARGS is the command, default `scan-image --help`)
	docker run --rm $(IMAGE):$(VERSION) '$(ARGS)'

format: ## Rewrite what the gate can fix: whitespace, line endings, final newline
	@# A fixing hook exits 1 when it rewrites a file. That is this target doing
	@# its job, not failing, so the exits are ignored — make still prints what
	@# each hook said.
	-pre-commit run --all-files trailing-whitespace
	-pre-commit run --all-files end-of-file-fixer
	-pre-commit run --all-files mixed-line-ending

analyze: ## Scan the tree the way CI does — vulnerabilities, misconfig, secrets
	@command -v trivy >/dev/null 2>&1 || { \
		echo "analyze needs trivy: https://trivy.dev/latest/getting-started/installation/" >&2; \
		exit 69; }
	trivy fs --scanners vuln,misconfig,secret --severity CRITICAL,HIGH .

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
