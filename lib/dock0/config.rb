require 'erb'
require 'fileutils'

module Dock0
  ##
  # A Config is a system-specific customization layer
  class Config < Base
    def default_config
      {
        'paths' => {
          'templates' => './templates',
          'scripts' => './scripts',
          'build' => './build/config',
          'output' => './build.tar.gz'
        }
      }
    end

    def finalize
      puts "Packing config into #{@paths['output']}"
      tar = Dir.chdir(File.dirname(@paths['build'])) do
        run 'tar -cz --owner=root --group=root *'
      end
      File.open(@paths['output'], 'w') { |fh| fh << tar }
    end

    def easy_mode
      cleanup @paths.values_at('build', 'output')
      render_templates('templates')
      run_scripts
      finalize
      cleanup @paths.values_at('build')
    end
  end
end
