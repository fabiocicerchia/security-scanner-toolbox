@domain:toolbox-image @area:platforms @from:security-scanner-toolbox/dockerfile
Feature: Native tools for each CPU architecture
  Operators on amd64 and arm64 runners get tool binaries built for their architecture from the same image definition.

  @id:toolbox-image.platforms.001 @rule:toolbox.platforms.arch-matched-binaries @inferred @source:Dockerfile#fetch @questionable
  Scenario Outline: The image bundles tool binaries for the platform it was built for
    Given the image is built for platform <platform>
    When the operator runs the bundled tools on a <platform> host
    Then trivy, grype, syft and cosign are the <platform> release binaries
    And each tool runs natively without emulation

    Examples:
      | platform    |
      | linux/amd64 |
      | linux/arm64 |
