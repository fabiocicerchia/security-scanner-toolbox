#!/usr/bin/env sh
# The -db variant's reason to exist: a real scan with the network switched off.
#
# `--network none` is the test. Not "--offline flags are accepted", not "the
# database file is present" — the container is given no route to anywhere and
# still has to produce findings. If the databases were missing or unreadable,
# trivy and grype would try to fetch and fail here rather than quietly
# reporting a clean image, which is the failure this tag exists to prevent.
set -eu
IMAGE="${1:?usage: test-offline.sh <image:tag>}"

# Something with known CVEs, pulled while the network is still up. The scan
# itself runs in a separate, isolated container.
TARGET="${2:-alpine:3.17}"
docker pull -q "$TARGET" >/dev/null
docker save "$TARGET" -o /tmp/scan-target.tar

echo "--- bundled database versions"
docker run --rm --network none "$IMAGE" 'cat /opt/scanner-db/VERSIONS'

echo "--- trivy, offline"
docker run --rm --network none -v /tmp/scan-target.tar:/tmp/t.tar:ro "$IMAGE" '
  set -e
  trivy image --input /tmp/t.tar --format json --quiet > /tmp/trivy.json
  # A scanner that found nothing at all against a deliberately old base is not
  # working offline, it is failing open.
  n=$(grep -c "VulnerabilityID" /tmp/trivy.json || true)
  echo "trivy findings: $n"
  [ "$n" -gt 0 ] || { echo "FATAL: trivy reported no findings offline" >&2; exit 1; }
'

echo "--- grype, offline"
docker run --rm --network none -v /tmp/scan-target.tar:/tmp/t.tar:ro "$IMAGE" '
  set -e
  grype "docker-archive:/tmp/t.tar" -o json > /tmp/grype.json
  n=$(grep -c "\"id\": \"CVE" /tmp/grype.json || true)
  echo "grype findings: $n"
  [ "$n" -gt 0 ] || { echo "FATAL: grype reported no findings offline" >&2; exit 1; }
'

echo "--- syft, offline"
docker run --rm --network none -v /tmp/scan-target.tar:/tmp/t.tar:ro "$IMAGE" \
  'syft "docker-archive:/tmp/t.tar" -o cyclonedx-json | head -c 200 | grep -q bomFormat && echo SBOM-OK'

rm -f /tmp/scan-target.tar
echo PASS-OFFLINE
