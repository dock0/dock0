require 'yaml'
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

    DEFAULT_CONFIG = {
      'paths' => {
        'scripts' => './scripts'
      }
    }

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

    def run_script(script)
      Dir.chdir('.') { instance_eval File.read(script), script, 0 }
    end

    def run_scripts
      Dir.glob(@paths['scripts'] + '/*.rb').sort.each do |script|
        puts "Running #{script}"
        run_script script
      end
    end
  end
end

require 'dock0/version'
require 'dock0/image'
require 'dock0/config'
