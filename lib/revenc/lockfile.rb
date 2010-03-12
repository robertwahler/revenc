module Revenc

  class Lockfile
    attr_accessor :lockfile

    def initialize(lockfile=nil)
      raise ArgumentError, "lockfile not specified" unless lockfile
      @lockfile = lockfile
    end

    def locked?
      return false unless File.exists?(lockfile)
      result = false
      open(lockfile, 'w') do |f|
        # exclusive non-blocking lock
        result = !lock(f, File::LOCK_EX | File::LOCK_NB)
      end
      result
    end

    # flock, get a file lock
    #
    # Typical usage:
    #
    #     open('output', 'w') do |f|
    #       flock(f, File::LOCK_EX) do |f|
    #       f << "write to file"
    #       end
    #     end
    def lock(file, mode)
      result = file.flock(mode)
      if result
        begin
          yield file if block_given?
        ensure
          file.flock(File::LOCK_UN)
        end
      end
      return result
    end
  end

  class Mutex < Lockfile

    def initialize(lockfile='revenc.lck')
      super lockfile
    end

    def execute
      result = false
      begin
        open(@lockfile, 'w') do |f|
          # exclusive non-blocking lock
          result = lock(f, File::LOCK_EX | File::LOCK_NB) do |f|
            yield if block_given?
          end
        end
      ensure
        # clean up but only if we have a positive result meaning we wrote the lockfile
        FileUtils.rm(@lockfile) if (result && File.exists?(@lockfile))
      end
      result
    end
  end

end
