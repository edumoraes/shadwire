# frozen_string_literal: true

require_relative "lib/shadwire/version"

Gem::Specification.new do |spec|
  spec.name          = "shadwire"
  spec.version       = Shadwire::VERSION
  spec.authors       = ["Eduardo de Moraes"]
  spec.email         = ["edumoraesdg@gmail.com"]

  spec.summary       = "shadcn/ui components for Ruby on Rails"
  spec.homepage      = "https://github.com/edumoraes/shadwire"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*.rb", "exe/**/*"]
  spec.executables   = ["shadwire"]
  spec.bindir        = "exe"

  spec.add_dependency "thor", "~> 1.5"
end
