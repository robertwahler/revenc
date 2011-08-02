require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Revenc::FileSystemEntity do

  before(:each) do
    FileUtils.rm_rf(current_dir)
  end

  describe Revenc::TextFile do

    it "should be valid" do
      filename = "text_file"
      write_file(filename, "passphrase")
      text_file = Revenc::TextFile.new(fullpath(filename))
      text_file.should be_valid
    end

    it "should return a fully qualified file name" do
      filename = "text_file"
      write_file(filename, "passphrase")
      relative_path_filename = File.join('tmp', 'aruba', filename)
      text_file = Revenc::TextFile.new(relative_path_filename)
      text_file.should be_valid
      text_file.name.should_not be(filename)
      text_file.name.should_not be(relative_path_filename)
      text_file.name.should == fullpath(filename)
    end

    it "should return a name for non-existing files" do
      filename = "text_file"
      relative_path_filename = File.join('tmp', 'aruba', filename)
      text_file = Revenc::TextFile.new(relative_path_filename)
      text_file.name.should_not be(filename)
      text_file.name.should be(relative_path_filename)
    end

    it "should be valid if empty" do
      filename = "text_file"
      write_file(filename, "")
      text_file = Revenc::TextFile.new(fullpath(filename))
      text_file.should be_valid
    end

    it "should not be valid if name missing" do
      text_file = Revenc::TextFile.new
      text_file.should_not be_valid
    end

    describe Revenc::PassphraseFile do

      it "should be valid" do
        filename = "text_file"
        write_file(filename, "passphrase")
        text_file = Revenc::PassphraseFile.new(fullpath(filename))
        text_file.should be_valid
      end

      it "should not be valid if empty" do
        filename = "text_file"
        write_file(filename, "")
        text_file = Revenc::PassphraseFile.new(fullpath(filename))
        text_file.exists?.should be(true)
        text_file.should_not be_valid
        text_file.errors.to_sentences.should match(/is empty/)
      end

    end

    describe Revenc::KeyFile do

      it "should be valid" do
        filename = "encfs6.xml"
        write_file(filename, "DOCTYPE boost_serialization")
        text_file = Revenc::KeyFile.new(fullpath(filename))
        text_file.should be_valid
      end

      it "should not be valid if empty" do
        filename = "encfs6.xml"
        write_file(filename, "")
        text_file = Revenc::KeyFile.new(fullpath(filename))
        text_file.exists?.should be(true)
        text_file.should_not be_valid
        text_file.errors.to_sentences.should match(/is empty/)
      end

    end

  end

  describe Revenc::FileFolder do

    it "should be valid if empty" do
      foldername = "folder1"
      create_dir(foldername)
      file_folder = Revenc::FileFolder.new(fullpath(foldername))
      file_folder.should be_valid
      file_folder.empty?.should be(true)
    end

    it "should return a fully qualified folder name" do
      foldername = "folder1"
      create_dir(foldername)
      relative_path_foldername = File.join('tmp', 'aruba', foldername)
      file_folder = Revenc::FileFolder.new(relative_path_foldername)
      file_folder.should be_valid
      file_folder.name.should_not be(foldername)
      file_folder.name.should_not be(relative_path_foldername)
      file_folder.name.should == fullpath(foldername)
    end

    it "should not be valid if missing" do
      foldername = "folder1"
      file_folder = Revenc::FileFolder.new(fullpath(foldername))
      file_folder.exists?.should be(false)
      file_folder.should_not be_valid
      file_folder.errors.to_sentences.should match(/not found/)
    end

    it "should return true on a call to empty? if folder missing" do
      foldername = "folder1"
      file_folder = Revenc::FileFolder.new(fullpath(foldername))
      file_folder.exists?.should be(false)
      file_folder.should_not be_valid
      file_folder.empty?.should be(true)
    end

    describe Revenc::ActionFolder do

      it "should process ERB in cmd" do
        foldername = "folder1"
        file_folder = Revenc::ActionFolder.new(fullpath(foldername))
        file_folder.exists?.should be(false)
        file_folder.cmd = "<%= \"hello world\" %>"
        file_folder.cmd.should == "hello world"
      end

      it "should process instance vars in ERB cmd" do
        foldername = "folder1"
        file_folder = Revenc::ActionFolder.new(fullpath(foldername))
        file_folder.exists?.should be(false)
        file_folder.cmd = "hello <%= name %>"
        file_folder.cmd.should eql("hello #{file_folder.name}")
        file_folder.cmd.should_not eql("hello ")
      end

      describe Revenc::MountPoint do

        it "should have an accessor 'mountpoint' equal to self" do
          foldername = "folder1"
          mountpoint = Revenc::MountPoint.new(fullpath(foldername))
          mountpoint.name.should eql(fullpath(foldername))
          mountpoint.mountpoint.name.should == mountpoint.name
        end

        it "should not be valid if encfs executable not found" do
          # stub out check for executable with double that can't find encfs
          double = Revenc::MountPoint.new
          double.stub!(:executable).and_return('')
          Revenc::MountPoint.stub!(:new).and_return(double)

          file_folder = Revenc::MountPoint.new
          file_folder.validate
          file_folder.errors.to_sentences.should match(/encfs executable not found/)
        end
      end

      describe Revenc::UnmountPoint do

        it "should not be valid if fusermount executable not found" do
          # stub out check for executable with double that can't find fusermount
          double = Revenc::UnmountPoint.new
          double.stub!(:executable).and_return('')
          Revenc::UnmountPoint.stub!(:new).and_return(double)

          file_folder = Revenc::UnmountPoint.new
          file_folder.validate
          file_folder.errors.to_sentences.should match(/fusermount executable not found/)
        end
      end
    end

  end
end

