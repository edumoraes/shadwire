# frozen_string_literal: true

require "test_helper"
require "rubygems"

# The gem declared MIT for three releases while shipping no licence text, which
# is the one file the licence asks every copy to carry.
class GemspecTest < Minitest::Test
  SPEC = Gem::Specification.load(File.expand_path("../shadwire.gemspec", __dir__))

  def test_declares_a_licence
    assert_equal [ "MIT" ], SPEC.licenses
  end

  def test_ships_the_licence_text
    assert_includes SPEC.files, "LICENSE"
    assert_path_exists File.expand_path("../LICENSE", __dir__)
  end

  def test_the_shipped_licence_matches_the_declared_one
    body = File.read(File.expand_path("../LICENSE", __dir__))

    assert_includes body, "MIT License"
    assert_includes body, "Permission is hereby granted, free of charge"
  end

  def test_the_gem_licence_matches_the_repository_licence
    gem_licence = File.read(File.expand_path("../LICENSE", __dir__))
    repo_licence = File.read(File.expand_path("../../../LICENSE", __dir__))

    assert_equal repo_licence, gem_licence, "packages/cli/LICENSE has drifted from the repository LICENSE"
  end
end
