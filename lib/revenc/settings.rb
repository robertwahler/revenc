require 'yaml'

module Revenc

  class Settings

    def initialize(working_dir, options={})
      @working_dir = working_dir
      @options = options
      configure
    end

    def options
      @options
    end

  private

    # read options from YAML config
    def configure

      # config file default options
      configuration = {
                        :options => {
                          :verbose => false,
                          :coloring => 'AUTO'
                        },
                        :mount => {
                          :source => {
                            :name => nil
                          },
                          :mountpoint => {
                            :name => nil
                          },
                          :passphrasefile => {
                            :name => 'passphrase'
                          },
                          :keyfile => {
                            :name => 'encfs6.xml'
                          },
                          :cmd => nil,
                          :executable => nil
                        },
                        :unmount => {
                          :mountpoint => {
                            :name => nil
                          },
                          :cmd => nil,
                          :executable => nil
                        },
                        :copy => {
                          :source => {
                            :name => nil
                          },
                          :destination => {
                            :name => nil
                          },
                          :cmd => nil,
                          :executable => nil
                        }
                      }

      # set default config if not given on command line
      config = @options[:config]
      unless config
        config = [
                   File.join(@working_dir, "revenc.conf"),
                   File.join(@working_dir, ".revenc.conf"),
                   File.join(@working_dir, "config", "revenc.conf"),
                   File.expand_path(File.join("~", ".revenc.conf"))
                 ].detect { |filename| File.exists?(filename) }
      end

      if config && File.exists?(config)
        # rewrite options full path for config for later use
        @options[:config] = config

        # load options from the config file, overwriting hard-coded defaults
        config_contents = YAML::load(File.open(config))
        configuration.merge!(config_contents.symbolize_keys!) if config_contents && config_contents.is_a?(Hash)
      else
        # user specified a config file?, no error if user did not specify config file
        raise "config file not found" if @options[:config]
      end

      # the command line options override options read from the config file
      @options = configuration[:options].merge!(@options)
      @options.symbolize_keys!

      # mount, unmount and copy configuration hashes
      @options[:mount] = configuration[:mount].recursively_symbolize_keys! if configuration[:mount]
      @options[:unmount] = configuration[:unmount].recursively_symbolize_keys! if configuration[:unmount]
      @options[:copy] = configuration[:copy].recursively_symbolize_keys! if configuration[:copy]
    end

  end

end
