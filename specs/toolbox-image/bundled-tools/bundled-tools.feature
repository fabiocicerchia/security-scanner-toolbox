@domain:toolbox-image @area:bundled-tools @from:security-scanner-toolbox/dockerfile
Feature: Bundled scanning and signing tools
  CI operators get trivy, grype, syft, cosign and scan-image in one image, with the licence notices that come with them.

  Background:
    Given the security-scanner-toolbox image has been built

  @id:toolbox-image.bundled-tools.001 @rule:toolbox.tools.all-tools-on-path @inferred @source:Dockerfile#COPY --from=fetch
  Scenario Outline: Every bundled tool can be run by name
    When the operator runs "<tool>" in the image
    Then the tool is found on the PATH and runs without any install step

    Examples:
      | tool       |
      | trivy      |
      | grype      |
      | syft       |
      | cosign     |
      | scan-image |
      | git        |
