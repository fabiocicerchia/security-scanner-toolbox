# security-scanner-toolbox

**trivy + grype + syft + cosign**, pinned and multi-arch, in one image — the
entire supply-chain step of a CI pipeline without four separate installs, four
caches, and four version drifts. Includes `scan-image`, an opinionated
SBOM → scan → verify pipeline.

The commitment of this image is *cadence*: scanners with stale DBs are worse
than no scanners, so releases are rebuilt on a schedule (see roadmap).

## Usage

One-command pipeline (SBOM with syft, scan it with grype, cross-check with
trivy, optionally verify the signature first):

```sh
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  fabiocicerchia/security-scanner-toolbox \
  'scan-image my-registry/app:1.2.3 --fail-on high --sbom /work/sbom.json'
```

Individual tools (the entrypoint is `bash -c`):

```sh
docker run --rm fabiocicerchia/security-scanner-toolbox 'trivy fs /work'
docker run --rm fabiocicerchia/security-scanner-toolbox 'cosign sign-blob ...'
```

GitHub Actions:

```yaml
container: fabiocicerchia/security-scanner-toolbox:0.1.0
steps:
  - run: scan-image ${{ env.IMAGE }} --fail-on critical
```

## Pinned versions

See [`versions.env`](versions.env) — consumed by the Makefile as build args.

## Status & roadmap

- [x] Pinned multi-arch build, smoke tests, `scan-image` pipeline
- [ ] Scheduled weekly rebuild (fresh vuln DBs baked in for air-gapped use)
- [ ] `-db` variant with pre-downloaded trivy/grype databases
- [ ] SLSA provenance + cosign-signed releases of this image itself

## Development

`make build` / `make lint` / `make test` / `make release`.

## License

Apache-2.0 — see [LICENSE](LICENSE).
