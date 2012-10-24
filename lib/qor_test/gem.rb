module Qor
  module Test
    class Gem
      attr_accessor :name, :options, :gem_option

      def initialize(node, gem_option=nil)
        self.name = node.name.to_s
        self.gem_option = gem_option

        [:git, :path, :platforms].map do |type|
          if node.parent.is_node?(type)
            self.options = {type => node.parent.value}.merge(node.parent.options)
          end
        end
      end

      def to_s
        if gem_option.is_a?(Array) && gem_option.length > 0
          %{gem "#{name}", #{gem_option.map(&:inspect).join(", ")}}
        elsif !gem_option.nil? && !gem_option.is_a?(Array)
          %{gem "#{name}", #{gem_option.inspect}}
        elsif options.is_a?(Hash)
          %{gem "#{name}", #{options.inspect}}
        else
          %{gem "#{name}"}
        end
      end

      def self.parse(node)
        if node.data.is_a?(Array) && node.data[0].is_a?(Array)
          node.data.map do |gem_option|
            gem_option.map {|x| Gem.new(node, x) }
          end.flatten
        else
          Array(Gem.new(node, node.data))
        end
      end
    end
  end
end
