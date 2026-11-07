@domain:build-integrity @area:download-verification @from:security-scanner-toolbox/verify-download
Feature: Verifying downloaded release artifacts
  Gives operators and image builders a fail-closed check that a downloaded tool matches its release's checksums file, and that this file matches a pinned SHA-256, so a tampered or wrong download never gets through.

  Background:
    Given a release artifact has been downloaded alongside its release's checksums file
    And the SHA-256 of that checksums file is pinned

  @id:build-integrity.download-verification.002 @rule:build-integrity.download-verification.verified-artifact-passes @inferred @source:verify-download#verify-download
  Scenario: An artifact matching its pinned checksums file is reported as verified
    Given the checksums file matches its pinned SHA-256
    And the artifact matches its own line in the checksums file
    When the operator runs verify-download on the artifact
    Then the command reports "verify-download: <artifact> verified against <checksums file>"
    And the command exits with status 0

  @id:build-integrity.download-verification.003 @rule:build-integrity.download-verification.fails-closed-on-mismatch @inferred @source:verify-download#verify-download
  Scenario Outline: A missing, untrusted or tampered download is refused
    Given <condition>
    When the operator runs verify-download on the artifact
    Then the command reports "<message>" on standard error
    And the command exits with a non-zero status

    Examples:
      | condition                                                                       | message                                                                                                   |
      | the artifact file is missing or empty                                           | verify-download: trivy_0.58.0_Linux-64bit.tar.gz is missing or empty                                      |
      | the checksums file does not match its pinned SHA-256                            | verify-download: sums.txt does not match its pinned SHA-256, followed by the expected and the actual hash |
      | the checksums file matches its pin but the artifact does not match its own line | verify-download: trivy_0.58.0_Linux-64bit.tar.gz failed verification against sums.txt                     |

  @id:build-integrity.download-verification.004 @rule:build-integrity.download-verification.unlisted-artifact-refused @inferred @source:verify-download#verify-download @questionable
  Scenario: An artifact with no line in the checksums file is not refused
    Given the checksums file matches its pinned SHA-256
    And the checksums file has no line for the artifact's name
    And sha256sum is the busybox one, as in the image build
    When the operator runs verify-download on the artifact
    Then the command reports "verify-download: <artifact> verified against <checksums file>"
    And the command exits with status 0

  @id:build-integrity.download-verification.005 @rule:build-integrity.download-verification.unverified-tool-never-installed @inferred @source:Dockerfile#fetch
  Scenario: A bundled tool that fails verification is never installed into the image
    Given the release download of trivy, grype, syft or cosign fails verification
    When the maintainer builds the image
    Then the build stops at that tool's download step
    And no image is produced
