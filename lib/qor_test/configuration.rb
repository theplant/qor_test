module Qor
  module Test
    class Configuration
      include Qor::Dsl

      node :source
      node :ruby
      node :gemspec
      node :gem

      [:git, :platforms, :path, :group].map do |name|
        node name do
          node :gem
        end
      end

      def self.config_path
        @@config_path || "config/qor/test.rb"
      end

      def self.sample_file
        File.expand_path("#{File.dirname(__FILE__)}/../../config/qor/test.rb")
      end

      def self.gemfile_path
        [ENV['QOR_TEST_GEMFILE'], ENV['BUNDLE_GEMFILE'], 'Gemfile'].select {|x| File.exist?(x.to_s)}[0]
      end
    end
  end
end

# def self.gems(options={})
#   deep_find(:gem) do |n|
#     n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
#   end
# end

# def self.gemspecs(options={})
#   deep_find(:gemspec) do |n|
#     n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
#   end
# end

# def self.sources(options={})
#   deep_find(:source) do |n|
#     n.parent.root? || ((n.parent.config_name == :env) && n.parent.name.to_s == (options[:env] || 'default'))
#   end
# end
