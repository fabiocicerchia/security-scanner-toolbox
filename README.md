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
than no scanners, so releases are rebuilt on a schedule (see roadmap).

## Install

```sh
make build                       # builds ghcr.io/fabiocicerchia/security-scanner-toolbox:1.0.0 locally
docker pull ghcr.io/fabiocicerchia/security-scanner-toolbox:1.0.0
```

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
