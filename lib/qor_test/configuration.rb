module Qor
  module Test
    class Configuration
      include Qor::Dsl

      node :source
      node :ruby
      node :gemspec
      node :gem

      [:git, :platforms, :path, :group, :env].map do |name|
        node name do
          node :ruby
          node :gem
        end
      end

      def self.config_path
        "config/qor/test.rb"
      end

      def self.sample_file
        File.expand_path("#{File.dirname(__FILE__)}/../../config/qor/test.rb")
      end

      def self.gemfile_path
        [ENV['QOR_TEST_GEMFILE'], ENV['BUNDLE_GEMFILE'], 'Gemfile'].select {|x| File.exist?(x.to_s)}[0]
      end

      def self.root_from_config
        @root_from_config ||= Qor::Test::Configuration.load(config_path, :force => true)
      end

      def self.root_from_gemfile
        @root_from_gemfile ||= Qor::Test::Configuration.load(gemfile_path, :force => true)
      end

      def self.find_block(options={})
        lambda do |node|
          node.parent.root? ||
            ((node.parent.config_name == :env) && node.parent.name.to_s == (options[:env] || 'default')) ||
            ((node.parent.config_name == :group) && node.parent.name.to_s == 'test')
        end
      end

      {:gemspecs => :gemspec, :sources => :source}.map do |key, value|
        self.class.class_eval do
          define_method key do |options|
            objs_from_config  = root_from_config.deep_find(value, &find_block(options))
            objs_from_gemfile = root_from_gemfile.deep_find(value, &find_block(options))
            [objs_from_config, objs_from_gemfile].flatten.compact
          end
        end
      end

      def self.combined_sources(options={})
        sources(options).map { |source| "source #{source.value.inspect}\n" }.uniq.join("")
      end

      def self.combined_gemspecs(options={})
        gemspecs(options).map do |gemspec|
          "gemspec #{gemspec.value.nil? ? '' : gemspec.value.inspect.gsub(/^\{|\}$/,'')}\n"
        end.uniq.join("")
      end

      def self.gems_set_from_config(options={})
        all_gems = root_from_config.deep_find(:gem, &find_block(options)).inject({}) do |sum, node|
          sum[node.name] ||= []
          sum[node.name].concat Qor::Test::Gem.parse(node)
          sum
        end.values

        gems_set = all_gems[0].product(*all_gems[1..-1]) rescue []
        gems_set.map do |gems|
          gems.inject({}) do |sum, gem|
            sum[gem.name.to_s] = gem
            sum
          end
        end
      end

      def self.gems_hash_from_gemfile(options={})
        root_from_gemfile.deep_find(:gem, &find_block(options)).inject({}) do |sum, node|
          sum[node.name.to_s] = Qor::Test::Gem.parse(node)[0]
          sum
        end
      end
    end
  end
end
