require 'mutagem'
require 'revenc/io'

Given /^a valid encfs keyfile named "([^\"]*)"$/ do |filename|
  steps %Q{
    Given a file named "#{filename}" with:
      """
      <?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
      <!DOCTYPE boost_serialization>
      <boost_serialization signature="serialization::archive" version="4">
      <config class_id="0" tracking_level="1" version="20080816" object_id="_0">
              <creator>EncFS 1.5</creator>
              <cipherAlg class_id="1" tracking_level="0" version="0">
                      <name>ssl/aes</name>
                      <major>2</major>
                      <minor>2</minor>
              </cipherAlg>
              <nameAlg>
                      <name>nameio/null</name>
                      <major>1</major>
                      <minor>0</minor>
              </nameAlg>
              <keySize>128</keySize>
              <blockSize>1024</blockSize>
              <uniqueIV>0</uniqueIV>
              <chainedNameIV>0</chainedNameIV>
              <externalIVChaining>0</externalIVChaining>
              <blockMACBytes>0</blockMACBytes>
              <blockMACRandBytes>0</blockMACRandBytes>
              <allowHoles>1</allowHoles>
              <encodedKeySize>36</encodedKeySize>
              <encodedKeyData>
      unVmAfPQFd5t4cakBxbE7uosu4tzZbo8B513iGGNynzArOKM=
              </encodedKeyData>
              <saltLen>20</saltLen>
              <saltData>
      IcFy11sZw/w7juCI+Cro8AZVp6Q
              </saltData>
              <kdfIterations>97493</kdfIterations>
              <desiredKDFDuration>500</desiredKDFDuration>
      </config>
      </boost_serialization>
      """
  }
end

When /^I run with a lock file present "(.*)"$/ do |cmd|
  lockfile = File.join(current_dir, 'revenc.lck')
  Mutagem::Mutex.new(lockfile).execute do
    run_simple(unescape(cmd), false)
  end
end

Then /^the folder "([^\"]*)" should not be mounted$/ do |folder_name|
  folder = Revenc::FileFolder.new(File.join(current_dir, folder_name))
  folder.exists?.should be_true
  folder.should be_empty
end

Then /^the folder "([^\"]*)" should be mounted$/ do |folder_name|
  folder = Revenc::FileFolder.new(File.join(current_dir, folder_name))
  folder.exists?.should be_true
  folder.should_not be_empty
end
