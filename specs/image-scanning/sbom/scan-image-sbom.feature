@domain:image-scanning @area:sbom @from:security-scanner-toolbox/scan-image
Feature: Producing the image's SBOM
  Operators keep scan-image's CycloneDX SBOM so they can answer 'were we affected' about later CVEs without the image.

  Background:
    Given the operator is in the security-scanner-toolbox image

  @id:image-scanning.sbom.001 @rule:scan-image.sbom.written-to-chosen-path @inferred @source:scan-image
  Scenario: The SBOM is written as CycloneDX JSON to the chosen file
    When the operator runs "scan-image alpine:3.22 --sbom /work/sbom.cdx.json"
    Then /work/sbom.cdx.json contains a CycloneDX JSON SBOM of alpine:3.22
    And "SBOM written to /work/sbom.cdx.json" is printed
    And the SBOM is written before either vulnerability scan runs

  @id:image-scanning.sbom.002 @rule:scan-image.sbom.temporary-when-unrequested @inferred @source:scan-image @questionable
  Scenario: Without a chosen file the SBOM goes to a temporary file that is left behind
    When the operator runs "scan-image alpine:3.22"
    Then a CycloneDX JSON SBOM is written to a new temporary file
    And "SBOM written to" followed by that temporary path is printed
    And the temporary file still exists after the scan ends
