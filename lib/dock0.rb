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
      system "mkfs.ext2 #{@config['paths']['device']}"
      puts "Mounting filesystem on #{@config['paths']['mount']}"
      FileUtils.mkdir_p @config['paths']['mount']
      system "mount #{@config['paths']['device']} #{@config['paths']['mount']}"
    end

    def install_packages
      File.read(@config['paths']['package_list']).split("\n").each do |package|
        puts "Installing #{package}"
        system "pacstrap -G -M #{@config['paths']['mount']} #{package}"
      end
    end

    def apply_overlay
      puts "Applying overlay from #{@config['paths']['overlay']}"
      overlay_path = @config['paths']['overlay'] + '/.'
      FileUtils.cp_r overlay_path, @config['paths']['mount']
    end

    def run_scripts
      Dir.glob(@config['paths']['scripts'] + '/*.rb').each do |script|
        puts "Running #{script}"
        load script
      end
    end

    def run_commands
      cmds = @config['commands']
      cmds.fetch('chroot', []).each do |cmd|
        puts "Running #{cmd} in chroot"
        system "arch_chroot #{@config['path']['mount']} #{cmd}"
      end
      cmds.fetch('host', []).each do |cmd|
        puts "Running #{cmd} on host"
        system "#{cmd}"
      end
    end

    def easy_mode
      prepare_device
      install_packages
      apply_overlay
      run_scripts
      run_commands
    end
  end
end
