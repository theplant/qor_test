module Qor
  module Test
    class Bundler
      attr_accessor :options

      def initialize options={}
        self.options = options
      end

      def generate_gemfiles
        puts Qor::Test::Configuration.find(:gem).map(&:data).inspect
        puts Qor::Test::Gemfile.find(:gem).map(&:data).inspect

        []
      end
    end
  end
end
