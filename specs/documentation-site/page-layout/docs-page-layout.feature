@domain:documentation-site @area:page-layout @from:docs/stylesheets
Feature: Docs page layout
  Lets documentation readers scan tables and pages without broken or borrowed branding.

  Background:
    Given the documentation site is published with the project's stylesheet

  @id:documentation-site.page-layout.001 @rule:docs.layout.wide-tables-clipped @inferred @source:docs/stylesheets/extra.css#.md-typeset table:not([class]) @questionable
  Scenario: A table wider than the page is clipped rather than scrollable
    Given a page contains a plain table wider than the reader's screen
    When a reader views the page on a narrow screen
    Then the table is shown as a rounded, bordered card with uppercase column headings
    And the columns beyond the card's edge are cut off and cannot be scrolled into view

  @id:documentation-site.page-layout.002 @rule:docs.layout.no-placeholder-logo @inferred @source:docs/stylesheets/extra.css#.md-header__button.md-logo
  Scenario: The site shows no logo rather than a generic stand-in
    Given the project has no logo configured
    When a reader opens any documentation page
    Then the header shows the site title without a logo icon
    And the navigation drawer title shows no logo icon
