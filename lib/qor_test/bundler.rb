module Qor
  module Test
    class Bundler
      attr_accessor :options

      def initialize(options={})
        self.options = options
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
