@domain:developer-tooling @area:local-install @from:security-scanner-toolbox/makefile
Feature: Installing the scanner tools on a host
  Lets an operator or packager put scan-image and verify-download, with their man pages, onto a host or into a staging root without running the container.

  @id:developer-tooling.local-install.001 @rule:developer-tooling.local-install.installs-tools-and-man-pages-under-destdir-prefix @inferred @source:Makefile#install
  Scenario Outline: Installing puts both tools and their man pages under the chosen root and prefix
    Given DESTDIR is "<destdir>" and PREFIX is "<prefix>"
    When the operator runs make install
    Then "<destdir><prefix>/bin/scan-image" and "<destdir><prefix>/bin/verify-download" exist and are executable (mode 0755)
    And "<destdir><prefix>/share/man/man1/scan-image.1" and "<destdir><prefix>/share/man/man1/verify-download.1" exist with mode 0644
    And the operator sees "installed scan-image verify-download into <destdir><prefix>/bin"

    Examples:
      | destdir      | prefix       |
      |              | /usr/local   |
      | /tmp/pkgroot | /usr         |
      |              | /opt/toolbox |

  @id:developer-tooling.local-install.002 @rule:developer-tooling.local-install.default-prefix-is-filesystem-root @inferred @source:Makefile#install @questionable
  Scenario: Installing without a prefix writes into /bin and /share at the filesystem root
    Given neither DESTDIR nor PREFIX is set
    When the operator runs make install
    Then scan-image and verify-download are written to "/bin"
    And the man pages are written to "/share/man/man1"
    And the operator sees "installed scan-image verify-download into /bin"

  @id:developer-tooling.local-install.003 @rule:developer-tooling.local-install.uninstall-removes-installed-files @inferred @source:Makefile#uninstall
  Scenario: Uninstalling removes exactly the tools and man pages that install put down
    Given scan-image and verify-download were installed with DESTDIR "/tmp/pkgroot" and PREFIX "/usr"
    When the operator runs make uninstall with the same DESTDIR and PREFIX
    Then "/tmp/pkgroot/usr/bin/scan-image" and "/tmp/pkgroot/usr/bin/verify-download" no longer exist
    And "/tmp/pkgroot/usr/share/man/man1/scan-image.1" and "/tmp/pkgroot/usr/share/man/man1/verify-download.1" no longer exist
    And the command succeeds even if some of those files were already gone
