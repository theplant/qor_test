module Qor
  module Test
    class Cli
      attr_accessor :options

      def initialize(options={})
        self.options = options
      end

      def run
        gemfiles = Qor::Test::Bundler.new(options).generate_gemfiles

        gemfiles.map do |gemfile|
          system("bundle install --gemfile='#{gemfile}'")
          system("BUNDLE_GEMFILE=#{gemfile} #{options[:command]}")
        end
      end
    end
  end
end
