require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Revenc do
  
  describe 'version' do

    it "should return a string formatted '#.#.#'" do
      Revenc::version.should match(/(^[\d]+\.[\d]+\.[\d]+$)/)
    end

  end

end
