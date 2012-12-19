module Qor
  module Test
    class Ruby
      class << self

        def rvm?
          %x(sh -c "command -v rvm").size > 0
        end

        def rbenv?
          %x(sh -c "command -v rbenv").size > 0
        end

        def version_manager_installed?
          rvm? || rbenv?
        end

        def versions
          if rvm?
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
            "rvm use #{matched_version(version)}"
          elsif rbenv?
            "export RBENV_VERSION=#{matched_version(version)}"
          end
        end

      end
    end
  end
end
