module Qor
  module Test
    module Configuration
      include Qor::Dsl
      default_configs ["config/qor/test.rb"]

      node :source
      node :ruby
      node :gemspec
      node :gem

      node :env do
        node :gem
        node :ruby
      end
    end

    class Gemfile
      include Qor::Dsl
      default_configs [ENV['QOR_TEST_GEMFILE'], ENV['BUNDLE_GEMFILE'], 'Gemfile']

      node :source
      node :ruby
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
    end
  end
end
