# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class BinstubTest < Minitest::Test
  def test_writes_an_executable_binstub
    Dir.mktmpdir do |root|
      result = Shadwire::Binstub.write(root)

      path = File.join(root, "bin/shadwire")
      assert_equal({ written: true, skipped: false }, result)
      assert_path_exists path
      assert_equal 0o755, File.stat(path).mode & 0o777
    end
  end

  def test_loads_the_gem_binary_through_bundler
    Dir.mktmpdir do |root|
      Shadwire::Binstub.write(root)

      body = File.read(File.join(root, "bin/shadwire"))
      assert_equal "#!/usr/bin/env ruby\n", body.lines.first
      assert_includes body, %(require "bundler/setup")
      assert_includes body, %(load Gem.bin_path("shadwire", "shadwire"))
    end
  end

  def test_creates_the_bin_directory_when_absent
    Dir.mktmpdir do |root|
      refute_path_exists File.join(root, "bin")

      Shadwire::Binstub.write(root)

      assert_path_exists File.join(root, "bin/shadwire")
    end
  end

  # `bundle binstubs shadwire` produces a longer, Bundler-generated binstub that
  # works correctly. Clobbering it would destroy a working file that
  # `shadwire diff` does not track and therefore cannot report.
  def test_leaves_an_existing_binstub_alone
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "bin"))
      File.write(File.join(root, "bin/shadwire"), "# hand-rolled\n")

      result = Shadwire::Binstub.write(root)

      assert_equal({ written: false, skipped: true }, result)
      assert_equal "# hand-rolled\n", File.read(File.join(root, "bin/shadwire"))
    end
  end

  def test_force_overwrites_an_existing_binstub
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "bin"))
      File.write(File.join(root, "bin/shadwire"), "# hand-rolled\n")

      result = Shadwire::Binstub.write(root, force: true)

      assert_equal({ written: true, skipped: false }, result)
      assert_includes File.read(File.join(root, "bin/shadwire")), "bundler/setup"
    end
  end
end
