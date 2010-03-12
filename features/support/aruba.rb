require 'aruba'
require 'fileutils'

APP_BIN_PATH = File.join(ENV['PWD'], 'bin', 'revenc')

module Aruba
  module Api

   alias_method :old_run, :run

    # override aruba 
    def run(cmd)
      
      # run development version in verbose mode
      cmd = cmd.gsub(/^revenc/, "#{APP_BIN_PATH} --verbose")

      # run original aruba 'run' 
      old_run(cmd)
    end
  end
end
