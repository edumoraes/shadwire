# frozen_string_literal: true

require "thor"

module Shadwire
  class CLI < Thor
    package_name "shadwire"

    desc "version", "Print the shadwire version"
    def version
      puts Shadwire::VERSION
    end
  end
end
