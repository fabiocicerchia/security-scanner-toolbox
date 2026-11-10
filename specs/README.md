# Specifications of security-scanner-toolbox

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## Build Integrity

Guarantees that the toolbox's own contents are exactly what was pinned and verified.

- **Download verification**: [Verifying downloaded tools before they ship](build-integrity/download-verification/download-verification.feature) (1), [Verifying downloaded release artifacts](build-integrity/download-verification/verifying-downloaded-tools.feature) (3)
- **Version pinning**: [Refusing to build without pinned tool versions](build-integrity/version-pinning/build-version-args.feature) (1)

## Developer Tooling

Make targets contributors use to build, test, check and install the toolbox locally.

- **Build and run**: [Running a command inside the toolbox image](developer-tooling/build-and-run/run-in-image.feature) (2)
- **Command help**: [Listing available make commands](developer-tooling/help/make-help.feature) (1)
- **Local installation**: [Installing the scanner tools on a host](developer-tooling/local-install/local-install.feature) (2)
- **Quality gates**: [Scanning the source tree like CI](developer-tooling/quality-gates/source-tree-analysis.feature) (2)

## Documentation Site

The look and feel of the project's published documentation.

- **Page layout**: [Docs page layout](documentation-site/page-layout/docs-page-layout.feature) (2)
- **Theme and colours**: [Docs site brand colours across light and dark schemes](documentation-site/theme/docs-theme.feature) (2)

## Image Scanning

The scan-image pipeline that checks a container image's supply chain in one command.

- **Command line**: [Invoking the scan-image pipeline](image-scanning/command-line/scan-image-command-line.feature) (2)
- **SBOM generation**: [Producing the image's SBOM](image-scanning/sbom/scan-image-sbom.feature) (2)
- **Severity gate**: [Gating an image on vulnerability severity](image-scanning/severity-gate/scan-image-severity-gate.feature) (4)
- **Signature verification**: [Verifying the image's signature before scanning](image-scanning/signature-verification/scan-image-signature-verification.feature) (2)

## Release & Distribution

Publishing the toolbox image to a registry for others to pull.

- **Multi-arch release**: [Releasing multi-arch images](release/multi-arch-release/multi-arch-release.feature) (1)

## Toolbox Image

The container image that ships trivy, grype, syft and cosign together, ready for CI.

- **Bundled tools**: [Bundled scanning and signing tools](toolbox-image/bundled-tools/bundled-tools.feature) (1)
- **Platform support**: [Native tools for each CPU architecture](toolbox-image/platforms/multi-arch-tools.feature) (1)
- **Runtime behaviour**: [Running the toolbox image](toolbox-image/runtime/toolbox-runtime.feature) (3)
