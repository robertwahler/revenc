@announce
Feature: Configuration via yaml file

  In order to configure options
  As an interactive user or automated script
  The program should process configuration options via yaml
  These options should override hard coded defaults but not command line options

  Background: A valid config file
    Given a file named "revenc.conf" with:
      """
      mount:
        source:
          name: source_folder_name
        mountpoint:
          name: destination_folder_name
        passphrasefile:
          name: testme1.conf
        keyfile:
          name: encfs6.xml
        executable: echo
        cmd: cat <%= passphrasefile.name %> | ENCFS6_CONFIG=<%= keyfile.name %> <%= executable %> --stdinpass --reverse <%= source.name %> <%= mountpoint.name %> -- -o ro
      unmount:
        mountpoint:
          name: defaults_to_mount_mountpoint
        executable: echo
        cmd: <%= executable %> -u <%= name %>
      copy:
        source:
          name: copy_source_defaults_to_mount_mountpoint
        destination:
          name: copy_to_destination
        executable: echo
        cmd: <%= executable %> -e ssh --bwlimit=16 --perms --links --times --recursive --verbose --compress --stats --human-readable --inplace <%= source.name %> <%= destination.name %>
      """

  Scenario: Mount with a config file
    When I run `revenc --verbose --dry-run mount`
    Then the output should contain:
      """
      mount: source=source_folder_name
      mount: mountpoint=destination_folder_name
      mount: passphrasefile=testme1.conf
      mount: keyfile=encfs6.xml
      mount: cmd=cat testme1.conf | ENCFS6_CONFIG=encfs6.xml /bin/echo --stdinpass --reverse source_folder_name destination_folder_name -- -o ro
      mount: executable=/bin/echo
      """

  Scenario: Unmount with a config file
    When I run `revenc unmount --verbose --dry-run`
    Then the output should contain:
      """
      unmount: mountpoint=defaults_to_mount_mountpoint
      unmount: cmd=/bin/echo -u defaults_to_mount_mountpoint
      unmount: executable=/bin/echo
      """

  Scenario: Unmount with a config file missing unmount.mountpoint
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: unmount_mountpoint_defaults_to_me
      """
    When I run `revenc unmount --verbose --dry-run`
    Then the output should contain:
      """
      unmount: mountpoint=unmount_mountpoint_defaults_to_me
      """

  Scenario: Copy with a config file
    When I run `revenc copy --verbose --dry-run`
    Then the output should contain:
      """
      copy: source=copy_source_defaults_to_mount_mountpoint
      copy: destination=copy_to_destination
      copy: cmd=/bin/echo -e ssh --bwlimit=16 --perms --links --times --recursive --verbose --compress --stats --human-readable --inplace copy_source_defaults_to_mount_mountpoint copy_to_destination
      copy: executable=/bin/echo
      """

  Scenario: Copy with a config file missing source
    Given a file named "revenc.conf" with:
      """
      mount:
        mountpoint:
          name: copy_source_defaults_to_me
      copy:
        destination:
          name: copy_to_destination
      """
    When I run `revenc copy --verbose --dry-run`
    Then the output should contain:
      """
      copy: source=copy_source_defaults_to_me
      copy: destination=copy_to_destination
      """

  Scenario: Config file specified via the command line
