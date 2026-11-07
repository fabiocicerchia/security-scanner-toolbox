@domain:build-integrity @area:download-verification @from:security-scanner-toolbox/dockerfile
Feature: Verifying downloaded tools before they ship
  Users trust this image to verify their supply chain, so every tool it bundles must match a pinned checksum, and the build fails rather than ship an unverified binary.

  Background:
    Given each tool's release checksums file has a SHA-256 pinned for the build

  @id:build-integrity.download-verification.001 @rule:build.downloads.verified-against-pinned-checksums @inferred @source:Dockerfile#verify-download
  Scenario Outline: A tool download that cannot be verified fails the build
    Given for <tool>, <condition>
    When the maintainer builds the image
    Then the build fails
    And the build output reports "<message>"
    And no image is produced

    Examples:
      | tool   | condition                                                                 | message                                                                                  |
      | cosign | the release checksums file differs from its pinned SHA-256                | verify-download: sums.txt does not match its pinned SHA-256                              |
      | grype  | the downloaded archive is not listed in the checksums file                | verify-download: grype_<version>_linux_amd64.tar.gz failed verification against sums.txt |
      | syft   | the downloaded archive's hash differs from its line in the checksums file | verify-download: syft_<version>_linux_amd64.tar.gz failed verification against sums.txt  |
      | trivy  | the downloaded archive is empty                                           | verify-download: trivy_<version>_Linux-64bit.tar.gz is missing or empty                  |
