# frozen_string_literal: true

module Shadwire
  # Resolves a list of item names to a de-duplicated, dependency-first ordered
  # array of parsed item hashes.  Uses post-order DFS so every dependency
  # appears before the item that requires it.  Unknown names — whether
  # top-level or pulled in transitively — raise Shadwire::RegistryError.
  class Resolver
    # Public API: returns an Array of item Hashes, dependency-first.
    def self.expand(names, client)
      new(client).expand(names)
    end

    def initialize(client)
      @client  = client
      @visited = {}   # name => true once fully processed
      @result  = []
    end

    def expand(names)
      names.each { |name| visit(name) }
      @result
    end

    private

    def visit(name)
      return if @visited[name]

      # Mark before recursing to break potential cycles and prevent double-add.
      @visited[name] = true

      # Fetch the item; RegistryError propagates on 404 / missing file.
      data = @client.item(name)

      # Recurse into dependencies first (post-order).
      Array(data["registryDependencies"]).each { |dep| visit(dep) }

      # Add this item after all its deps are in the result.
      @result << data
    end
  end
end
