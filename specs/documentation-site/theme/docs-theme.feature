@domain:documentation-site @area:theme @from:docs/stylesheets
Feature: Docs site brand colours across light and dark schemes
  Gives readers of the documentation site one consistent security-family palette with legible links whichever colour scheme they use.

  Background:
    Given the documentation site is published with the project's stylesheet

  @id:documentation-site.theme.001 @rule:docs.theme.security-palette @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The docs use the security orange-red accent pair
    Given the project belongs to the security / supply chain cluster
    When a reader opens any documentation page
    Then the header and navigation chrome use the red accent #ef4444
    And interactive accents use the orange accent #fb923c
    And primary buttons and the home title blend orange into red

  @id:documentation-site.theme.002 @rule:docs.theme.links-legible-per-scheme @inferred @source:docs/stylesheets/extra.css#[data-md-color-scheme="slate"]
  Scenario Outline: Link colour switches with the colour scheme so links stay readable
    Given the reader has chosen the <scheme> colour scheme
    When a reader views a page containing links
    Then links are shown in <link_colour>
    And the page background is <background>

    Examples:
      | scheme | link_colour    | background                |
      | light  | red #ef4444    | the theme's default white |
      | dark   | orange #fb923c | deep navy #0b0f1a         |

  @id:documentation-site.theme.003 @rule:docs.theme.no-network-fonts @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The docs render with system fonts and fetch no web font
    Given the reader's browser has no network access to font providers
    When a reader opens any documentation page
    Then body text renders in the operating system's sans-serif font
    And code renders in the operating system's monospace font
    And no font is downloaded from a third party
