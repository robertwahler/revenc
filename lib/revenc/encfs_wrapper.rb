module Revenc

  class EncfsWrapper

    def initialize(base_dir, options)
      raise ArgumentError, "Options should be a hash" unless options.is_a?(Hash)
      @base_dir = base_dir
      @options = options
    end

    def mount(source=nil, mount_point_folder=nil)

      # add params from config file if not specified
      source = configatron.mount.source.name unless source
      mount_point_folder = configatron.mount.mountpoint.name unless mount_point_folder

      # sanity check params
      raise "source folder not specified" unless source
      raise "mountpoint not specified" unless mount_point_folder

      mount_point_options = @options.merge(:passphrasefile => configatron.mount.passphrasefile.name)
      mount_point_options = mount_point_options.merge(:keyfile => configatron.mount.keyfile.name)
      mount_point_options = mount_point_options.merge(:cmd => configatron.mount.cmd) if configatron.mount.cmd
      mount_point_options = mount_point_options.merge(:executable => configatron.mount.executable) if configatron.mount.executable

      mount_point = MountPoint.new(mount_point_folder, source, mount_point_options)

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

      # add param from config file if not specified, try specific unmount
      foldername = configatron.unmount.mountpoint.name unless foldername
      # fallback to mount.mountpoint if specified
      foldername = configatron.mount.mountpoint.name unless foldername

      # sanity check params
      raise "mountpoint not specified" unless foldername

      unmount_point_options = @options || {}
      unmount_point_options = unmount_point_options.merge(:cmd => configatron.unmount.cmd) if configatron.umount.cmd
      unmount_point_options = unmount_point_options.merge(:executable => configatron.unmount.executable) if configatron.umount.executable
      unmount_point = UnmountPoint.new(foldername, unmount_point_options)

      if @options[:verbose]
        puts "unmount: mountpoint=#{unmount_point.mountpoint.name}".cyan
        puts "unmount: cmd=#{unmount_point.cmd}".cyan
        puts "unmount: executable=#{unmount_point.executable}".cyan
      end

      unmount_point.execute
    end

    def copy(source=nil, destination=nil)

      # add params from config file if not specified
      source = configatron.copy.source.name unless source
      # fallback
      source = configatron.mount.mountpoint.name unless source
      destination = configatron.copy.destination.name unless destination

      # sanity check params
      raise "source folder not specified" unless source
      raise "destination not specified" unless destination

      copy_options = @options || {}
      copy_options = copy_options.merge(:cmd => configatron.copy.cmd) if configatron.copy.cmd
      copy_options = copy_options.merge(:executable => configatron.copy.executable) if configatron.copy.executable
      copy_options = copy_options.merge(:mountpoint => configatron.mount.mountpoint.name) if configatron.mount.mountpoint.name

      copy_folder = CopySourceFolder.new( source, destination, copy_options)

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

