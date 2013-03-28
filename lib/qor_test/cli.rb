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

      def gemfile
        @gemfile ||= Qor::Test::Gemfile.new(options)
      end

      def gemfiles
        @gemfiles ||= gemfile.generate_gemfiles.reverse
      end

      def rubies
        gemfile.ruby_versions
      end

      def run
        rubies.map do |version|
          scripts << Qor::Test::Rubies.switch_ruby_version(version)
          gemfiles.map { |file| run_with_gemfile(file) }
        end
      rescue Qor::Dsl::ConfigurationNotFound
        puts "ConfigurationNotFound, please run `qor_test --init` in project's root to get a sample configuration"
      end

      def run_with_gemfile(file)
        $case_num += 1
        scripts << "echo -n '\n\e[01;31m[ENV #{gemfile.group_name}] \e[0m'"
        scripts << "echo -n '\e[31mRunning case #{$case_num} with ruby '$(ruby -v)', '$[$total_cases_num-#{$case_num}]' cases left\e[0m\n'"

        lock_file = "#{file}.lock"
        temp_file = "QorTest_" + File.basename(file)
        temp_lock = "#{temp_file}.lock"

        # Copy Gemfile and Gemfile.lock if exist
        scripts << "cp '#{file}' '#{temp_file}'"
        scripts << "[ -f '#{lock_file}' ] && cp '#{lock_file}' '#{temp_lock}'"

        # Export Gemfile
        scripts << "echo '>> BUNDLE_GEMFILE=#{file}'"
        scripts << "export BUNDLE_GEMFILE=#{temp_file}"

        # Test commands
        [
          "bundle install --quiet",
          "#{options[:command].sub(/^(bundle\s+exec\s+)?/, 'bundle exec ')} && pass_cases_num=$(($pass_cases_num+1)) || failed_cases=(\"${failed_cases[@]}\" \"RUBY_VERSION:$(ruby -v | sed 's/ /-/g') #{file}\")"
        ].map do |command|
          scripts << "echo '>> #{command.sub(/ && .*$/,'')}'"
          scripts << command unless options[:pretend]
        end

        # Backup & Cleanup
        scripts << "[ -f '#{temp_lock}' ] && cp '#{temp_lock}' '#{lock_file}'"
        [temp_file, temp_lock].map do |file|
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
    end
  end
end
