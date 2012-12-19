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

      def write_scripts
        File.open(ENV['QOR_TEST_SCRIPT_FILE'], 'w+') do |f|
          f << scripts.compact.join("\n")
        end
      end

      def run
        scripts << "echo 'Generated #{gemfiles.count} Gemfile, Running with ruby #{rubies}'"

        case_num = 0
        rubies.map do |version|
          scripts << Qor::Test::Rubies.switch_ruby_version(version)
          gemfiles.map do |gemfile|
            case_num += 1
            scripts << "echo '\n\n\e[01;31mRunning case #{case_num} with ruby #{version}, '$[$total_cases_num-#{case_num}]' cases left\n\e[0m'"
            run_with_gemfile(gemfile)
          end
        end
        scripts.unshift "total_cases_num=#{case_num}"

        write_scripts
      rescue Qor::Dsl::ConfigurationNotFound
        puts "ConfigurationNotFound, please run `qor_test --init` in project's root to get a sample configuration"
      end

      def run_with_gemfile(file)
        lock_file = "#{file}.lock"
        temp_file = "QorTest_" + File.basename(file)
        temp_lock = "#{temp_file}.lock"

        # Copy Gemfile and Gemfile.lock if exist
        scripts << "cp '#{file}' '#{temp_file}'"
        scripts << "[ -f '#{lock_file}' ] && cp '#{lock_file}' '#{temp_lock}'"

        # Export Gemfile
        scripts << "echo '>> BUNDLE_GEMFILE=#{file}'"
        scripts << "export BUNDLE_GEMFILE=#{temp_file}"

        # Test commands. 1, bundle install, 2, rake test
        [
          "bundle install --quiet",
          "#{options[:command]}".sub(/^(bundle\s+exec\s+)?/, 'bundle exec ')
        ].map do |command|
          scripts << "echo '>> #{command}'"
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

      def self.init
        command = "sudo ln -nfs #{File.expand_path("../../../shell/qor_test", __FILE__)} /usr/bin/"
        puts command
        system command
      end
    end
  end
end
