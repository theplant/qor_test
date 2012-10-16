require "qor_test/configuration"

module Qor
  module Test
    class Gemfile
      attr_accessor :options, :default_gemfile

      def initialize(options={})
        self.options = options

        gemfile_path = ENV['BUNDLE_GEMFILE'] || 'Gemfile'
        default_gemfile = Qor::Test::Configuration.load(gemfile_path, {:force => true}) if File.exist?(gemfile_path)
        config_gemfile = Qor::Test::Configuration.load(nil, {:force => true})
      end

      def get_gems_from_gemfile
      end

      def get_gems_from_config
        gems = []

        if Qor::Test::Configuration.root
          gems << Qor::Test::Configuration.find(:gem)

          if options[:env]
            env = Qor::Test::Configuration.first(:env, options[:env])
            gems << env.find(:gem) if env
          end
        end

        gems
      end

      def generate_gemfiles
        []
      end
    end
  end
end
