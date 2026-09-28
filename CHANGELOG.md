# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0](https://github.com/fabiocicerchia/security-scanner-toolbox/compare/v1.1.1...v1.2.0) (2026-09-28)


### Features

* add the eight-verb repo contract ([#53](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/53)) ([0687589](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/0687589cd77f0c1161aa7577b50068258eb8b00d))
* **packaging:** man page, and an install that stages rather than pulls ([#57](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/57)) ([6e04a0a](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/6e04a0af239167aee77f5daa76a78015e8c29df8))
* sign releases, add a -db variant, and refresh its databases weekly ([#43](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/43)) ([00669a8](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/00669a81b4fe681245f83dfab0fb398e08bfa8ab))


### Bug Fixes

* **ci:** keep actions: read on the job that uploads sarif ([#73](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/73)) ([c2a7894](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/c2a7894932f3ed7490a569dbd9cd2876fc3ccb4e))
* **ci:** pin the editorconfig-checker binary version ([#44](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/44)) ([6054b75](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/6054b758078b9ee4e8a6f2d508f9b51b97d81097))
* **docs:** link out-of-tree files by URL so --strict passes ([#45](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/45)) ([01f7b2a](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/01f7b2a8c51611bf226ae0cce215c5aa4507d26d))
* point install docs at image tags that exist ([#55](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/55)) ([b33901e](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/b33901eb9f1fa20060258c6912dae1342394a4c4))
* **publish:** ask cosign for the SLSA v1 predicate, not v0.2 ([#62](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/62)) ([0bcc827](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/0bcc82771f89e6f382e3a3f64e8d7c8630079001))
* **release:** grant attestations on the job that calls publish.yml ([#78](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/78)) ([92eccf5](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/92eccf5f92f77c870fc40d64469a68aea59922e9))
* **release:** grant id-token on the job that calls the signing workflow ([#61](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/61)) ([cc957ce](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/cc957cefc2c863d4253148fbaf0549051f49a9dd))

## [1.1.1](https://github.com/fabiocicerchia/security-scanner-toolbox/compare/v1.1.0...v1.1.1) (2026-08-29)

### Bug Fixes

- unblock quality and clear the Scorecard pinned-dependencies finding ([#37](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/37)) ([04bb501](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/04bb501783829b0ad92be76278aeef7023e8fd4b))

## [1.1.0](https://github.com/fabiocicerchia/security-scanner-toolbox/compare/v1.0.3...v1.1.0) (2026-08-25)

### Features

- **docs:** build the docs site in Actions and drop Read the Docs ([#35](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/35)) ([bd5308c](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/bd5308ca639c7ec4ec60696bd0eecadf2a9bc59c))

## [1.0.3](https://github.com/fabiocicerchia/security-scanner-toolbox/compare/v1.0.2...v1.0.3) (2026-08-13)

### Bug Fixes

- security and code-quality findings ([#25](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/25)) ([1793d37](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/1793d37814fb3202df8d1b472d52ac22d77624d0))

## [1.0.2](https://github.com/fabiocicerchia/security-scanner-toolbox/compare/v1.0.1...v1.0.2) (2026-08-11)

### Bug Fixes

- verify every downloaded tool against a pinned checksum ([5cd03ad](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/5cd03ad4cb174e623d1ccdf961ea8f646f46b1e6))

## [1.0.1](https://github.com/fabiocicerchia/security-scanner-toolbox/compare/v1.0.0...v1.0.1) (2026-08-06)

### Bug Fixes

- publish the image from the release job so it actually runs ([e40df4d](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/e40df4db04b4c2971da5850d578fc86aefc438d5))

## 1.0.0 (2026-08-06)

### Bug Fixes

- bump trivy to 0.73.0 so the image builds again ([48b5e13](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/48b5e1360cce9309fd578da0d0d096d6f10f73be))
- **ci:** stop security workflows failing on private repos ([#9](https://github.com/fabiocicerchia/security-scanner-toolbox/issues/9)) ([e62d106](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/e62d106b0b32046dd7238dc44ed7d7f0712743c0))
- **docker:** set pipefail before RUN steps that pipe curl into tar ([905263a](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/905263a0c1bd22882dee20da35e2e52a322ce210))
- **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([ba3fc43](https://github.com/fabiocicerchia/security-scanner-toolbox/commit/ba3fc433b5000832c688c0806141e7655f6f8304))

## [Unreleased]

### Added

- trivy, grype, syft and cosign pinned in one multi-arch image, plus
  `scan-image`: SBOM, scan, cross-check and optional signature verification
  in one command.

Not yet released.
