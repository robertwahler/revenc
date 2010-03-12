@announce
Feature: Copy encrypted data to another location via rsync

  As an interactive user or automated script
  The program should copy the encrypted data to another location
  And lock the process to prevent automated recursion on long running copy commands
  In order to backup the data and allow recovery of the unencrypted data

  Scenario: Sucessful copy
    Given a directory named "encrypted_source_folder"
    Given a directory named "encrypted_destination"
    Given an empty file named "encrypted_source_folder/test_data1.txt"
    Given an empty file named "encrypted_source_folder/test_data2.txt"
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: encrypted_source_folder
      """
    When I run "revenc copy encrypted_source_folder encrypted_destination"
    Then the exit status should be 0
    And the following files should exist:
      | encrypted_destination/encrypted_source_folder/test_data1.txt |
      | encrypted_destination/encrypted_source_folder/test_data2.txt |

  Scenario: Sucessful copy dry run
    Given a directory named "encrypted_source_folder"
    Given a directory named "encrypted_destination"
    Given an empty file named "encrypted_source_folder/test_data1.txt"
    Given an empty file named "encrypted_source_folder/test_data2.txt"
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: encrypted_source_folder
      """
    When I run "revenc copy --dry-run encrypted_source_folder encrypted_destination"
    Then the exit status should be 0
    And the following files should not exist:
      | encrypted_destination/encrypted_source_folder/test_data1.txt |
      | encrypted_destination/encrypted_source_folder/test_data2.txt |

  Scenario: Copy already running (mutex/lock file check)
    Given a directory named "encrypted_source_folder"
    Given a directory named "encrypted_destination"
    Given an empty file named "encrypted_source_folder/test_data.txt"
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: encrypted_source_folder
      """
    When I run with a lock file present "revenc copy encrypted_source_folder encrypted_destination"
    Then the exit status should be 1
    And I should see:
      """
      action failed, lock file present
      """

  Scenario: Source folder not specified
    When I run "revenc copy"
    Then the exit status should be 1
    And I should see:
      """
      source folder not specified
      """

  Scenario: Destination not specified
    When I run "revenc copy encrypted_source_folder"
    Then the exit status should be 1
    And I should see:
      """
      destination not specified
      """

  Scenario: Source folder doesn't exist
    When I run "revenc copy encrypted_source_folder encrypted_destination"
    Then the exit status should be 1
    And I should see:
      """
      source folder not found
      """

  Scenario: Source folder is empty
    Given a directory named "encrypted_source_folder"
    When I run "revenc copy encrypted_source_folder encrypted_destination"
    Then the exit status should be 1
    And I should see:
      """
      source folder is empty
      """

  Scenario: Source folder contains files but mount point empty (not mounted)
    Given a directory named "copy_to_destination"
    Given a directory named "parent_folder"
    Given a directory named "parent_folder/encrypted_data_mountpoint"
    Given a directory named "parent_folder/plain_text_key_here"
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: parent_folder/encrypted_data_mountpoint
      copy:
        source:
          name: parent_folder
        destination:
          name: copy_to_destination
      """
    When I run "revenc copy --verbose --dry-run"
    Then I should see:
      """
      mountpoint is empty
      """

  Scenario: Source folder contains files, mountpoint does not exist
    Given a directory named "copy_to_destination"
    Given a directory named "parent_folder"
    Given a directory named "parent_folder/plain_text_key_here"
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: parent_folder/encrypted_data_mountpoint
      copy:
        source:
          name: parent_folder
        destination:
          name: copy_to_destination
      """
    When I run "revenc copy --verbose --dry-run"
    Then I should see:
      """
      mountpoint not found
      """

  Scenario: Source folder contains files, mountpoint not specified
    Given a directory named "copy_to_destination"
    Given a directory named "parent_folder"
    Given a directory named "parent_folder/plain_text_key_here"
    Given a file named "revenc.conf" with:
      """
      copy:
        source:
          name: parent_folder
        destination:
          name: copy_to_destination
      """
    When I run "revenc copy --verbose --dry-run"
    Then I should not see:
      """
      mountpoint not found
      """
    And I should not see:
      """
      mountpoint is empty
      """

  Scenario: Missing executable
    Given a file named "revenc.conf" with:
      """
      copy:
        executable: missing_bin_file
      """
    When I run "revenc copy encrypted_source_folder encrypted_destination"
    Then the exit status should be 1
    And I should see:
      """
      executable not found
      """
