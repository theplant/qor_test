module Qor
  module Test
    class Ruby
      class << self

        def rvm?
          system("which rvm")
        end

        def rbenv?
          system("which rbenv")
        end

        def version_manager_installed?
          rvm? || rbenv?
        end

        def versions
          @@versions ||= if rvm?
            `rvm list strings`.split("\n")
          elsif rbenv?
            `rbenv versions | cut -d '(' -f1`.split("\n").map {|x| x.sub(/\*/,'') }.map(&:strip)
          end
        end

        def matched_version(version)
          versions.select {|x| x =~ Regexp.new(version) }[-1]
        end

        def switch_ruby_version(version)
          if rvm?
            "rvm #{matched_version(version)}"
          elsif rbenv?
            "rbenv shell #{matched_version(version)}"
          end
        end

        def run_with_version(version)
          #puts switch_ruby_version(matched_version(version))
          #system switch_ruby_version(matched_version(version))
          yield
        end
      end
    end
  end
end
