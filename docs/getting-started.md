# Getting Started

## Prerequisites

Docker. Nothing else — the four scanners are in the image.

Scanning a *registry* image needs only network access. Scanning a **locally
built** image needs the Docker socket mounted, because the scanners have to
read it from the local daemon.

## First scan

Against something public, with no socket and no credentials:

```sh
docker run --rm fabiocicerchia/security-scanner-toolbox \
  'scan-image alpine:3.22 --fail-on critical'
```

```text
==> syft (SBOM)
SBOM written to /tmp/tmp.XXXXXXXX
==> grype (from SBOM)
No vulnerabilities found
==> trivy
alpine:3.22 (alpine 3.22.0)
Total: 0 (HIGH: 0, CRITICAL: 0)
scan-image: PASS (alpine:3.22)
```

Exit code 0 on pass, non-zero on a finding at or above the threshold. That is
the whole CI contract.

## Keep the SBOM

```sh
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox \
  'scan-image alpine:3.22 --sbom /work/sbom.cdx.json'
```

Worth doing even when the scan passes. When a CVE lands next month, the
question is "was this release affected", and the SBOM answers it without
rebuilding a six-month-old image:

```sh
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox \
  'grype sbom:/work/sbom.cdx.json'
```

## Scan an image you just built

```sh
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD:/work" \
  fabiocicerchia/security-scanner-toolbox \
  'scan-image my-registry/app:1.2.3 --fail-on high --sbom /work/sbom.json'
```

If this fails with a permission error on the socket, it is uid 10001 not being
in the socket's group. Either push to a registry and scan from there — the
better answer in CI — or add `--user 0` for a local run.

## Verify the signature before scanning it

```sh
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox \
  'scan-image my-registry/app:1.2.3 --verify-key /work/cosign.pub'
```

`cosign verify` runs *before* anything else. Scanning first and checking
provenance afterwards answers the questions in the wrong order — a clean scan
of the wrong artifact is not a clean scan.

## In a pipeline

```yaml
jobs:
  scan:
    runs-on: ubuntu-latest
    container: fabiocicerchia/security-scanner-toolbox:0.1.0
    steps:
      - uses: actions/checkout@v4
      - run: scan-image ${{ env.IMAGE }} --fail-on critical --sbom sbom.cdx.json
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: sbom
          path: sbom.cdx.json
```

Pin the tag. `:latest` in a compliance pipeline means the scan that passed and
the scan that will run next month are different scans.

`if: always()` on the upload matters: the SBOM is most useful on the run that
*failed*.

## The individual tools

The entrypoint is `bash -c`, so anything in the image is reachable:

```sh
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox 'trivy fs /work'
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox 'trivy config /work'
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox 'syft -o spdx-json /work'
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox 'cosign sign-blob /work/artifact'
```

Note the quotes — the argument is a command line, not an executable.

## Two things to know before you rely on it

**The scanners fetch their databases at runtime.** A pinned image stays useful
because the data is not baked in — but in an air-gapped or network-restricted
runner they will fetch nothing and report less. A clean result from a scanner
that could not reach its database looks exactly like a clean result. Check the
logs for the DB update line on the first run in a new environment.

**`--fail-on critical` is stricter in trivy than in grype.** grype is given the
threshold as-is; trivy is given `CRITICAL,HIGH`. So a HIGH finding fails the
run at `--fail-on critical`. Use `--fail-on high` if you want both tools on the
same footing.

## Development

```sh
make build     # docker build, with the pinned versions as build args
make lint      # hadolint + shellcheck on scan-image
make test      # all four tools respond; syft produces a real SBOM
make release   # multi-arch buildx push
```

`make build` reads the pinned-versions file and turns each line into a
`--build-arg`. Building with a plain `docker build` and no build args silently
uses the Dockerfile's `ARG` defaults instead — which is why the Makefile is the
supported entry point.
