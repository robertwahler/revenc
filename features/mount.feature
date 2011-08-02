@announce
Feature: Reverse mount encrypted folder using encfs

  As a user with unencrypted data
  I need to mount an encrypted folder from an unencrypted folder
  In order to backup the encrypted folder to untrusted systems

  @unmount_after
  Scenario: Successful mount
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    Given a directory named "encrypted_destination_folder"
    Given a valid encfs keyfile named "encfs6.xml"
    Given a file named "passphrase" with:
      """
      test
      """
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the output should not contain "For more information, see the man page encfs(1)"
    And the exit status should be 0

  Scenario: Successful mount dry run
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    Given a directory named "encrypted_destination_folder"
    Given a valid encfs keyfile named "encfs6.xml"
    Given a file named "passphrase" with:
      """
      test
      """
    When I run "revenc --dry-run mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 0
    And the folder "encrypted_destination_folder" should not be mounted

  Scenario: Source folder not specified
    When I run "revenc mount"
    Then the exit status should be 1
    And the output should contain:
      """
      source folder not specified
      """

  Scenario: Destination mount point not specified
    When I run "revenc mount unencrypted_source_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      mountpoint not specified
      """

  Scenario: Source folder doesn't exist
    Given a directory named "encrypted_destination_folder"
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      source folder not found
      """

  Scenario: Destination mount point doesn't exist
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      mount point not found
      """

  Scenario: Destination mount point is not empty
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    Given a directory named "encrypted_destination_folder"
    Given an empty file named "encrypted_destination_folder/should_not_be_here.txt"
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      mount point is not empty
      """

  Scenario: Passphrase file not found
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    Given a directory named "encrypted_destination_folder"
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      mount point passphrase file not found
      """

  Scenario: Passphrase file is empty
    Given a directory named "unencrypted_source_folder"
    Given an empty file named "unencrypted_source_folder/test_data.txt"
    Given a directory named "encrypted_destination_folder"
    Given an empty file named "passphrase"
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      mount point passphrase file is empty
      """

  Scenario: Key file not found
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      key file not found
      """

  Scenario: Key file is empty
    Given an empty file named "encfs6.xml"
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      key file is empty
      """

  Scenario: Missing executable
    Given a file named "revenc.conf" with:
      """
      mount:
        executable: missing_bin_file
      """
    When I run "revenc mount unencrypted_source_folder encrypted_destination_folder"
    Then the exit status should be 1
    And the output should contain:
      """
      executable not found
      """
