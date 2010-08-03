@announce
Feature: Application actions, configuration and error handling

  As an interactive user or automated script
  The application should accept actions and report errors 

  Scenario: No command line action
    When I run "revenc"
    Then the exit status should be 1
    And the output should match: 
      """
      ^.* action required
      ^.* --help for more information
      """

  Scenario: Invalid action
    When I run "revenc non-existing-action"
    Then the exit status should be 1
    And the output should match: 
      """
      ^.* invalid action: non-existing-action
      ^.* --help for more information

      """

  Scenario: --config FILE (exists)
    Given an empty file named "config.conf"
    When I run "revenc mount --verbose --config config.conf"
    Then the output should contain: 
      """
      loading config file: config.conf
      """

  Scenario: --config FILE (not found)
    When I run "revenc mount --verbose --config config.conf"
    Then the output should not contain: 
      """
      loading config file: config.conf
      """
    And the output should contain: 
      """
      config file not found 
      """

  Scenario: Backtrace with --verbose option
    When I run "revenc --verbose mount bad_source bad_dest"
    Then the exit status should be 1
    And the output should match: 
      """
      lib/(.*)/app.rb
      """

  Scenario: No backtrace without --verbose option
    When I run "revenc mount bad_source bad_dest --no-verbose"
    Then the exit status should be 1
    And the output should not contain: 
      """
      /app.rb:
      """
