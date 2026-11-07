@domain:toolbox-image @area:image-metadata @from:security-scanner-toolbox/dockerfile
Feature: Image metadata labels
  Registries, scanners and compliance tooling read the standard OCI labels to show what the image is, where its source lives and how it is licensed.

  @id:toolbox-image.image-metadata.001 @rule:toolbox.metadata.oci-labels @inferred @source:Dockerfile#LABEL
  Scenario Outline: The image declares its title, description, source and licences
    Given the security-scanner-toolbox image has been built
    When a registry or compliance tool reads the image label "<label>"
    Then the label's value is "<value>"

    Examples:
      | label                                | value                                                            |
      | org.opencontainers.image.title       | security-scanner-toolbox                                         |
      | org.opencontainers.image.description | trivy + grype + syft + cosign, pinned, for supply-chain CI steps |
      | org.opencontainers.image.licenses    | Apache-2.0 AND GPL-2.0-or-later AND GPL-3.0-or-later             |
      | org.opencontainers.image.source      | https://github.com/fabiocicerchia/security-scanner-toolbox       |
