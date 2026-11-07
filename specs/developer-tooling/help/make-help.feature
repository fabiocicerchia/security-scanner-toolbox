@domain:developer-tooling @area:help @from:security-scanner-toolbox/makefile
Feature: Listing available make commands
  Shows a newcomer every verb the repository exposes without reading the Makefile.

  @id:developer-tooling.help.001 @rule:developer-tooling.help.bare-make-lists-every-target @inferred @source:Makefile#help
  Scenario: Running make with no target lists every command with its one-line description
    When the developer runs make with no target
    Then one line per documented target is printed, e.g. "build        Build the image locally"
    And the list includes help, build, build-db, lint, test, test-db, setup, install, uninstall, run, format, analyze, push, release and release-db
    And nothing is built or run
