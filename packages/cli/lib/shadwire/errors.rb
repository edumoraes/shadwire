# frozen_string_literal: true

module Shadwire
  class Error < StandardError; end
  class RegistryError < Error; end
  class ConfigError < Error; end
  class ProjectError < Error; end
end
