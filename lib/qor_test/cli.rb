require "optparse"

module Qor
  module Test
    class CLI
      BUNDLER_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE).freeze
      attr_accessor :options

      def initialize(options={})
        self.options = options
      end

      def run
        gemfiles = Qor::Test::Bundler.new(options).generate_gemfiles
        gemfiles.map do |gemfile|
          with_clean_gemfile(gemfile) do
            ["bundle update", "#{options[:command]}\n\n"].map do |command|
              puts ">> #{command}"
              system(command)
            end
          end
        end
      end

      def with_clean_gemfile(gemfile)
        original_env = {}
        BUNDLER_ENV_VARS.each do |key|
          original_env[key] = ENV[key]
          ENV[key] = nil
        end

        ENV['BUNDLE_GEMFILE'] = gemfile
        yield
      ensure
        original_env.each { |key, value| ENV[key] = value }
      end

      def self.option_parser
        options = {}

        OptionParser.new do |opts|
          opts.on( '-e', '--env env', 'Test Env') do |env|
            options[:env] = env
          end

          opts.on( '-c', '--command command', 'Command') do |command|
            options[:command] = command
          end

          opts.on( '-h', '--help', 'Display this help') do
            puts opts
            exit
          end

          opts.on( '-v', '--version', 'Show version number') do |version|
            puts "Version: #{Qor::Test::VERSION}"
            exit
          end
        end.parse!

        options
      end
    end
  end
end
