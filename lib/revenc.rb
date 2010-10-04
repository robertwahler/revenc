# require all files here
require 'rubygems'
require 'revenc/app'
require 'revenc/io'
require 'revenc/errors'
require 'revenc/lockfile'
require 'revenc/encfs_wrapper'

# Master namespace
module Revenc

  # Contents of the VERSION file
  # VERSION example format: 0.0.1
  #
  # @return [String] version the contents of the version file in #.#.# format
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read
    end
  end
 
end

