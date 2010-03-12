$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'rubygems'

module Revenc

  # return the contents of the VERSION file
  # VERSION format: 0.0.0
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read
    end 
  end
  
end

require 'revenc/app'
require 'revenc/io'
require 'revenc/errors'
require 'revenc/lockfile'
require 'revenc/encfs_wrapper'
