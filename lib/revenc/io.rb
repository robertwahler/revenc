module Revenc

  class BasicAction

    def initialize(name=nil, options={})
      raise ArgumentError, "Options should be a hash" unless options.is_a?(Hash)
      @name = name
      @options = options
    end

    def name
      @name
    end

    def name=(value)
      @name = value
    end

    def options
      @options ||= {}
    end

    def options=(value)
      @options = value
    end

    def errors
      @errors ||= Errors.new
    end

    def exists?
      false
    end

    def validate
    end

    def valid?
      errors.clear
      validate
      errors.empty?
    end

    def cmd
      return nil unless @cmd
      # process ERB
      render(@cmd)
    end

    def cmd=(value)
      @cmd = value
    end

  private

    def system_cmd(cmd=nil)
      raise "ERROR: cmd not given" unless cmd
      return true if options[:dry_run]
      system cmd
    end

    # Runs the YAML file through ERB
    def render(value, b = binding)
      ERB.new(value).result(b)
    end

  end

  class FileSystemEntity < BasicAction

    # return fully qualified name
    def name
      return @name unless (@name && File.exists?(@name))
      File.expand_path(@name)
    end

    def exists?
      File.exists?(name) if name
    end

  end

  class TextFile < FileSystemEntity


    def empty?
      return true unless exists?

      contents = nil
      File.open(@name, "r") do |f|
        contents = f.read
      end 
      contents.empty?
    end

    def validate
      errors.add(self, "filename not specified") if @name.nil?
      errors.add(self, "not found") unless exists?
    end
  end

  class PassphraseFile < TextFile

    def initialize(name='passphrase', options={})
      super name, options
    end

    def validate
      super 
      errors.add(self, "is empty") if empty?
    end
  end

  class KeyFile < TextFile

    def initialize(name='encfs6.xml', options={})
      super name, options
    end

    def validate
      super 
      errors.add(self, "is empty") if exists? && empty?
    end
  end

  class FileFolder < FileSystemEntity

    def exists?
      !@name.nil? && File.directory?(@name)
    end

    def empty?
      return true unless exists?
      Dir.entries(@name).sort == [".", ".."].sort
    end

    def validate
      errors.add(self, "not found") unless exists?
    end
  end

  class SourceFolder < FileFolder

    def validate
      super
      errors.add(self, "is empty") if exists? && empty?
    end
  end

  class ActionFolder < FileFolder
    attr_accessor :passphrasefile
    attr_accessor :keyfile

    def initialize(name=nil, options={})
      super
      @passphrasefile = PassphraseFile.new(options[:passphrasefile])
      @keyfile = KeyFile.new(options[:keyfile])
      @cmd = options[:cmd]
      @executable = options[:executable]
    end

    def validate
      super
      errors.add(self, "executable filename not specified") unless @executable
      errors.add(self, "#{@executable} executable not found") if executable.empty?
      errors.add(self, "cmd not specified") unless cmd
    end

    def executable
      return nil unless @executable
      result = `which #{@executable}`
      result.strip
    end

    # run the action if valid and return true if successful
    def execute
      raise errors.to_sentences unless valid?
      
      # default failing command
      result = false
      
      # protect command from recursion
      mutex = Revenc::Mutex.new
      lock_sucessful = mutex.execute do
        result = system_cmd(cmd)
      end
      
      raise "action failed, lock file present" unless lock_sucessful
      result
    end
  end

  class MountPoint < ActionFolder
    attr_accessor :source

    def initialize(name=nil, source_folder_name=nil, options={})
      super name, options
      @source = SourceFolder.new(source_folder_name)
      @cmd = options[:cmd] || "cat <%= passphrasefile.name %> | ENCFS6_CONFIG=<%= keyfile.name %> \
                              <%= executable %> --stdinpass --reverse <%= source.name %> <%= mountpoint.name %> -- -o ro"
      @executable = options[:executable] || 'encfs'
    end

    # allow clarity in config files, instead of <%= name %> you can use <%= mountpoint.name %>
    def mountpoint
      self
    end

    def validate
      super
      errors.add(self, "is not empty") unless empty?
      errors.add(self, source.errors.to_sentences) unless source.valid?
      errors.add(self, keyfile.errors.to_sentences) unless keyfile.valid?
      errors.add(self, passphrasefile.errors.to_sentences) unless passphrasefile.valid?
    end

  end

  class UnmountPoint < ActionFolder

    def initialize(name=nil, options={})
      super
      @cmd = options[:cmd] || "<%= executable %> -u <%= mountpoint.name %>"
      @executable = options[:executable] || 'fusermount'
    end
    
    # allow clarity in config files, instead of <%= name %> you can use <%= mountpoint.name %>
    def mountpoint
      self
    end

  end

  class DestinationPoint < BasicAction
  end

  class CopySourceFolder < ActionFolder
    attr_accessor :destination
    attr_accessor :mountpoint

    def initialize(name=nil, destination_name=nil, options={})
      super name, options
      @destination = DestinationPoint.new(destination_name)
      @mountpoint = MountPoint.new(options[:mountpoint])
      @cmd = options[:cmd] || "<%= executable %> -r <%= source.name %> <%= destination.name %>"
      @executable = options[:executable] || 'cp'
    end
    
    # allow clarity in config files, instead of <%= name %> you can use <%= source.name %>
    def source
      self
    end

    def validate
      super
      errors.add(self, "is empty") if exists? && empty?
      errors.add(self, "mountpoint not found") if (mountpoint.name && !mountpoint.exists?)
      errors.add(self, "mountpoint is empty") if (mountpoint.name && mountpoint.exists? && mountpoint.empty?)
      errors.add(self, destination.errors.to_sentences) unless destination.valid?
    end

  end

end

