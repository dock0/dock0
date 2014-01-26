require 'yaml'
require 'fileutils'

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
  # An Image is an Arch system being built

  class Image
    attr_reader :device_path, :config

    ##
    # Make a new Image object with the given config

    def initialize(*configs)
      @config = configs.each_with_object({}) do |path, obj|
        obj.merge! YAML.load(File.read(path))
      end
    end

    def prepare_device
      puts "Making new filesystem on #{@config['paths']['device']}"
      `mkfs.ext2 #{@config['paths']['device']} 2>&1`
      puts "Mounting filesystem on #{@config['paths']['mount']}"
      FileUtils.mkdir_p @config['paths']['mount']
      `mount #{@config['paths']['device']} #{@config['paths']['mount']} 2>&1`
      puts "Making build FS at #{@config['paths']['build_file']}"
      `dd if=/dev/zero of=#{@config['paths']['build_file']} bs=1M count=#{@config['root_size']} 2>&1`
      `mkfs.ext2 -f #{@config['paths']['build_file']} 2>&1`
      puts "Mounting FS at #{@config['paths']['build']}"
      `mount #{@config['paths']['build_file']} #{@config['paths']['build']} 2>&1`
    end

    def install_packages
      File.read(@config['paths']['package_list']).split("\n").each do |package|
        puts "Installing #{package}"
        `pacstrap -G -M #{@config['paths']['build']} #{package} 2>&1`
      end
    end

    def apply_overlay
      puts "Applying overlay from #{@config['paths']['overlay']}"
      overlay_path = @config['paths']['overlay'] + '/.'
      FileUtils.cp_r overlay_path, @config['paths']['build']
    end

    def run_scripts
      Dir.glob(@config['paths']['scripts'] + '/*.rb').each do |script|
        puts "Running #{script}"
        instance_eval File.read(script), script, 0
      end
    end

    def run_commands
      cmds = @config['commands']
      cmds.fetch('chroot', []).each do |cmd|
        puts "Running #{cmd} in chroot"
        `arch_chroot #{@config['path']['build']} #{cmd} 2>&1`
      end
      cmds.fetch('host', []).each do |cmd|
        puts "Running #{cmd} on host"
        `#{cmd} 2>&1`
      end
    end

    def finalize
      puts "Packing up root FS"
      `umount #{@config['paths']['build']} 2>&1`
      `mksquashfs #{@config['paths']['build_file']} #{@config['paths']['mount']}/root.fs.sfs 2>&1`
      puts "Unmounting target device"
      `umount #{@config['paths']['mount']}`
    end

    def easy_mode
      prepare_device
      install_packages
      apply_overlay
      run_scripts
      run_commands
      finalize
    end
  end
end
