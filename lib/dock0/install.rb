require 'fileutils'
require 'open-uri'

module Dock0
  ##
  # An Install is a deployment of components onto a system
  class Install < Base
    def default_config
      {
        'paths' => {
          'templates' => './templates',
          'scripts' => './scripts',
          'build' => './build'
        },
        'org' => 'dock0',
        'artifacts' => []
      }
    end

    def build_url(artifact)
      org = @config['org']
      name, version, file = artifact.values_at('name', 'version', 'file')
      "https://github.com/#{org}/#{name}/releases/download/#{version}/#{file}"
    end

    def build_path(artifact)
      "#{artifact['name']}/#{artifact['file']}"
    end

    def download(artifact)
      url, path = artifact.values_at('url', 'full_path')
      puts "Downloading #{url} to #{path}"
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'wb') do |fh|
        open(url, 'rb') { |request| fh.write request.read }
      end
    end

    def chmod(artifact)
      File.chmod(artifact['mode'], full_path)
    end

    def link(artifact)
      full_link_path = "#{@paths['build']}/#{artifact['link']}"
      FileUtils.mkdir_p File.dirname(full_link_path)
      FileUtils.ln_sf artifact['path'], full_link_path
    end

    def load_artifacts
      @config['artifacts'].each do |artifact|
        artifact['url'] ||= build_url(artifact)
        artifact['path'] ||= build_path(artifact)
        artifact['full_path'] = "#{@paths['build']}/#{artifact['path']}"
        download artifact
        chmod artifact if artifact['mode']
        link(artifact) if artifact['link']
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

    def finalize
      puts "Packing config into #{@paths['output']}"
      tar = Dir.chdir(File.dirname(@paths['build'])) { run 'tar cz .' }
      File.open(@paths['output'], 'w') { |fh| fh << tar }
    end

    def easy_mode
      load_artifacts
      render_templates
      run_scripts
      finalize
    end
  end
end
