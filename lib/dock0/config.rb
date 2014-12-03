require 'erb'
require 'fileutils'

module Dock0
  ##
  # A Config is a system-specific customization layer
  class Config < Base
    DEFAULT_CONFIG = {
      'paths' => {
        'templates' => './templates',
        'build' => './build'
      }
    }

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

    def easy_mode
      render_templates
    end
  end
end
