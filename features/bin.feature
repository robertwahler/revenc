@announce
Feature: Options via a command line interface (CLI)

  As an interactive user or automated script
  The application should accept options on the command line
  These options should override hard coded defaults 
  In order to configure options

  Scenario: Version info
    When I run "revenc --version"
    Then the exit status should be 0
    And I should see matching "revenc, version ([\d]+\.[\d]+\.[\d]+$)"

  Scenario: Help
    When I run "revenc --help"
    Then the exit status should be 0
    And I should see matching: 
      """
      .*
        Usage: .*
      .*
      Options:
      .*
          -v, --\[no-\]verbose               Run verbosely
      """

  Scenario: Invalid option
    When I run "revenc --non-existing-option"
    Then the exit status should be 1
    And I should see matching: 
      """
      ^.* invalid option: --non-existing-option
      ^.* --help for more information

      """
