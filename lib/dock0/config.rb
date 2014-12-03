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

    def templates
      Dir.chdir(@paths['templates']) do
        Dir.glob('**/*').select { |x| File.file? x }
      end
    end

    def render_templates
      templates.each do |path|
        template = File.read "#{@paths['templates']}/#{path}"
        parsed = ERB.new(template, nil, '<>').result(binding)

        target_path = "#{@paths['build']}/templates/#{path}"
        FileUtils.mkdir_p File.dirname(target_path)
        File.open(target_path, 'w') { |fh| fh.write parsed }
      end
    end

    def finalize
      tar = Dir.chdir(File.dirname(@paths['build'])) { run 'tar cz .' }
      File.open(@paths['output'], 'w') { |fh| fh << tar }
    end

    def easy_mode
      cleanup @paths.values_at('build', 'output')
      render_templates
      run_scripts
      finalize
      cleanup @paths.values_at('build')
    end
  end
end
