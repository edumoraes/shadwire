# frozen_string_literal: true

require_relative "lib/shadwire/version"

Gem::Specification.new do |spec|
  spec.name          = "shadwire"
  spec.version       = Shadwire::VERSION
  spec.authors       = ["Eduardo de Moraes"]
  spec.email         = ["edumoraesdg@gmail.com"]

  spec.summary       = "shadcn/ui components for Ruby on Rails"
  spec.description   = "Shadwire installs shadcn/ui-style ViewComponent source into a " \
                       "Rails app the shadcn Open Code way: components are copied in and " \
                       "owned by your app, with no runtime dependency on Shadwire."
  spec.homepage      = "https://github.com/edumoraes/shadwire"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*.rb", "exe/**/*"] + ["README.md"]
  spec.executables   = ["shadwire"]
  spec.bindir        = "exe"

  spec.add_dependency "thor", "~> 1.5"
end
