# require all files here
require 'rbconfig'
require 'revenc/core/hash'
require 'revenc/core/array'
require 'revenc/app'
require 'revenc/settings'
require 'revenc/io'
require 'revenc/errors'
require 'revenc/encfs_wrapper'

# Master namespace
module Revenc

  # Contents of the VERSION file
  #
  # Example format: 0.0.1
  #
  # @return [String] the contents of the version file in #.#.# format
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read.strip
    end
  end

  # Platform constants
  unless defined?(Revenc::WINDOWS)
    WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/i
    CYGWIN = RbConfig::CONFIG['host_os'] =~ /cygwin/i
  end

end

