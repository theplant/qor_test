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
        gemfile = Qor::Test::Gemfile.new(options)
        gemfiles = gemfile.generate_gemfiles
        puts ">> Generated #{gemfiles.count} Gemfile\n\n"

        gemfile.ruby_versions.map do |version|
          Qor::Test::Ruby.run_with_version(version) do
            gemfiles.map do |gemfile|
              run_with_gemfile(gemfile)
            end
          end
        end
      rescue Qor::Dsl::ConfigurationNotFound
        puts "ConfigurationNotFound, please run `qor_test --init` in project's root to get a sample configuration"
      end

      def run_with_gemfile(gemfile)
        gemfile_lock = "#{gemfile}.lock"
        temp_gemfile = "QorTest_" + File.basename(gemfile)
        temp_gemfile_lock = "#{temp_gemfile}.lock"

        FileUtils.cp(gemfile, temp_gemfile)
        FileUtils.cp(gemfile_lock, temp_gemfile_lock) if File.exist?(gemfile_lock)

        with_clean_env(temp_gemfile) do
          puts ">> BUNDLE_GEMFILE=#{gemfile}"

          [
            "bundle install",
            "#{options[:command]}\n\n".sub(/^(bundle\s+exec\s+)?/, 'bundle exec ')
          ].map do |command|
            puts ">> #{command}"
            system(command) unless options[:pretend]
          end
        end
      ensure
        FileUtils.cp(temp_gemfile_lock, gemfile_lock) if File.exist?(temp_gemfile_lock)
        [temp_gemfile, temp_gemfile_lock].map do |file|
          FileUtils.rm(file) if File.exist?(file)
        end
      end

      def with_clean_env(gemfile)
        original_env = {}

        BUNDLER_ENV_VARS.each do |key|
          original_env[key], ENV[key] = ENV[key], nil
        end

        ENV['BUNDLE_GEMFILE'] = gemfile
        yield
      ensure
        original_env.each { |key, value| ENV[key] = value }
      end

      def self.temp_directory
        tempfile = Tempfile.new('fake')
        File.dirname(tempfile.path)
      end

      def self.copy_sample_configuration
        FileUtils.mkdir_p(File.dirname(Qor::Test::Configuration.config_path))
        FileUtils.cp(Qor::Test::Configuration.sample_file, Qor::Test::Configuration.config_path)
        puts("Copied sample configuration to #{Qor::Test::Configuration.config_path}!")
      end

      def self.init
        system "sudo ln -nfs #{File.expand_path("../../../shell/qor_test", __FILE__)} /usr/bin/"
      end
    end
  end
end
