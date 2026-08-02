# Basic Example

What it shows: the scan as a CI gate, and the same pipeline run by hand so you
can see what the gate is actually checking.

## Run it locally first

```sh
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox \
  'scan-image alpine:3.22 --fail-on critical --sbom /work/sbom.cdx.json'
```

```text
==> syft (SBOM)
SBOM written to /work/sbom.cdx.json
==> grype (from SBOM)
No vulnerabilities found
==> trivy
Total: 0 (HIGH: 0, CRITICAL: 0)
scan-image: PASS (alpine:3.22)
```

Now try one that fails, to confirm the gate is a gate:

```sh
docker run --rm fabiocicerchia/security-scanner-toolbox \
  'scan-image alpine:3.12 --fail-on critical' ; echo "exit=$?"
```

An old base has known criticals; expect a non-zero exit and a findings table.
A gate you have never seen fail is a gate you are assuming works.

## In CI

[`scan.yml`](scan.yml) is a working workflow — copy it to
`.github/workflows/scan.yml` in the repo being scanned and set `IMAGE`.

Two things in it are load-bearing:

**The tag is pinned.** `security-scanner-toolbox:0.1.0`, not `:latest`. The
scanner versions are the reproducible part of the result.

**The SBOM upload is `if: always()`.** The failing run is the one whose SBOM
you want, and a step that only runs on success will not give it to you.

## Query the SBOM later

The SBOM outlives the scan. When a CVE is published next month:

```sh
docker run --rm -v "$PWD:/work" fabiocicerchia/security-scanner-toolbox \
  'grype sbom:/work/sbom.cdx.json'
```

That re-scans the recorded inventory against today's vulnerability data,
without needing the image to still exist.

## A note on the threshold

`--fail-on critical` is not symmetric: grype gets `critical`, trivy gets
`CRITICAL,HIGH`. So a HIGH finding fails the run. Use `--fail-on high`
explicitly if you want that to be the stated policy rather than a side effect —
the example workflow does.
