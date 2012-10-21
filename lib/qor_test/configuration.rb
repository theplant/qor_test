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

      def self.gems(options={})
        deep_find(:gem) do |n|
          n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
        end
      end

      def self.gemspecs(options={})
        deep_find(:gemspec) do |n|
          n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
        end
      end

      def self.sources(options={})
        deep_find(:source) do |n|
          n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
        end
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

      node :platforms do
        node :gem
      end

      node :path do
        node :gem
      end

      node :group do
        node :gem
      end

      def self.gems(options={})
        deep_find(:gem) do |n|
          n.parent.root? || (n.parent.config_name != :group) || (n.parent.name.to_s == 'test')
        end
      end

      def self.gemspecs(options={})
        deep_find(:gemspec) do |n|
          n.parent.root? || (n.parent.config_name != :group) || (n.parent.name.to_s == 'test')
        end
      end

      def self.sources(options={})
        deep_find(:source) do |n|
          n.parent.root? || (n.parent.config_name != :group) || (n.parent.name.to_s == 'test')
        end
      end
    end
  end
end
