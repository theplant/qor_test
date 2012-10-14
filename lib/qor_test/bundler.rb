module Qor
  module Test
    class Bundler
      attr_accessor :options

      def initialize(options={})
        self.options = options
      end

      def generate_gemfiles
        [1]
      end
    end
  end
end
