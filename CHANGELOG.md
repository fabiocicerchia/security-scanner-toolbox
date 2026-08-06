# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 (2026-08-06)


### Bug Fixes

* bump trivy to 0.73.0 so the image builds again ([48b5e13](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/48b5e1360cce9309fd578da0d0d096d6f10f73be))
* **ci:** stop security workflows failing on private repos ([#9](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/9)) ([e62d106](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/e62d106b0b32046dd7238dc44ed7d7f0712743c0))
* **docker:** set pipefail before RUN steps that pipe curl into tar ([905263a](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/905263a0c1bd22882dee20da35e2e52a322ce210))
* **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([ba3fc43](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/ba3fc433b5000832c688c0806141e7655f6f8304))

## [Unreleased]

### Added

- trivy, grype, syft and cosign pinned in one multi-arch image, plus
  `scan-image`: SBOM, scan, cross-check and optional signature verification
  in one command.

Not yet released.
