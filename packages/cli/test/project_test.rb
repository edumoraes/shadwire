# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class ProjectTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)

  # Copies the fake Rails app fixture into a fresh tmpdir and yields its root,
  # so tests can mutate the copy freely.
  def with_app
    Dir.mktmpdir do |tmp|
      root = File.join(tmp, "app")
      FileUtils.cp_r(FIXTURE_APP, root)
      yield root
    end
  end

  # ── #rails? ──────────────────────────────────────────────────────────────────

  def test_rails_true_when_gemfile_declares_rails
    with_app do |root|
      assert Shadwire::Project.new(root).rails?
    end
  end

  def test_rails_true_when_config_application_rb_exists
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "config"))
      File.write(File.join(root, "config/application.rb"), "# app\n")
      assert Shadwire::Project.new(root).rails?
    end
  end

  def test_rails_false_for_non_rails_directory
    Dir.mktmpdir do |root|
      refute Shadwire::Project.new(root).rails?
    end
  end

  # ── #gem? ────────────────────────────────────────────────────────────────────

  def test_gem_true_from_gemfile
    with_app do |root|
      assert Shadwire::Project.new(root).gem?("importmap-rails")
    end
  end

  def test_gem_false_when_absent
    with_app do |root|
      refute Shadwire::Project.new(root).gem?("view_component")
    end
  end

  def test_gem_reads_gemfile_lock_first
    with_app do |root|
      # Present in the lock but not in the Gemfile: proves the lock is consulted.
      File.write(File.join(root, "Gemfile.lock"), <<~LOCK)
        GEM
          remote: https://rubygems.org/
          specs:
            view_component (4.0.0)

        PLATFORMS
          ruby
      LOCK
      assert Shadwire::Project.new(root).gem?("view_component")
    end
  end

  # ── stack booleans ───────────────────────────────────────────────────────────

  def test_importmap_true_from_gem_and_config
    with_app do |root|
      assert Shadwire::Project.new(root).importmap?
    end
  end

  def test_tailwindcss_rails_true_from_gem
    with_app do |root|
      assert Shadwire::Project.new(root).tailwindcss_rails?
    end
  end

  def test_stimulus_true_from_gem
    with_app do |root|
      assert Shadwire::Project.new(root).stimulus?
    end
  end

  def test_stack_booleans_false_on_bare_gemfile
    Dir.mktmpdir do |root|
      File.write(File.join(root, "Gemfile"), %(source "https://rubygems.org"\ngem "rails"\n))
      project = Shadwire::Project.new(root)
      refute project.importmap?
      refute project.tailwindcss_rails?
      refute project.stimulus?
    end
  end

  # ── paths ────────────────────────────────────────────────────────────────────

  def test_importmap_path
    with_app do |root|
      assert_equal File.join(root, "config/importmap.rb"),
                   Shadwire::Project.new(root).importmap_path
    end
  end

  def test_tailwind_css_path_defaults_to_convention
    with_app do |root|
      assert_equal File.join(root, "app/assets/tailwind/application.css"),
                   Shadwire::Project.new(root).tailwind_css_path
    end
  end

  def test_tailwind_css_path_accepts_override
    with_app do |root|
      assert_equal File.join(root, "app/assets/stylesheets/app.css"),
                   Shadwire::Project.new(root).tailwind_css_path("app/assets/stylesheets/app.css")
    end
  end

  # ── #raise_unless_rails! ─────────────────────────────────────────────────────

  def test_raise_unless_rails_passes_for_rails_app
    with_app do |root|
      assert_nil Shadwire::Project.new(root).raise_unless_rails!
    end
  end

  def test_raise_unless_rails_raises_project_error
    Dir.mktmpdir do |root|
      err = assert_raises(Shadwire::ProjectError) do
        Shadwire::Project.new(root).raise_unless_rails!
      end
      assert_match(/rails/i, err.message)
    end
  end

  # ── #binstub? ────────────────────────────────────────────────────────────────

  def test_binstub_false_without_the_file
    with_app do |root|
      refute Shadwire::Project.new(root).binstub?
    end
  end

  def test_binstub_true_when_bin_shadwire_exists
    with_app do |root|
      FileUtils.mkdir_p(File.join(root, "bin"))
      File.write(File.join(root, "bin/shadwire"), "#!/usr/bin/env ruby\n")

      assert Shadwire::Project.new(root).binstub?
    end
  end
end
