module Qor
  module Test
    class Bundler
      attr_accessor :options

      def initialize options={}
        self.options = options
      end

      def generate_gemfiles
        config_gems = Qor::Test::Configuration.deep_find(:gem) do |n|
          n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
        end

        bundler_gems = Qor::Test::Gemfile.deep_find(:gem) do |n|
          n.parent.root? || (n.parent.config_name != :group) || (n.parent.name.to_s == 'test')
        end

        config_gems.inject({}) do |s, node|
          s[node.name] ||= []
          s[node.name].concat Qor::Test::Gem.parse(node)
          s
        end

        []
      end
    end
  end
end
