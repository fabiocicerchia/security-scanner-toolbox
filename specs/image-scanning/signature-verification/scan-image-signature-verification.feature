@domain:image-scanning @area:signature-verification @from:security-scanner-toolbox/scan-image
Feature: Verifying the image's signature before scanning
  Operators who sign images need scan-image to refuse an unsigned or wrongly signed image before any scan reports on it.

  Background:
    Given the operator is in the security-scanner-toolbox image
    And the operator holds the cosign public key "/work/cosign.pub"

  @id:image-scanning.signature-verification.001 @rule:scan-image.signature.refuse-before-scanning @inferred @source:scan-image
  Scenario: An image whose signature does not verify is refused before any SBOM or scan
    Given "ghcr.io/acme/api:1.4.0" is not signed by the key in "/work/cosign.pub"
    When the operator runs "scan-image ghcr.io/acme/api:1.4.0 --verify-key /work/cosign.pub"
    Then the cosign verification error is reported
    And no SBOM is written
    And neither vulnerability scanner is run
    And the exit code is non-zero

  @id:image-scanning.signature-verification.002 @rule:scan-image.signature.skipped-without-key @inferred @source:scan-image
  Scenario: Without a key no signature check is made
    Given "ghcr.io/acme/api:1.4.0" is unsigned
    When the operator runs "scan-image ghcr.io/acme/api:1.4.0"
    Then no "cosign verify" step is printed
    And the SBOM and both vulnerability scans run
