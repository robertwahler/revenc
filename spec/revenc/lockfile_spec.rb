require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Revenc::Mutex do
  
  before(:each) do
    FileUtils.rm_rf(current_dir)
  end
  
  describe 'mutex' do

    it "should create a mutex, yield, and clean up" do
      in_current_dir do
        mutex = Revenc::Mutex.new
        result = mutex.execute do
          File.should be_file('revenc.lck')
          mutex.should be_locked
        end
        result.should be_true
        mutex.should_not be_locked
        File.should_not be_file('revenc.lck')
      end
    end

    it "should prevent recursion but not block" do
      in_current_dir do
        Revenc::Mutex.new.execute do
          File.should be_file('revenc.lck')

          mutext = Revenc::Mutex.new
          result = mutext.execute do
            # This block is protected, should not be here
            true.should be(false)
          end
          result.should be_false
          mutext.should be_locked
        end
        File.should_not be_file('revenc.lck')
      end
    end

  end
end


