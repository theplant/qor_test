#!/usr/bin/env ruby
# encoding: utf-8

require "optparse"

$:.unshift File.expand_path("../../lib", __FILE__)
require "qor_test"
require "qor_test/configuration"

options = {}

OptionParser.new do |opts|
  opts.on( '-e', '--env env', 'Test Env') do |env|
    options[:env] = env
  end

  opts.on( '-c', '--clean', 'Clean up temporary files') do
    puts "Cleaning temporary files..."
    FileUtils.rm_rf(Dir[File.join(Qor::Test::CLI.temp_directory, "qor_test-gemfiles-*")])
    exit
  end

  opts.on( '-p', '--pretend', 'Skip run command, only generate Gemfiles') do
    options[:pretend] = true
  end

  opts.on( '-s', '--sample', 'Create sample configuration') do
    Qor::Test::CLI.copy_sample_configuration
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

# Default command to run tests
options[:command] = ENV['COMMAND'] || "rake #{File.exist?('spec') ? 'spec' : 'test'}"

# Run all envs by default
envs = options[:env] ? [options[:env]] : Qor::Test::Configuration.envs
envs = [nil] if envs.size == 0

$case_num = 0

script_filename = ENV['QOR_TEST_SCRIPT_FILE'] || 'qor_test.sh'

scripts = envs.map do |env|
  cli = Qor::Test::CLI.new(options.merge(:env => env))
  cli.run
  cli.scripts
end

scripts.unshift <<-EOF
  total_cases_num=#{$case_num}
  pass_cases_num=0
  failed_cases=()
EOF

scripts.push <<-EOF
  echo
  echo "(test script: #{script_filename})"
  echo "\e[31mTotal Cases: $total_cases_num, Passed Cases: $pass_cases_num\e[0m"
  for name in ${failed_cases[@]}
  do
    echo "\e[33mFailed Case: $name\e[0m"
  done
EOF

open(script_filename, 'a') do |f|
  f.puts scripts.compact.join("\n")
end
