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

## Verify *this* image

The same argument applies to the scanner. Every published tag is cosign-signed
keylessly and carries SLSA build provenance:

```sh
IMAGE=ghcr.io/fabiocicerchia/security-scanner-toolbox

# Resolve the tag to a digest first. A signature is attached to bytes, not to a
# name, and a tag can move.
DIGEST=$(docker buildx imagetools inspect "$IMAGE:latest" \
  --format '{{ .Manifest.Digest }}')

cosign verify \
  --certificate-identity-regexp \
    '^https://github.com/fabiocicerchia/security-scanner-toolbox/\.github/workflows/' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  "$IMAGE@$DIGEST"
```

And the provenance — what built it, from which commit:

```sh
cosign verify-attestation --type slsaprovenance \
  --certificate-identity-regexp \
    '^https://github.com/fabiocicerchia/security-scanner-toolbox/\.github/workflows/' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  "$IMAGE@$DIGEST" | jq -r '.payload | @base64d | fromjson | .predicate.buildDefinition'
```

There is no public key to fetch or trust. Keyless signing binds the signature to
an OIDC identity — the workflow file, in this repository, at the ref that ran —
and that identity is what the two flags above assert. Pinning the identity
matters: a signature that is merely *valid* only says someone signed it.

Both commands run in `publish.yml` against the digest it just pushed, so a
signing path that quietly stops working fails the release rather than the docs.

## Offline scanning: the `-db` tag

The default image fetches vulnerability databases at scan time, which is a
non-starter on an air-gapped runner and slow everywhere else. The `-db` tags
ship them baked in:

```sh
docker run --rm --network none -v "$PWD:/work" \
  ghcr.io/fabiocicerchia/security-scanner-toolbox:latest-db \
  'trivy image --input /work/app.tar'
```

Same tools, same pins — the `-db` image is built *from the published base image
by digest*, so it is that exact release plus data, not a parallel build that
could drift.

What is in it, without running a scan:

```sh
docker run --rm --network none \
  ghcr.io/fabiocicerchia/security-scanner-toolbox:latest-db \
  'cat /opt/scanner-db/VERSIONS'
```

```
image_built=2026-09-01T03:20:11Z
trivy=0.73.0
grype=0.95.0
trivy_db=2026-09-01T02:11:44Z
grype_db=2026-08-31T22:04:00Z
```

The databases are also the reason this tag is much larger than the base image.
The current sizes are reported in the job summary of the latest
[Refresh bundled databases](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/db-refresh.yml) run, rather
than written here where they would go stale the first time a feed grows.

### It ages

A bundled database is a snapshot. `latest-db` is rebuilt every Monday — only
the databases, never the tool pins — so a weekly `docker pull` keeps it fresh.
If you mirror it into an air-gapped environment, mirror it on a schedule too: a
scanner running on a six-month-old feed reports clean and is believed, which is
worse than having no scanner at all.

The rebuild fails rather than publishing a stale-database image. `Dockerfile.db`
checks both database files exist after the download, and CI then runs the whole
scan under `--network none` and requires real CVEs to come back — an image that
scanned clean offline would be exactly the silent failure the schedule exists to
prevent.

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
