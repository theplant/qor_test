module Qor
  module Test
    class Rubies
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
          result = ["^#{version}", version].map do |x|
            versions.select {|v| v =~ Regexp.new(x) }[-1]
          end.compact[0]
          not_installed!(version) unless result
          result
        end

        def switch_ruby_version(version)
          if rvm?
            "[ -f $rvm_path/scripts/rvm ] && source $rvm_path/scripts/rvm; rvm use #{matched_version(version)}"
          elsif rbenv?
            "export RBENV_VERSION=#{matched_version(version)}"
          elsif (`ruby -v` !~ Regexp.new(version))
            not_installed!(version)
          end
        end

        def not_installed!(version)
          puts "ruby '#{version}' is not installed! please install it first!"
          exit
        end

      end
    end
  end
end
