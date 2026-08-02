IMAGE     ?= fabiocicerchia/security-scanner-toolbox
VERSION   ?= 0.1.0
PLATFORMS ?= linux/amd64,linux/arm64
BUILD_ARGS = $(shell sed -n 's/^\([A-Z_]*\)=\(.*\)/--build-arg \1=\2/p' versions.env)

.PHONY: build lint test push release

build:
	docker build $(BUILD_ARGS) -t $(IMAGE):$(VERSION) .

lint:
	docker run --rm -i hadolint/hadolint < Dockerfile
	shellcheck scan-image

test: build
	./test.sh $(IMAGE):$(VERSION)

push: build
	docker push $(IMAGE):$(VERSION)

release:
	docker buildx build --platform $(PLATFORMS) $(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
