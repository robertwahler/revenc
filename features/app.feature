@announce
Feature: Application actions, configuration and error handling

  As an interactive user or automated script
  The application should accept actions and report errors 

  Scenario: No command line action
    When I run "revenc"
    Then the exit status should be 1
    And I should see matching: 
      """
      ^.* action required
      ^.* --help for more information
      """

  Scenario: Invalid action
    When I run "revenc non-existing-action"
    Then the exit status should be 1
    And I should see matching: 
      """
      ^.* invalid action: non-existing-action
      ^.* --help for more information

      """

  Scenario: --config FILE (exists)
    Given an empty file named "config.conf"
    When I run "revenc mount --verbose --config config.conf"
    Then I should see: 
      """
      loading config file: config.conf
      """

  Scenario: --config FILE (not found)
    When I run "revenc mount --verbose --config config.conf"
    Then I should not see: 
      """
      loading config file: config.conf
      """
    And I should see: 
      """
      config file not found 
      """

  Scenario: Backtrace with --verbose option
    When I run "revenc --verbose mount bad_source bad_dest"
    Then the exit status should be 1
    And I should see matching: 
      """
      lib/(.*)/app.rb
      """

  Scenario: No backtrace without --verbose option
    When I run "revenc mount bad_source bad_dest --no-verbose"
    Then the exit status should be 1
    And I should not see: 
      """
      /app.rb:
      """
