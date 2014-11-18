require 'yaml'
require 'fileutils'
require 'English'

module Dock0
  ##
  # An Image is an Arch system being built
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
      run "arch-chroot #{@paths['build']} #{cmd}"
    end

    def prepare_root
      build_file = @paths['build_file']
      filesystem = @config['fs']
      puts "Making build FS at #{build_file}"
      run "dd if=/dev/zero of=#{build_file} bs=1MB count=#{filesystem['size']}"
      mkfs = "mkfs.#{filesystem['type']} #{filesystem['flags']}"
      run "#{mkfs} #{build_file}"
      puts "Mounting FS at #{@paths['build']}"
      FileUtils.mkdir_p @paths['build']
      run "mount #{build_file} #{@paths['build']}"
    end

    def install_packages
      File.read(@paths['package_list']).split("\n").each do |package|
        puts "Installing #{package}"
        run "pacstrap -G -M #{@paths['build']} #{package}"
      end
    end

    def apply_overlay
      puts "Applying overlay from #{@paths['overlay']}"
      overlay_path = @paths['overlay'] + '/.'
      FileUtils.cp_r overlay_path, @paths['build']
    end

    def run_script(script)
      Dir.chdir('.') { instance_eval File.read(script), script, 0 }
    end

    def run_scripts
      Dir.glob(@paths['scripts'] + '/*.rb').sort.each do |script|
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
      run "umount #{@paths['build']}"
      FileUtils.rm_f @paths['output']
      run "mksquashfs #{@paths['build_file']} #{@paths['output']}"
    end

    def cleanup
      puts 'Removing temporary build image'
      File.unlink @paths['build_file']
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