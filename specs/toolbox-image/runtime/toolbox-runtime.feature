@domain:toolbox-image @area:runtime @from:security-scanner-toolbox/dockerfile
Feature: Running the toolbox image
  CI operators run the image as a one-shot command runner, so what it does with no arguments, with a command string, and as which user is the contract their pipelines rely on.

  Background:
    Given the security-scanner-toolbox image has been built

  @id:toolbox-image.runtime.001 @rule:toolbox.runtime.default-command-shows-scan-help @inferred @source:Dockerfile#CMD
  Scenario: Running the image with no command shows the scan-image help
    When the operator runs the image without a command
    Then the scan-image help text is printed
    And the container exits once the help is printed

  @id:toolbox-image.runtime.002 @rule:toolbox.runtime.argument-is-a-shell-command @inferred @source:Dockerfile#ENTRYPOINT
  Scenario Outline: The command given to the image runs as one shell command line
    When the operator runs the image with the command "<command>"
    Then the command line is run by bash inside the container
    And the container's exit status is the exit status of that command line

    Examples:
      | command                                          |
      | trivy --version | head -1                        |
      | syft -o cyclonedx-json alpine:3.22 | head -c 200 |
      | scan-image registry.example.com/app:1.4.2        |

  @id:toolbox-image.runtime.003 @rule:toolbox.runtime.runs-as-non-root @inferred @source:Dockerfile#USER
  Scenario: Commands run as an unprivileged user in the /work directory
    When the operator runs a command in the image without overriding the user
    Then the command runs as user id 10001 ("scanner"), not root
    And the working directory is /work
