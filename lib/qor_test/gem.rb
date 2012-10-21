module Qor
  module Test
    class Gem
      attr_accessor :name, :gem_option

      def initialize(name, gem_option=nil)
        self.name = name.to_s
        self.gem_option = gem_option
      end

      def to_s
        if gem_option.is_a?(Array) && gem_option.length > 0
          %{gem "#{name}", #{gem_option.map(&:inspect).join(", ")}}
        elsif !gem_option.is_a?(Array)
          %{gem "#{name}", #{gem_option.inspect}}
        else
          %{gem "#{name}"}
        end
      end

      def self.parse(node)
        if node.data.is_a?(Array) && node.data[0].is_a?(Array)
          node.data.map do |gem_option|
            gem_option.map {|x| Gem.new(node.name, x) }
          end.flatten
        else
          Array(Gem.new(node.name, node.data))
        end
      end
    end
  end
end
