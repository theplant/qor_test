require "optparse"
require 'tempfile'
require "fileutils"

module Qor
  module Test
    class CLI
      attr_accessor :options, :scripts

      def initialize(options={})
        self.options = options
        self.scripts = []
      end

      def run
        gemfile = Qor::Test::Gemfile.new(options)
        gemfiles = gemfile.generate_gemfiles
        puts ">> Generated #{gemfiles.count} Gemfile\n\n"

        gemfile.ruby_versions.map do |version|
          scripts << Qor::Test::Ruby.switch_ruby_version(version)
          gemfiles.map do |gemfile|
            run_with_gemfile(gemfile)
          end
        end

        puts scripts.compact.join("\n")

      rescue Qor::Dsl::ConfigurationNotFound
        puts "ConfigurationNotFound, please run `qor_test --init` in project's root to get a sample configuration"
      end

      def run_with_gemfile(gemfile)
        gemfile_lock = "#{gemfile}.lock"
        temp_gemfile = "QorTest_" + File.basename(gemfile)
        temp_gemfile_lock = "#{temp_gemfile}.lock"

        scripts << "cp '#{gemfile}' '#{temp_gemfile}'"
        scripts << "[ -f '#{gemfile_lock}' ] && cp '#{gemfile_lock}' '#{temp_gemfile_lock}'"

        scripts << "echo '>> BUNDLE_GEMFILE=#{gemfile}'"
        scripts << "export BUNDLE_GEMFILE=#{temp_gemfile}"

        [
          "bundle install",
          "#{options[:command]}".sub(/^(bundle\s+exec\s+)?/, 'bundle exec ')
        ].map do |command|
          scripts << "echo '>> #{command}'"
          scripts << command unless options[:pretend]
        end

        scripts << "[ -f '#{temp_gemfile_lock}' ] && cp '#{temp_gemfile_lock}' '#{gemfile_lock}'"
        [temp_gemfile, temp_gemfile_lock].map do |file|
          scripts << "[ -f '#{file}' ] && rm '#{file}'"
        end
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
