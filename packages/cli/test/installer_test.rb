# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class InstallerTest < Minitest::Test
  # Helper to build a file entry (published shape from build_registry)
  def entry(target:, content: "content for #{target}", type: "component")
    { "target" => target, "type" => type, "content" => content }
  end

  # ── 1. Writes new files and creates nested parent dirs ──────────────────────

  def test_writes_new_file_to_root
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      report = installer.install([entry(target: "app/components/ui/button_component.rb")])

      assert_equal ["app/components/ui/button_component.rb"], report[:written]
      assert_empty report[:skipped]
      assert File.exist?(File.join(root, "app/components/ui/button_component.rb"))
    end
  end

  def test_creates_nested_parent_directories
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      installer.install([entry(target: "deep/a/b/c/file.rb")])

      assert File.exist?(File.join(root, "deep/a/b/c/file.rb"))
    end
  end

  def test_written_file_has_correct_content
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      installer.install([entry(target: "app/file.rb", content: "# hello world\n")])

      assert_equal "# hello world\n", File.read(File.join(root, "app/file.rb"))
    end
  end

  def test_multiple_files_all_listed_as_written
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      files = [
        entry(target: "app/components/button.rb"),
        entry(target: "app/helpers/ui_helper.rb"),
        entry(target: "vendor/shadwire/shadwire.css")
      ]
      report = installer.install(files)

      assert_equal 3, report[:written].size
      assert_includes report[:written], "app/components/button.rb"
      assert_includes report[:written], "app/helpers/ui_helper.rb"
      assert_includes report[:written], "vendor/shadwire/shadwire.css"
      assert_empty report[:skipped]
    end
  end

  # ── 2. Escape-path check ─────────────────────────────────────────────────────

  def test_raises_on_relative_escape_target
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      err = assert_raises(Shadwire::RegistryError) do
        installer.install([entry(target: "../outside.rb")])
      end
      assert_match "outside.rb", err.message
    end
  end

  def test_raises_on_deep_relative_escape_target
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      err = assert_raises(Shadwire::RegistryError) do
        installer.install([entry(target: "app/../../secret.rb")])
      end
      assert_match "secret.rb", err.message
    end
  end

  def test_escape_check_raises_before_any_write
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      files = [
        entry(target: "app/legit.rb"),
        entry(target: "../escape.rb")
      ]
      assert_raises(Shadwire::RegistryError) { installer.install(files) }
      refute File.exist?(File.join(root, "app/legit.rb")), "no file should be written before raising"
    end
  end

  # ── 3. Conflict check (same target, different content) ──────────────────────

  def test_raises_on_conflicting_targets
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      files = [
        entry(target: "app/conflict.rb", content: "version A"),
        entry(target: "app/conflict.rb", content: "version B")
      ]
      err = assert_raises(Shadwire::RegistryError) do
        installer.install(files)
      end
      assert_match "conflict.rb", err.message
    end
  end

  def test_conflict_raises_before_any_write
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      files = [
        entry(target: "app/first.rb"),
        entry(target: "app/conflict.rb", content: "version A"),
        entry(target: "app/conflict.rb", content: "version B")
      ]
      assert_raises(Shadwire::RegistryError) { installer.install(files) }
      refute File.exist?(File.join(root, "app/first.rb")), "no file should be written before raising"
    end
  end

  # ── 4. Identical content de-dup (shared base files) ─────────────────────────

  def test_deduplicates_same_target_identical_content
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :always)
      shared_content = "# shared\n"
      files = [
        entry(target: "vendor/shadwire/shadwire.css", content: shared_content),
        entry(target: "vendor/shadwire/shadwire.css", content: shared_content)
      ]
      report = installer.install(files)

      # No raise; written exactly once
      assert_equal ["vendor/shadwire/shadwire.css"], report[:written]
      assert_equal shared_content, File.read(File.join(root, "vendor/shadwire/shadwire.css"))
    end
  end

  # ── 5. Overwrite policy :always ──────────────────────────────────────────────

  def test_always_overwrites_existing_file
    Dir.mktmpdir do |root|
      path = File.join(root, "app/button.rb")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "old content")

      installer = Shadwire::Installer.new(root, overwrite: :always)
      report = installer.install([entry(target: "app/button.rb", content: "new content")])

      assert_equal "new content", File.read(path)
      assert_equal ["app/button.rb"], report[:written]
      assert_empty report[:skipped]
    end
  end

  # ── 6. Overwrite policy :never ───────────────────────────────────────────────

  def test_never_skips_existing_file
    Dir.mktmpdir do |root|
      path = File.join(root, "app/button.rb")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "original")

      installer = Shadwire::Installer.new(root, overwrite: :never)
      report = installer.install([entry(target: "app/button.rb", content: "replacement")])

      assert_equal "original", File.read(path), "content must be unchanged"
      assert_empty report[:written]
      assert_equal ["app/button.rb"], report[:skipped]
    end
  end

  def test_never_still_writes_new_files
    Dir.mktmpdir do |root|
      installer = Shadwire::Installer.new(root, overwrite: :never)
      report = installer.install([entry(target: "app/new_file.rb", content: "fresh")])

      assert_equal "fresh", File.read(File.join(root, "app/new_file.rb"))
      assert_equal ["app/new_file.rb"], report[:written]
      assert_empty report[:skipped]
    end
  end

  # ── 7. Overwrite policy :prompt ──────────────────────────────────────────────

  def test_prompt_with_confirm_true_overwrites_existing_file
    Dir.mktmpdir do |root|
      path = File.join(root, "app/button.rb")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "old")

      received_target = nil
      confirm = ->(t) { received_target = t; true }

      installer = Shadwire::Installer.new(root, overwrite: :prompt, confirm: confirm)
      report = installer.install([entry(target: "app/button.rb", content: "new")])

      assert_equal "new", File.read(path)
      assert_equal ["app/button.rb"], report[:written]
      assert_empty report[:skipped]
      assert_equal "app/button.rb", received_target, "confirm lambda must receive the target path"
    end
  end

  def test_prompt_with_confirm_false_skips_existing_file
    Dir.mktmpdir do |root|
      path = File.join(root, "app/button.rb")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "original")

      received_target = nil
      confirm = ->(t) { received_target = t; false }

      installer = Shadwire::Installer.new(root, overwrite: :prompt, confirm: confirm)
      report = installer.install([entry(target: "app/button.rb", content: "replacement")])

      assert_equal "original", File.read(path)
      assert_empty report[:written]
      assert_equal ["app/button.rb"], report[:skipped]
      assert_equal "app/button.rb", received_target, "confirm lambda must still be called"
    end
  end

  def test_prompt_does_not_call_confirm_for_new_files
    Dir.mktmpdir do |root|
      confirm_called = false
      confirm = ->(_t) { confirm_called = true; true }

      installer = Shadwire::Installer.new(root, overwrite: :prompt, confirm: confirm)
      installer.install([entry(target: "app/new_file.rb", content: "fresh")])

      refute confirm_called, "confirm must not be called for files that do not yet exist"
    end
  end
end
