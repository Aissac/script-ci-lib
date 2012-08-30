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
    end

    def initialize(rails_root, ci_env)
      @rails_root = rails_root
      @ci_env = ci_env
    end

    def setup!
      setup_configs!
      setup_environment!
    end

    def setup_environment!
      FileUtils.ln_s(test_config, env_config) unless 'test' == ci_env
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
