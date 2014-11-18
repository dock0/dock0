require 'yaml'
require 'fileutils'
require 'English'

##
# An Image is an Arch system being built
module Dock0
  class Image
    attr_reader :device_path, :config, :stamp

    DEFAULT_CONFIG = {
      'paths' => {
        'build_file' => '/opt/build_file',
        'build' => '/opt/build_file_mount',
        'package_list' => './packages',
        'overlay' => './overlay',
        'scripts' => './scripts',
        'output' => './root.fs.sfs'
      },
      'fs' => {
        'size' => 512,
        'type' => 'ext4',
        'flags' => '-F'
      }
    }

    ##
    # Make a new Image object with the given config

    def initialize(*configs)
      @config = configs.each_with_object(DEFAULT_CONFIG.dup) do |path, obj|
        new = YAML.load(File.read(path))
        next unless new
        obj.merge! new
      end
      @paths = @config['paths']
    end

    def run(cmd)
      results = `#{cmd} 2>&1`
      return results if $CHILD_STATUS.success?
      fail "Failed running #{cmd}:\n#{results}"
    end

    def run_chroot(cmd)
      run "arch-chroot #{@config['paths']['build']} #{cmd}"
    end

    def prepare_root
      build_file = @paths['build_file']
      filesystem = @config['fs']
      puts "Making build FS at #{build_file}"
      run "dd if=/dev/zero of=#{build_file} bs=1M count=#{filesystem['size']}"
      mkfs = "mkfs.#{filesystem['type']} #{filesystem['flags']}"
      run "#{mkfs} #{build_file}"
      puts "Mounting FS at #{@paths['build']}"
      FileUtils.mkdir_p @paths['build']
      run "mount #{build_file} #{@paths['build']}"
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
    end

    def run_script(script)
      Dir.chdir('.') { instance_eval File.read(script), script, 0 }
    end

    def run_scripts
      Dir.glob(@config['paths']['scripts'] + '/*.rb').sort.each do |script|
        puts "Running #{script}"
        run_script script
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
      squash_path = @config['paths']['output']
      run "umount #{@config['paths']['build']}"
      run "mksquashfs #{@config['paths']['build_file']} #{squash_path}"
    end

    def cleanup
      puts 'Removing temporary build image'
      File.unlink @config['paths']['build_file']
    end

    def easy_mode
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
