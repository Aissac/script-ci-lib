require 'erb'
require 'fileutils'

module CI
  # Helper for setting up environment dependent config files for CI.
  # It expects to find ERB templates for config files in rails-root/config/ci/
  # which it renders with the rails_root and ci_env variables.
  class ConfigHelper
    attr_reader :rails_root, :ci_env

    def self.setup!(rails_root, ci_env)
      new(rails_root, ci_env).setup!
    end

    class ConfigTemplate
      include ERB::Util

      def initialize(template, options={})
        options.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
        @erb = ERB.new(File.read(template))
      end

      def render
        @erb.result(binding)
      end

      def to_s
        render
      end
    end

    DEFAULT_CONFIG_PATHS = %W[
      config/environments/test.rb
    ]

    def initialize(rails_root, ci_env, config_paths=DEFAULT_CONFIG_PATHS)
      @rails_root = rails_root
      @ci_env = ci_env
      @config_paths = config_paths
    end

    def setup!
      setup_configs!
      setup_environment!
    end

    def setup_environment!
      return if 'test' == ci_env
      
      @config_paths.each do |path|
        test_config = File.join(rails_root, path)
        env_config = destination_config_path(path)
        FileUtils.ln_s(test_config, env_config) 
      end
      
    end

    def setup_configs!
      find_config_templates.each do |template|
        result = ConfigTemplate.new(template, config_template_options)

        File.open(destination_config(template), 'w') do |f|
          f.write(result)
        end
      end
    end

    private
      def destination_config_path(path)
        source = File.expand_path File.join(rails_root, path)
        name = if File.directory?(source)
          ci_env
        else
          ext = File.extname(path)
          "#{ci_env}#{ext}"
        end

        File.join(File.dirname(source), name)
      end

      def destination_config(template)
        File.join(rails_root, 'config', File.basename(template).gsub(/\.erb$/, ''))
      end

      def find_config_templates
        Dir[rails_root + '/config/ci/*.erb']
      end

      def config_template_options
        {
          :rails_root => rails_root,
          :ci_env => ci_env
        }
      end
  end
end
