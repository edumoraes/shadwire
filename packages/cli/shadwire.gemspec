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

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "#{spec.homepage}/tree/main/packages/cli",
    "changelog_uri" => "#{spec.homepage}/releases",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  # LICENSE ships with the gem: spec.license only names the licence, it does not
  # deliver the text the licence itself requires copies to carry.
  spec.files = Dir["lib/**/*.rb", "exe/**/*"] + ["README.md", "LICENSE"]
  spec.executables   = ["shadwire"]
  spec.bindir        = "exe"

  spec.add_dependency "thor", "~> 1.5"
end
