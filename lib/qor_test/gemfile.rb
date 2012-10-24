module Qor
  module Test
    class Gemfile
      attr_accessor :options

      def initialize options={}
        self.options = options
      end

      def generate_gemfiles
        gems_set  = Qor::Test::Configuration.gems_set_from_config(options)
        gems_hash = Qor::Test::Configuration.gems_hash_from_gemfile(options)
        gems_name = gems_hash.keys
        gemfile_length = [gems_set.length, 1].max

        gemfile_dir = File.join(Qor::Test::CLI.temp_directory, "qor_test-tmp-#{Time.now.to_i}")
        FileUtils.mkdir_p(gemfile_dir)

        filenames = (0...gemfile_length).map do |t|
          gems = []
          gem_names = gems_set[t].map(&:name)
          gem_names.concat(gems_name).uniq!

          gem_names.map do |name|
            gems << (gems_set[t].select {|g| g.name == name}[0] || gems_hash[name])
          end

          file = File.new(File.join(gemfile_dir, "Gemfile.#{t}"), "w+")
          file << Qor::Test::Configuration.combined_sources(options)
          file << Qor::Test::Configuration.combined_gemspecs(options)
          # Add gems
          file << gems.map(&:to_s).join("\n")
          file.close
          file.path
        end

        filenames
      end
    end
  end
end
