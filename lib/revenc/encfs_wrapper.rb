module Revenc

  class EncfsWrapper

    def initialize(base_dir, options)
      raise ArgumentError, "Options should be a hash" unless options.is_a?(Hash)
      @base_dir = base_dir
      @options = options
    end

    def mount(source=nil, mount_point_folder=nil)
      mount_point_options = @options || {}
      mount_point_options = mount_point_options.merge(@options[:mount].dup) if @options[:mount]

      # add params from config file if not specified
      source = (mount_point_options[:source] ? mount_point_options[:source][:name] : nil) unless source
      mount_point_folder = (mount_point_options[:mountpoint] ? mount_point_options[:mountpoint][:name] : nil) unless mount_point_folder

      # sanity check params
      raise "source folder not specified" unless source
      raise "mountpoint not specified" unless mount_point_folder

      mount_point = MountPoint.new(mount_point_folder, source, mount_point_options.merge(@options))

      if @options[:verbose]
        puts "mount: source=#{mount_point.source.name}".cyan
        puts "mount: mountpoint=#{mount_point.name}".cyan
        puts "mount: passphrasefile=#{mount_point.passphrasefile.name}".cyan
        puts "mount: keyfile=#{mount_point.keyfile.name}".cyan
        puts "mount: cmd=#{mount_point.cmd}".cyan
        puts "mount: executable=#{mount_point.executable}".cyan
      end

      mount_point.execute
    end

    def unmount(foldername = nil)
      unmount_point_options = @options || {}
      unmount_point_options = unmount_point_options.merge(@options[:unmount].dup) if @options[:unmount]
      mount_point_options = @options[:mount] ? @options[:mount].dup : {}

      # add param from config file if not specified, try specific unmount
      foldername = (unmount_point_options[:mountpoint] ? unmount_point_options[:mountpoint][:name] : nil) unless foldername
      # fallback to mount.mountpoint if specified
      foldername = (mount_point_options[:mountpoint] ? mount_point_options[:mountpoint][:name] : nil) unless foldername

      # sanity check params
      raise "mountpoint not specified" unless foldername

      unmount_point = UnmountPoint.new(foldername, unmount_point_options)

      if @options[:verbose]
        puts "unmount: mountpoint=#{unmount_point.mountpoint.name}".cyan
        puts "unmount: cmd=#{unmount_point.cmd}".cyan
        puts "unmount: executable=#{unmount_point.executable}".cyan
      end

      unmount_point.execute
    end

    def copy(source=nil, destination=nil)
      copy_options = @options || {}
      copy_options = copy_options.merge(@options[:copy].dup) if @options[:copy]
      mount_point_options = @options[:mount] ? @options[:mount].dup : {}

      # add params from config file if not specified
      source = (copy_options[:source] ? copy_options[:source][:name] : nil) unless source
      # fallback
      source = (mount_point_options[:mountpoint] ? mount_point_options[:mountpoint][:name] : nil) unless source
      destination = (copy_options[:destination] ? copy_options[:destination][:name] : nil)  unless destination

      # sanity check params
      raise "source folder not specified" unless source
      raise "destination not specified" unless destination

      copy_options = copy_options.merge(:mountpoint => mount_point_options[:mountpoint][:name]) if mount_point_options[:mountpoint]
      copy_folder = CopySourceFolder.new(source, destination, copy_options)

      if @options[:verbose]
        puts "copy: source=#{copy_folder.name}".cyan
        puts "copy: destination=#{copy_folder.destination.name}".cyan
        puts "copy: cmd=#{copy_folder.cmd}".cyan
        puts "copy: executable=#{copy_folder.executable}".cyan
      end

      copy_folder.execute
    end

  end

end

