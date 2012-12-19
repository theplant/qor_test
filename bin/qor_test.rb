#!/usr/bin/env ruby
# encoding: utf-8

require "optparse"

$:.unshift File.expand_path("../../lib", __FILE__)
require "qor_test"

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

  opts.on( '-i', '--init', 'Init') do
    Qor::Test::CLI.init
    exit
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

options[:command] = ENV['COMMAND'] || "rake #{File.exist?('spec') ? 'spec' : 'test'}"

Qor::Test::CLI.new(options).run
