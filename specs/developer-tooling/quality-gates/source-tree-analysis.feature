@domain:developer-tooling @area:quality-gates @from:security-scanner-toolbox/makefile
Feature: Scanning the source tree like CI
  Lets a contributor run the same vulnerability, misconfiguration and secret scan CI runs, before pushing.

  @id:developer-tooling.quality-gates.001 @rule:developer-tooling.quality-gates.analyze-requires-trivy @inferred @source:Makefile#analyze
  Scenario: Source analysis refuses to run when trivy is not installed
    Given trivy is not installed on the contributor's machine
    When the contributor runs make analyze
    Then the contributor sees "analyze needs trivy: https://trivy.dev/latest/getting-started/installation/" on standard error
    And make analyze fails, reporting "Error 69" for the recipe
    And no scan is performed

  @id:developer-tooling.quality-gates.002 @rule:developer-tooling.quality-gates.analyze-reports-high-and-critical @inferred @source:Makefile#analyze
  Scenario: Source analysis reports only high and critical vulnerabilities, misconfigurations and secrets
    Given trivy is installed
    When the contributor runs make analyze
    Then the working tree is scanned for vulnerabilities, misconfigurations and secrets
    And only findings of severity CRITICAL or HIGH are reported
