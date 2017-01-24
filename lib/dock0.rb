require 'yaml'
require 'English'
require 'fileutils'
require 'meld'
require 'cymbal'

##
# Dock0 provides an interface for building Arch images
module Dock0
  class << self
    ##
    # Insert a helper .new() method for creating a new Dock0 object

    def new(*args)
      Dock0::Image.new(*args)
    end

    ##
    # Helper for simplifying object creation
    def easy_mode(type, args)
      Dir.chdir File.dirname(args.first)
      const_get(type).new(*args).easy_mode
    end
  end

  ##
  # Base class for common methods
  class Base
    attr_reader :config

    def initialize(*configs)
      @config = configs.each_with_object(default_config) do |path, obj|
        new = YAML.safe_load(File.read(path))
        next unless new
        obj.deep_merge! Cymbal.symbolize(new)
      end
      @paths = @config[:paths]
    end

    def default_config
      { paths: { scripts: './scripts' } }
    end

    def run(cmd)
      results = `#{cmd} 2>&1`
      return results if $CHILD_STATUS.success?
      raise "Failed running #{cmd}:\n#{results}"
    end

    def templates
      Dir.chdir(@paths[:templates]) do
        Dir.glob('**/*').select { |x| File.file? x }
      end
    end

    def render_templates(prefix)
      templates.each do |path|
        puts "Templating #{path}"
        template = File.read "#{@paths[:templates]}/#{path}"
        parsed = ERB.new(template, nil, '<>').result(binding)

        target_path = "#{@paths[:build]}/#{prefix}/#{path}"
        FileUtils.mkdir_p File.dirname(target_path)
        File.open(target_path, 'w') { |fh| fh.write parsed }
      end
    end

    def run_script(script)
      Dir.chdir('.') { instance_eval File.read(script), script, 0 }
    end

    def run_scripts
      Dir.glob(@paths[:scripts] + '/*.rb').sort.each do |script|
        puts "Running #{script}"
        run_script script
      end
    end

    def cleanup(list)
      puts "Removing: #{list.join(', ')}"
      FileUtils.rm_rf list
    end
  end
end

require 'dock0/version'
require 'dock0/image'
require 'dock0/config'
require 'dock0/install'
