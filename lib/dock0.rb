require 'yaml'
require 'fileutils'
require 'English'

##
# Dock0 provides an interface for building Arch images
module Dock0
  class << self
    ##
    # Insert a helper .new() method for creating a new Dock0 object

    def new(*args)
      Dock0::Image.new(*args)
    end
  end

  ##
  # Default config for images
  DEFAULT_CONFIG = {
    'paths' => {
      'device' => '/dev/xvdc',
      'mount' => '/opt/target',
      'build_file' => '/opt/build_file',
      'build' => '/opt/build_file_mount',
      'package_list' => './packages',
      'overlay' => './overlay',
      'scripts' => './scripts'
    },
    'root_size' => 512
  }

  ##
  # An Image is an Arch system being built
  class Image
    attr_reader :device_path, :config, :stamp

    ##
    # Make a new Image object with the given config

    def initialize(*configs)
      @config = configs.each_with_object(DEFAULT_CONFIG.dup) do |path, obj|
        new = YAML.load(File.read(path))
        next unless new
        obj.merge! new
      end
      @stamp = Time.new.strftime '%F-%H%M'
    end

    def run(cmd)
      results = `#{cmd} 2>&1`
      return results if $CHILD_STATUS.success?
      fail "Failed running #{cmd}:\n#{results}"
    end

    def run_chroot(cmd)
      run "arch-chroot #{@config['paths']['build']} #{cmd}"
    end

    def prepare_device
      puts "Making new filesystem on #{@config['paths']['device']}"
      run "mkfs.ext4 -F #{@config['paths']['device']}"
      puts "Mounting filesystem on #{@config['paths']['mount']}"
      FileUtils.mkdir_p @config['paths']['mount']
      run "mount #{@config['paths']['device']} #{@config['paths']['mount']}"
    end

    def prepare_root
      puts "Making build FS at #{@config['paths']['build_file']}"
      run "dd if=/dev/zero of=#{@config['paths']['build_file']} \
        bs=1M count=#{@config['root_size']}"
      run "mkfs.ext2 -F #{@config['paths']['build_file']}"
      puts "Mounting FS at #{@config['paths']['build']}"
      FileUtils.mkdir_p @config['paths']['build']
      run "mount #{@config['paths']['build_file']} \
        #{@config['paths']['build']}"
    end

    def install_packages
      File.read(@config['paths']['package_list']).split("\n").each do |package|
        puts "Installing #{package}"
        run "pacstrap -G -M #{@config['paths']['build']} #{package}"
      end
    end

    def apply_overlay
      puts "Applying overlay from #{@config['paths']['overlay']}"
      overlay_path = @config['paths']['overlay'] + '/.'
      FileUtils.cp_r overlay_path, @config['paths']['build']
      File.open("#{@config['paths']['build']}/.stamp", 'w') do |fh|
        fh.write @stamp
      end
    end

    def run_scripts
      Dir.glob(@config['paths']['scripts'] + '/*.rb').each do |script|
        puts "Running #{script}"
        instance_eval File.read(script), script, 0
      end
    end

    def run_commands
      cmds = @config.fetch('commands', {})
      cmds.fetch('chroot', []).each do |cmd|
        puts "Running #{cmd} in chroot"
        run_chroot cmd
      end
      cmds.fetch('host', []).each do |cmd|
        puts "Running #{cmd} on host"
        run cmd
      end
    end

    def finalize
      puts 'Packing up root FS'
      mount_path = @config['paths']['mount']
      squash_path = "#{mount_path}/#{@stamp}.fs.sfs"
      run "umount #{@config['paths']['build']}"
      run "mksquashfs #{@config['paths']['build_file']} #{squash_path}"
      File.symlink "#{@stamp}.fs.sfs", "#{mount_path}/root.fs.sfs"
    end

    def cleanup
      puts 'Removing temporary build image'
      File.unlink @config['paths']['build_file']
      puts 'Unmounting target device'
      run "umount #{@config['paths']['mount']}"
    end

    def easy_mode
      prepare_device
      prepare_root
      install_packages
      apply_overlay
      run_scripts
      run_commands
      sleep 5
      finalize
      cleanup
    end
  end
end
