require "optparse"

module Qor
  module Test
    class CLI
      attr_accessor :options

      def initialize(options={})
        self.options = options
      end

      def prepare_run
        gemfiles = Qor::Test::Gemfile.new(options).generate_gemfiles

        gemfiles.map do |gemfile|
          system("bundle install --gemfile='#{gemfile}'")
          system("BUNDLE_GEMFILE=#{gemfile} #{options[:command]}")
        end
      end

      def run
        prepare_run
        option_parser.parse!
      end

      def option_parser
        @option_parser ||= OptionParser.new do |opts|
          opts.on( '-e', '--env env', 'Test Env' ) do |env|
            options[:env] = env
          end

          opts.on( '-c', '--command command', 'Command' ) do |command|
            options[:command] = command
          end

          opts.on( '-h', '--help', 'Display this help' ) do
            puts opts
            exit
          end
        end
      end

      def self.start(*args)
        new(args).run
      end
    end
  end
end
