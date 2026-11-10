@domain:image-scanning @area:command-line @from:security-scanner-toolbox/scan-image
Feature: Invoking the scan-image pipeline
  Operators running scan-image in CI need clear help and a distinct usage-error exit so a mistyped command is never mistaken for a failed scan.

  Background:
    Given the operator is in the security-scanner-toolbox image

  @id:image-scanning.command-line.001 @rule:scan-image.cli.help-exits-zero @inferred @source:scan-image#usage @questionable
  Scenario Outline: Asking for help prints the usage and exits cleanly
    When the operator runs "scan-image <flag>"
    Then the usage line "scan-image IMAGE [--fail-on SEVERITY] [--sbom out.json] [--verify-key key.pub]" is printed
    And no scan is run
    And the exit code is 0

    Examples:
      | flag   |
      | --help |
      | -h     |

  @id:image-scanning.command-line.002 @rule:scan-image.cli.usage-error-exits-64 @inferred @source:scan-image#usage
  Scenario Outline: A missing image or unknown flag is refused as a usage error
    When the operator runs "scan-image <arguments>"
    Then <message>the usage text is printed
    And no image is scanned
    And the exit code is 64

    Examples:
      | arguments            | message                                                    |
      | alpine:3.22 --strict | "unknown flag: --strict" is printed on standard error and  |
      | --fail-on high       |                                                            |
