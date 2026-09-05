# Architecture

A two-stage build that downloads four pinned release binaries, and one script
that runs them in an order that means something.

```text
stage `fetch`:  curl trivy, grype, syft, cosign at $*_VERSION  (from versions file)
        │
final:  alpine + bash + git + ca-certificates + the four binaries
        │
scan-image IMAGE:
     cosign verify (if --verify-key)     ← before anything else runs
        └─► syft  ──► CycloneDX SBOM
              ├─► grype  sbom:<file>     ← scans the SBOM, not the image
              └─► trivy  image           ← scans the image, independently
```

## Why one image instead of four installs

Four separate scanner installs in a pipeline means four download steps, four
caches to warm, four version drifts, and four different ways for a CI job to
fail before it has scanned anything. Pinning them together makes the scan step
one pull with a version number you can put in a compliance document.

The cost is that the image has to be rebuilt to update any of them, which is
the next section.

## The pinned versions are the product, and they are also the risk

The four versions are `ARG`s with defaults in the Dockerfile, overridden by the
build args the Makefile derives from the versions file. That file is the single
source of truth, and `make build` and `make release` both read it.

But a scanner's usefulness is mostly its **database**, not its binary. trivy
and grype fetch their vulnerability data at runtime, so a six-month-old image
still finds today's CVEs — as long as it can reach the internet. In an
air-gapped or cache-cold pipeline it silently finds fewer, which is the failure
mode worth knowing about here.

That is why the roadmap's scheduled rebuild and `-db` variant are the two items
that matter: a scanner with a stale DB is worse than no scanner, because it
reports a clean result.

Dependabot cannot parse the versions file, so those bumps are deliberate work,
not automated PRs.

## Why `scan-image` runs two scanners

grype and trivy do not agree. They use different vulnerability sources,
different matching rules, and differ most on exactly the packages people argue
about — OS packages with distro backports, and language dependencies pulled in
transitively. Running both and failing on either is a deliberate
false-positive-tolerant stance: this is a gate, and a gate that misses is worse
than a gate that occasionally stops you.

They are also pointed at different things on purpose:

- **grype scans the SBOM** (`sbom:$SBOM`). It re-uses syft's inventory, so what
  it reports and what the SBOM lists cannot disagree.
- **trivy scans the image directly.** An independent inventory, which is what
  makes the cross-check a cross-check rather than two views of one list.

## Order matters

**`cosign verify` runs first**, before syft is even invoked. Scanning an image
and then discovering it is not the image you thought is the wrong order — the
signature check is a precondition, not a report.

**The SBOM is generated before either scan**, and `--sbom` writes it out. The
SBOM is worth keeping even when the scan passes: it is what lets you answer
"were we affected" about a CVE published next month, without rebuilding
anything.

## The severity handling, and its rough edge

`--fail-on` is passed to grype as-is and to trivy as
`--severity "${FAIL_ON^^},HIGH"`. So `--fail-on critical` fails trivy on HIGH
too, while grype fails only on CRITICAL. The two tools are not applying the
same threshold.

That is a real inconsistency, not a subtlety, and it is documented here rather
than hidden: expect trivy to be the stricter of the two at `critical`.

## The entrypoint is `bash -c`

```dockerfile
ENTRYPOINT ["/bin/bash", "-c"]
```

So the argument is a command line, not an executable:
`docker run ... 'trivy fs /work'`. This keeps the image useful for the
individual tools rather than only for the pipeline script, at the cost of
needing quotes. `WORKDIR /work` is the mount point the examples assume.

The image runs as uid 10001. Scanning a *local* image needs the Docker socket,
and the socket's group has to be readable by that uid; scanning a registry
image needs neither.

## Adding a tool

1. A version variable in the versions file, an `ARG` with a matching default,
   and a fetch step in the `fetch` stage.
1. Copy it into the final stage.
1. A line in `test.sh` asserting it responds — the smoke test is what stops a
   fetch step that silently produced a zero-byte file.
1. Decide whether it belongs in `scan-image` at all. Most things do not: the
   script is a gate, and every tool added to it is another way for the gate to
   fail for a reason nobody wants to debug at merge time.
