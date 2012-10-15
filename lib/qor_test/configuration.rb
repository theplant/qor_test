require 'qor_dsl'

module Qor
  module Test
    module Configuration
      include Qor::Dsl
      default_configs ["config/qor/test.rb"]

      node :source
      node :gemspec
      node :gem

      node :git do
        node :gem
      end

      node :path do
        node :gem
      end

      node :group do
        node :gem
      end

      node :env do
        node :gem
        node :ruby
      end
    end
  end
end
