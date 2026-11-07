@domain:image-scanning @area:severity-gate @from:security-scanner-toolbox/scan-image
Feature: Gating an image on vulnerability severity
  CI pipelines rely on scan-image's exit code to block images whose known vulnerabilities reach the chosen severity, as judged by two independent scanners.

  Background:
    Given the operator is in the security-scanner-toolbox image

  @id:image-scanning.severity-gate.001 @rule:scan-image.gate.pass-below-threshold @inferred @source:scan-image
  Scenario: An image with nothing at or above the threshold passes
    Given neither grype nor trivy finds a vulnerability at the gated severities in "alpine:3.22"
    When the operator runs "scan-image alpine:3.22 --fail-on critical"
    Then grype and trivy findings are reported
    And "scan-image: PASS (alpine:3.22)" is printed
    And the exit code is 0

  @id:image-scanning.severity-gate.002 @rule:scan-image.gate.fail-at-threshold @inferred @source:scan-image
  Scenario Outline: A finding at the threshold fails the scan, critical by default
    Given grype finds a vulnerability of severity <severity> in "alpine:3.12"
    When the operator runs "scan-image alpine:3.12 <options>"
    Then the findings are reported
    And trivy is not run
    And "scan-image: PASS" is not printed
    And the exit code is non-zero

    Examples:
      | options            | severity |
      |                    | Critical |
      | --fail-on critical | Critical |
      | --fail-on high     | High     |
      | --fail-on high     | Critical |

  @id:image-scanning.severity-gate.003 @rule:scan-image.gate.trivy-always-gates-high @inferred @source:scan-image @questionable
  Scenario: A HIGH finding fails the scan even when the threshold is critical
    Given grype finds nothing at Critical in "ghcr.io/acme/api:1.4.0"
    And trivy finds a HIGH vulnerability in it
    When the operator runs "scan-image ghcr.io/acme/api:1.4.0 --fail-on critical"
    Then trivy is run at severities "CRITICAL,HIGH"
    And the HIGH finding is reported
    And "scan-image: PASS" is not printed
    And the exit code is 1

  @id:image-scanning.severity-gate.004 @rule:scan-image.gate.trivy-skips-severities-below-high @inferred @source:scan-image @questionable
  Scenario Outline: A threshold below high leaves trivy-only MEDIUM and CRITICAL findings ungated
    Given grype finds nothing at or above <threshold> in "ghcr.io/acme/api:1.4.0"
    And trivy alone finds a <severity> vulnerability in it
    When the operator runs "scan-image ghcr.io/acme/api:1.4.0 --fail-on <threshold>"
    Then trivy is run at severities "<trivy_severities>" only
    And the <severity> finding is not reported by trivy
    And "scan-image: PASS (ghcr.io/acme/api:1.4.0)" is printed
    And the exit code is 0

    Examples:
      | threshold | trivy_severities | severity |
      | low       | LOW,HIGH         | CRITICAL |
      | low       | LOW,HIGH         | MEDIUM   |
      | medium    | MEDIUM,HIGH      | CRITICAL |
