@domain:build-integrity @area:version-pinning @from:security-scanner-toolbox/dockerfile
Feature: Refusing to build without pinned tool versions
  Maintainers can only build the image with tool versions supplied explicitly, so no unpinned or default version ever ships by accident.

  @id:build-integrity.version-pinning.001 @rule:build.versions.missing-version-refused @inferred @source:Dockerfile#ARG TRIVY_VERSION
  Scenario Outline: A build without a tool version is refused and names the missing version
    Given the build is given no value for <version_arg>
    When the maintainer builds the image
    Then the build fails before downloading any tool
    And the error names <version_arg> and tells the maintainer to build with make build or pass the pinned versions file as build args

    Examples:
      | version_arg    |
      | TRIVY_VERSION  |
      | GRYPE_VERSION  |
      | SYFT_VERSION   |
      | COSIGN_VERSION |
