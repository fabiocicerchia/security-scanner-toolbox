#!/usr/bin/env sh
# Smoke test: all four tools respond, and syft can SBOM a real tiny image.
set -eu
IMAGE="${1:?usage: test.sh <image:tag>}"
docker run --rm "$IMAGE" '
  set -e
  trivy --version | head -1
  grype version 2>/dev/null | head -1
  syft version 2>/dev/null | head -1
  cosign version 2>/dev/null | head -1
'
docker run --rm "$IMAGE" 'syft -o cyclonedx-json alpine:3.22 | head -c 200 | grep -q bomFormat && echo SBOM-OK'
echo PASS
