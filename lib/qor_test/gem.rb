module Qor
  module Test
    class Gem
      attr_accessor :name, :gem_option

      def initialize(name, gem_option=nil)
        self.name = name
        self.gem_option = gem_option
      end

      def to_s
        if gem_option
          %{gem "#{name}", #{gem_option.inspect}}
        else
          %{gem "#{name}"}
        end
      end

      def self.parse(node)
        if node.data.is_a?(Array) && node.data.length > 1
          node.data.map do |gem_option|
            if gem_option.is_a? Array
              gem_option.map {|x| Gem.new(node.name, x) }
            else
              Gem.new(node.name, gem_option)
            end
          end.flatten
        else
          Array(Gem.new(node.name))
        end
      end
    end
  end
end

