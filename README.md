# security-scanner-toolbox

[![CI](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/ci.yml)
[![Code Quality](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/code-quality.yml/badge.svg)](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/code-quality.yml)
[![Security](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/security-scanner-toolbox/actions/workflows/security.yml)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/security-scanner-toolbox/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/security-scanner-toolbox)
[![CI carbon](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fabiocicerchia/security-scanner-toolbox/gh-pages/badge.json)](.github/workflows/carbon-badge.yml)

**trivy + grype + syft + cosign**, pinned and multi-arch, in one image — the
entire supply-chain step of a CI pipeline without four separate installs, four
caches, and four version drifts. Includes `scan-image`, an opinionated
SBOM → scan → verify pipeline.

The commitment of this image is *cadence*: scanners with stale DBs are worse
than no scanners, so the database-bundled tags are rebuilt every Monday.

## Install

```sh
make build                       # builds ghcr.io/fabiocicerchia/security-scanner-toolbox:1.0.0 locally
docker pull ghcr.io/fabiocicerchia/security-scanner-toolbox:1.0.0
docker pull ghcr.io/fabiocicerchia/security-scanner-toolbox:1.0.0-db   # databases baked in
```

### Two tags

| Tag                       | Databases                  | For                                    |
| ------------------------- | -------------------------- | -------------------------------------- |
| `:1.0.0`, `:latest`       | fetched at scan time       | ordinary CI with a network             |
| `:1.0.0-db`, `:latest-db` | baked in, refreshed weekly | air-gapped, or cold-start-sensitive CI |

The `-db` image is built **from the published base image by digest**, so it is
that exact release plus data — the tools cannot drift between the two. It scans
with `--network none`, which is proved in CI on every rebuild by requiring real
CVEs to come back; an image that scanned clean offline would be the silent
failure the whole tag exists to prevent.

### Verify it

This image ships cosign to check other people's artifacts, so it signs its own.
Every tag is cosign-signed keylessly and carries SLSA build provenance:

```sh
IMAGE=ghcr.io/fabiocicerchia/security-scanner-toolbox
DIGEST=$(docker buildx imagetools inspect "$IMAGE:latest" --format '{{ .Manifest.Digest }}')

cosign verify \
  --certificate-identity-regexp \
    '^https://github.com/fabiocicerchia/security-scanner-toolbox/\.github/workflows/' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  "$IMAGE@$DIGEST"
```

No key to fetch or trust: the signature is bound to an OIDC identity — this
workflow, in this repository, at the ref that ran — and pinning that identity is
the point. A signature that is merely *valid* only says somebody signed it. See
[docs/getting-started.md](docs/getting-started.md#verify-this-image) for the
provenance command too.

## Usage

One-command pipeline (SBOM with syft, scan it with grype, cross-check with
trivy, optionally verify the signature first):

```sh
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/fabiocicerchia/security-scanner-toolbox \
  'scan-image my-registry/app:1.2.3 --fail-on high --sbom /work/sbom.json'
```

Individual tools (the entrypoint is `bash -c`):

```sh
docker run --rm ghcr.io/fabiocicerchia/security-scanner-toolbox 'trivy fs /work'
docker run --rm ghcr.io/fabiocicerchia/security-scanner-toolbox 'cosign sign-blob ...'
```

GitHub Actions:

```yaml
container: ghcr.io/fabiocicerchia/security-scanner-toolbox:1.0.0
steps:
  - run: scan-image ${{ env.IMAGE }} --fail-on critical
```

## Pinned versions

See [`versions.env`](versions.env) — consumed by the Makefile as build args.

## Development

`make build` / `make lint` / `make test` / `make release`.

## Documentation

Full docs live in [`docs/`](docs/). Runnable examples live in [`examples/`](examples/).

## License

Apache-2.0 — see [LICENSE](LICENSE).
