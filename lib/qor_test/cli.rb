require "optparse"

module Qor
  module Test
    class CLI
      attr_accessor :options

      def initialize(options={})
        self.options = options
      end

      def run
        gemfiles = Qor::Test::Bundler.new(options).generate_gemfiles

        gemfiles.map do |gemfile|
          ["bundle update --gemfile='#{gemfile}'", "BUNDLE_GEMFILE=#{gemfile} #{options[:command]}\n\n"].map do |command|
            puts command
            system command
          end
        end
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
