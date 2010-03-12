require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Revenc::Errors do
  
  before(:each) do
    @error_obj = Revenc::Errors.new
  end
  
  it "should be empty when created" do
    @error_obj.should be_empty
  end

  it "should return a count of the errors" do
    @error_obj.should be_empty
    @error_obj.add(:test_error1)
    @error_obj.add(:test_error2)
    @error_obj.should_not be_empty
    @error_obj.size.should == 2
  end

  it "should clear the errors" do
    @error_obj.should be_empty
    @error_obj.add(:test_error1)
    @error_obj.add(:test_error2)
    @error_obj.should_not be_empty
    @error_obj.size.should be(2)
    @error_obj.clear
    @error_obj.should be_empty
    @error_obj.size.should be(0)
  end

  it "should return the errors in full sentences for errors on symbol" do
    @error_obj.should be_empty
    @error_obj.add(:test_error1, "Error no 1")
    @error_obj.add(:test_error2, "Error no 2")
    @error_obj.size.should be(2)
    @error_obj.to_sentences.should == "test error1 Error no 1\ntest error2 Error no 2"
  end

  it "should return the errors in full sentences for errors on class names" do
    @error_obj.should be_empty
    @error_obj.add(@error_obj, "error no 1")
    @error_obj.add(@error_obj, "error no 2")
    @error_obj.size.should be(2)
    @error_obj.to_sentences.should == "errors error no 1\nerrors error no 2"
  end

end


