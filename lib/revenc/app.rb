require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module Revenc

  AVAILABLE_ACTIONS = %w[mount unmount copy]

  class App

    def initialize(working_dir, argv=[], options={})
      @working_dir = working_dir
      @options = options
      @argv = argv
      if @options[:verbose]
        puts "working_dir: #{@working_dir}".cyan
        puts "options: #{@options.inspect}".cyan
        puts "base_dir: #{@options[:base_dir]}".cyan if @options[:base_dir]
        puts "config file: #{@options[:config]}".cyan if @options[:config]
      end
      $stdout.sync = true
    end

    def execute
      begin

        if action_argument_required?
          action = @argv.shift
          args = @argv

          unless AVAILABLE_ACTIONS.include?(action)
            if action.nil?
              puts "revenc action required"
            else
              puts "revenc invalid action: #{action}"
            end
            puts "revenc --help for more information"
            exit 1
          end
          puts "revenc run action: #{action} #{args.join(' ')}".cyan if @options[:verbose]
          raise "action #{action} not implemented" unless respond_to?(action)
          result = send(action, args)
        else
          #
          # default action if action_argument_required? is false
          #
          result = 0
        end

        if result.is_a?(Numeric)
          exit(result)
        else
          # handle all other return types
          exit(result ? 0 : 1)
        end

      rescue SystemExit => e
        # This is the normal exit point, exit code from the send result
        # or exit from another point in the system
        puts "revenc run system exit: #{e}, status code: #{e.status}".green if @options[:verbose]
        exit(e.status)
      rescue Exception => e
        STDERR.puts("revenc command failed, error(s) follow:")
        STDERR.puts("#{e.message}".red)
        STDERR.puts("Use '--verbose' for backtrace.") unless @options[:verbose]
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

    #
    # app commands start
    #
    # TODO: Add status command, use encfsctl

    def mount
      EncfsWrapper.new(@base_dir, @options).mount(ARGV.shift, ARGV.shift)
    end

    def unmount
      EncfsWrapper.new(@base_dir, @options).unmount(ARGV.shift)
    end

    def copy
      EncfsWrapper.new(@base_dir, @options).copy(ARGV.shift, ARGV.shift)
    end
    
    #
    # app commands end
    #

  private

    # true if application requires an action to be specified on the command line
    def action_argument_required?
      !AVAILABLE_ACTIONS.empty?
    end

  end
end
