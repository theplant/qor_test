require 'qor_dsl'

module Qor
  module Test
    module Configuration
      include Qor::Dsl
      default_configs ["config/qor/test.rb"]

      node :gem

      node :env do
        node :gem
        node :ruby
      end
    end
  end
end
