Revenc
======

Mount an unencrypted folder as encrypted using EncFS and copy/synchronize the
encrypted files to untrusted destinations using rsync/cp

Background
----------

EncFS in reverse mode facilitates mounting an encrypted file system
from an unencrypted source folder.  This allows keeping your files unencrypted
in a trusted environment while gaining the ability to encrypt on demand
i.e. when you want to rsync encrypted files off-site to an untrusted system.

Revenc was jump-started by cloning from
[BasicApp](https://github.com/robertwahler/basic_app).

Why Revenc?
-----------

Revenc facilitates scripting EncFS reverse mounting and synchronizing by
providing a configuration framework and validating mounts before running tools
like rsync.

Benefits
--------

* Provides conventions for EncFS reverse mounting
* Validates mountpoints before copying to prevent "rsync --delete" commands
  from trying to sync empty folders
* Mount, unmount, and copy actions are protected by a mutex to prevent
  recursion on long running copy/sync operations.  (mount, unmount and
  copy actions will fail if another instance of revenc is blocking)
* Allow short, easy to remember command lines when used with configuration files.
  i.e. revenc mount, revenc unmount, revenc copy

Installation
------------

gem install revenc

Usage
-----

revenc action [options]

### Actions ###

#### Mount ####

Reverse mount using EncFS. Source and mountpoint are not required when
using a configuration file.

    Mount: revenc mount <unencrypted source> <empty mountpoint>

This calls the executable "encfs" with the following by default:

    cat <%= passphrasefile.name %> | ENCFS6_CONFIG=<%= keyfile.name %> \
    <%= executable %> --stdinpass --reverse <%= source.name %> \
    <%= mountpoint.name %> -- -o ro

#### Unmount ####

Unmount using EncFS. Mountpoint is required when specified by revenc.conf.

    Unmount: revenc unmount <mountpoint>

This calls the executable "fusermount" with the following by default:

    <%= executable %> -u <%= mountpoint.name %>

#### Copy ####

Recursive copy with "cp -r", for rsync copy, see examples.  Source and destination
are not required when specified by revenc.conf.

    Copy: revenc copy <source>  <destination>

This calls the executable "cp" with the following by default:

    <%= executable %> -r <%= source.name %> <%= destination.name %>

### Setup ###

The following is a walk through of the steps used to create the example project
"simple" in the examples folder.

    mkdir -p revenc/examples/simple/encrypted_mountpoint
    mkdir -p revenc/examples/simple/unencrypted_data
    mkdir -p revenc/examples/simple/copy_destination

    cd revenc/examples/simple

    echo "some stuff" > unencrypted_data/test_file1.txt
    echo "some more stuff" > unencrypted_data/test_file2.txt

### Create the EncFS passphrase file ###

You must supply EncFS with a passphrase in plain text. The passphrase is piped in on the command line
to EncFS.  This file can be stored anywhere on your trusted system.  Revenc expects it in the
current folder, use revenc.conf to supply a different location.

    echo "my_super_secret_PassPHRase" > passphrase
    chmod 600 passphrase

### Generate the EncFS key file ###

Generation of your key file is done once.  The same key is used for each mount action on the same
unencrypted source folder.  You need to keep a copy of your key available in order to restore encrypted files.
EncFS doesn't supply a method to fully automate the generation of the key file with so it needs
to be done manually.

NOTE: The ENCFS6_CONFIG var is needed to control where the key file is created.  The "${PWD}" is
used because EncFS expects full paths from the root folder.

    ENCFS6_CONFIG=./encfs6.xml encfs --reverse ${PWD}/unencrypted_data  ${PWD}/encrypted_mountpoint -- -o ro

You will see a message about encfs6.xml failing to load, this is OK.  You should now be at the EncFS
command prompt.  You can complete the key generation any way you like.  The following are the responses
used to generate the sample key.  Note the I opted to store filenames in plain text for clarity.

EncFS command prompt responses:

    x                              # expert mode
    1                              # AES
    128                            # key size
    1024                           # block size
    2                              # Null => no encryption of filenames
    my_super_secret_PassPHRase     # passphrase we stored in the step above
    my_super_secret_PassPHRase     # confirm passphrase


EncFS should generate encfs6.xml, mount the folder and return you to the command prompt. You can
now work with your encrypted files.

    ls encrypted_mountpoint

        test_file1.txt  test_file2.txt

    revenc unmount encrypted_mountpoint
    ls encrypted_mountpoint

        <no files here>

    revenc mount unencrypted_data encrypted_mountpoint
    ls encrypted_mountpoint

        test_file1.txt  test_file2.txt


    revenc copy encrypted_mountpoint copy_to_destination
    ls copy_to_destination

        test_file1.txt  test_file2.txt


### Configuration files ###

Revenc expects a passphrase file and the key file "encfs6.xml" to exist in the
current folder.  You can override these locations using the revenc.conf file.  Revenc
looks for its configuration file in the current folder. When you use configuration file,
you can ommit action parameters. For example:

    cd examples/rsync

    revenc mount
    revenc copy
    revenc unmount

The configuration file is YAML http://www.yaml.org/ format with ERB processing. You must
escape ERB in the action commands.  These need to be lazy loaded by Revenc. Unescaped
ERB is evaluated as the configuration file is read but before Revenc parses the commands.
See the example configuration file examples/rsync/revenc.conf.

The file features/configuration.feature has more details.

System Requirements
-------------------

* EncFS http://www.arg0.net/encfs  (tested on versions: 1.5, 1.6)

Run-time dependencies
---------------------

* Term-ansicolor for optional color output <http://github.com/flori/term-ansicolor>
* Mutagem for mutex support <http://github.com/robertwahler/mutagem>

Development dependencies
------------------------

* Bundler for dependency management <http://github.com/carlhuda/bundler>
* Rspec for unit testing <http://github.com/rspec/rspec>
* Cucumber for functional testing <http://github.com/cucumber/cucumber>
* Aruba for CLI testing <http://github.com/cucumber/aruba>

Copyright
---------

Copyright (c) 2010-2017 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
