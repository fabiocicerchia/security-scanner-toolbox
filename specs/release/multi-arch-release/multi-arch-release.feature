@domain:release @area:multi-arch-release @from:security-scanner-toolbox/makefile
Feature: Releasing multi-arch images
  Lets the maintainer publish the toolbox and its offline -db variant for every supported architecture under versioned and latest tags.

  Background:
    Given the image name is ghcr.io/fabiocicerchia/security-scanner-toolbox
    And version.txt contains "1.4.0"

  @id:release.multi-arch-release.001 @rule:release.multi-arch-release.pushes-version-and-latest-tags @inferred @source:Makefile#release
  Scenario Outline: A release pushes the versioned and latest tags for amd64 and arm64
    Given PLATFORMS is not overridden
    When the maintainer runs make <target>
    Then an image for linux/amd64 and linux/arm64 is pushed as "<version_tag>" and "<latest_tag>"
    And both tags point at the same multi-arch image

    Examples:
      | target     | version_tag | latest_tag |
      | release    | 1.4.0       | latest     |
      | release-db | 1.4.0-db    | latest-db  |
