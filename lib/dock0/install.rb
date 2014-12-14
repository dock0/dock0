require 'fileutils'
require 'menagerie'

module Dock0
  ##
  # An Install is a deployment of components onto a system
  class Install < Base
    def default_config
      {
        'paths' => {
          'templates' => './templates',
          'scripts' => './scripts',
          'build' => './build',
          'base' => '/',
        },
        'org' => 'dock0',
        'artifacts' => [],
      }
    end

    def build_url(artifact)
      org = @config['org']
      name, version, file = artifact.values_at('name', 'version', 'file')
      "https://github.com/#{org}/#{name}/releases/download/#{version}/#{file}"
    end

    def artifacts
      @config['artifacts'].map do |artifact|
        artifact['url'] ||= build_url(artifact)
        artifact
      end
    end

    def load_artifacts
      Dir.chdir("#{@paths['build']}/#{@paths['base']}") do
        menagerie = Menagerie.new @config['menagerie']
        menagerie.create artifacts
      end
    end

    def templates
      Dir.chdir(@paths['templates']) do
        Dir.glob('**/*').select { |x| File.file? x }
      end
    end

    def render_templates
      templates.each do |path|
        puts "Templating #{path}"
        template = File.read "#{@paths['templates']}/#{path}"
        parsed = ERB.new(template, nil, '<>').result(binding)

        target_path = "#{@paths['build']}/#{path}"
        FileUtils.mkdir_p File.dirname(target_path)
        File.open(target_path, 'w') { |fh| fh.write parsed }
      end
    end

    def easy_mode
      load_artifacts
      render_templates
      run_scripts
    end
  end
end
