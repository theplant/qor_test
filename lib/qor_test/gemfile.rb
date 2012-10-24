module Qor
  module Test
    class Gemfile
      attr_accessor :options

      def initialize options={}
        self.options = options
      end

      def generate_gemfiles
        gems_set_from_config = Qor::Test::Configuration.gems_set_from_config(options)
        gems_hash_from_gemfile = Qor::Test::Configuration.gems_hash_from_gemfile(options)
        gemfile_length = [gems_set_from_config.length, 1].max

        gemfile_dir = File.join(Qor::Test::CLI.temp_directory, "qor_test-gemfiles-#{Time.now.to_i}")
        FileUtils.mkdir_p(gemfile_dir)

        (0...gemfile_length).map do |index|
          filename = File.join(gemfile_dir, "Gemfile.#{index}")
          write_gemfile(gems_set_from_config[index], gems_hash_from_gemfile, filename)
        end
      end

      def write_gemfile(gems_from_config, gems_from_gemfile, filename)
        gem_names = [gems_from_config.keys, gems_from_gemfile.keys].flatten.compact.uniq

        gems = gem_names.map do |name|
          gems_from_config[name] || gems_from_gemfile[name]
        end.compact

        file = File.new(filename, "w+")
        file << Qor::Test::Configuration.combined_sources(options)
        file << Qor::Test::Configuration.combined_gemspecs(options)
        file << gems.map(&:to_s).join("\n")
        file.close
        file.path
      end
    end
  end
end
