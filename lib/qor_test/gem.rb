module Qor
  module Test
    class Gem
      attr_accessor :name, :options

      def initialize(node, gem_option=nil)
        self.name = node.name.to_s
        self.options = gem_option.is_a?(Array) ? gem_option : [gem_option]

        [:git, :path, :platforms].map do |type|
          if node.parent.is_node?(type)
            parent_option = {type => node.parent.value}.merge(node.parent.options)
            if options[-1].is_a?(Hash)
              self.options[-1] = parent_option.merge(options[-1])
            else
              self.options.push(parent_option)
            end
          end
        end
      end

      def to_s
        result = %{gem "#{name}"}
        result += %{, #{options.map(&:inspect).join(", ")}} if options.length > 0
        result
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
