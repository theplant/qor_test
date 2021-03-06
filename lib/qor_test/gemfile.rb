module Qor
  module Test
    class Gemfile
      attr_accessor :options

      def initialize options={}
        self.options = options
      end

      def ruby_versions
        versions = Qor::Test::Configuration.ruby_versions(options)
        versions.empty? ? [RUBY_VERSION] : versions
      end

      def group_name
        Qor::Test::Configuration.envs(options)[0]
      end

      def generate_gemfiles
        gems_set_from_config = Qor::Test::Configuration.gems_set_from_config(options)
        gems_hash_from_gemfile = Qor::Test::Configuration.gems_hash_from_gemfile(options)
        gemfile_length = [gems_set_from_config.length, 1].max

        gemfile_dir = File.join(Qor::Test::CLI.temp_directory, Qor::Test::Configuration.configuration_digest(options))

        if File.exist?(gemfile_dir)
          Dir[File.join(gemfile_dir, '*')].select {|x| x !~ /.lock$/ }
        else
          FileUtils.mkdir_p(gemfile_dir)

          (0...gemfile_length).map do |index|
            filename = File.join(gemfile_dir, "Gemfile.#{index}")
            write_gemfile(gems_set_from_config[index] || {}, gems_hash_from_gemfile, filename)
          end
        end
      end

      def generate_gems_entry(gems_from_config, gems_from_gemfile)
        gem_names = [gems_from_config.keys, gems_from_gemfile.keys].flatten.compact.uniq

        gem_names.map do |name|
          gems_from_config[name] || gems_from_gemfile[name]
        end.compact.map(&:to_s).join("\n")
      end

      def write_gemfile(gems_from_config, gems_from_gemfile, filename)
        File.open(filename, "w+") do |f|
          f << Qor::Test::Configuration.combined_sources(options)
          f << Qor::Test::Configuration.combined_gemspecs(options)
          f << generate_gems_entry(gems_from_config, gems_from_gemfile)
        end.path
      end
    end
  end
end
