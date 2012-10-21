require 'tempfile'

module Qor
  module Test
    class Bundler
      attr_accessor :options

      def initialize options={}
        self.options = options
      end

      def gems_set_from_config
        gems = Qor::Test::Configuration.gems(options).inject({}) do |s, node|
          s[node.name] ||= []
          s[node.name].concat Qor::Test::Gem.parse(node)
          s
        end.values

        gems.length > 0 ? gems[0].product(*gems[1..-1]) : []
      end

      def gems_hash_from_gemfile
        Qor::Test::Gemfile.gems(options).inject({}) do |s, node|
          s[node.name.to_s] = Qor::Test::Gem.parse(node)[0]
          s
        end
      end

      def generate_gemfiles
        gems_set  = gems_set_from_config
        gems_hash = gems_hash_from_gemfile
        gems_name = gems_hash.keys
        gemfile_length = [gems_set.length, 1].max

        tempfile = Tempfile.new('fake')
        gemfile_dir = File.join(File.dirname(tempfile.path), "qor_test-tmp-#{Time.now.to_i}")
        FileUtils.mkdir_p(gemfile_dir)

        filenames = (0...gemfile_length).map do |t|
          gems = []
          gem_names = gems_set[t].map(&:name)
          gem_names.concat(gems_name).uniq!

          gem_names.map do |name|
            gems << (gems_set[t].select {|g| g.name == name}[0] || gems_hash[name])
          end

          file = File.new(File.join(gemfile_dir, "Gemfile.#{t}"), "w+")
          file << gems.map(&:to_s).join("\n")
          file.close
          file.path
        end

        filenames
      end
    end
  end
end
