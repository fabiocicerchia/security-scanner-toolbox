@domain:developer-tooling @area:build-and-run @from:security-scanner-toolbox/makefile
Feature: Running a command inside the toolbox image
  Lets a developer try any bundled tool in the freshly built image with one make command.

  @id:developer-tooling.build-and-run.001 @rule:developer-tooling.build-and-run.run-executes-args-in-built-image @inferred @source:Makefile#run
  Scenario: Running with a command executes it in the freshly built image
    Given ARGS is "trivy --version"
    When the developer runs make run
    Then the image is built and tagged with the current version first
    And "trivy --version" runs inside a throwaway container of that image and its output is shown
    And the container is removed when the command ends

  @id:developer-tooling.build-and-run.002 @rule:developer-tooling.build-and-run.run-without-args-shows-scan-image-help @inferred @source:Makefile#run @questionable
  Scenario: Running without a command prints nothing instead of the advertised scan-image help
    Given ARGS is not set
    When the developer runs make run
    Then the container runs an empty command and exits 0
    And no scan-image help is printed, although the target describes `scan-image --help` as the default
