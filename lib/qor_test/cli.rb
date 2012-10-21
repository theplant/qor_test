require "optparse"
require 'tempfile'
require "fileutils"

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

        puts ">> Generated #{gemfiles.count} Gemfile\n\n"

        gemfiles.map do |gemfile|
          begin
            new_gemfile = "QorTest_" + File.basename(gemfile)
            FileUtils.cp(gemfile, new_gemfile)
            with_clean_gemfile(new_gemfile) do
              puts ">> Using Gemfile #{gemfile}"
              ["bundle update", "#{options[:command]}\n\n"].map do |command|
                puts ">> #{command}"
                system(command)
              end
            end
          ensure
            FileUtils.rm(new_gemfile)
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

          opts.on( '-C', '--clean', 'Clean old temp files') do |command|
            puts "Cleaning temp files..."
            FileUtils.rm_rf(Dir[File.join(temp_directory, "qor_test-tmp-*")])
            exit
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

      def self.temp_directory
        tempfile = Tempfile.new('fake')
        File.dirname(tempfile.path)
      end
    end
  end
end
