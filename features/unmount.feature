@unmount_after @announce
Feature: Unmounting a reverse mounted encrypted folder using encfs

  As a user with an encfs encrypted data folder
  I need to unmount an encrypted folder
  In order to preserve resources

  Background: Successful mount
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    Given a directory named "encrypted_destination_folder"
    Given a valid encfs keyfile named "encfs6.xml"
    Given a file named "passphrase" with:
      """
      test
      """
    And I successfully run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    
  Scenario: Successful unmount
    When I run "revenc unmount encrypted_destination_folder"
    Then the exit status should be 0
    And the folder "encrypted_destination_folder" should not be mounted
    

  Scenario: Successful unmount dry run
    When I run "revenc --dry-run unmount encrypted_destination_folder"
    Then the exit status should be 0
    And the folder "encrypted_destination_folder" should be mounted

  Scenario: Unmount folder not specified
    When I run "revenc unmount"
    Then the exit status should be 1
    And the output should contain:
      """
      mountpoint not specified
      """

  Scenario: Unmount folder doesn't exist
    Given a directory named "encrypted_destination_folder"
    When I run "revenc unmount unencrypted_source_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      folder not found
      """

  Scenario: Missing executable
    Given a file named "revenc.conf" with:
      """
      unmount:
        executable: missing_bin_file
      """
    When I run "revenc unmount unencrypted_source_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      executable not found
      """
