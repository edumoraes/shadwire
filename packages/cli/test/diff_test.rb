# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

class DiffTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def noop_runner
    ->(_cmd, chdir:) { true }
  end

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:, yes: true)
  end

  def initialized_app
    Dir.mktmpdir do |tmp|
      root = File.join(tmp, "app")
      FileUtils.cp_r(FIXTURE_APP, root)
      Shadwire::Commands::Init.new(
        root:, registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: noop_runner
      ).call
      yield root
    end
  end

  def add(root, name)
    Shadwire::Commands::Add.new(
      root:, names: Array(name), registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: noop_runner
    ).call
  end

  def diff(root, names = [], ui: silent_ui, **opts)
    Shadwire::Commands::Diff.new(root:, names: Array(names), registry: FILE_REGISTRY, ui:, **opts).call
  end

  def test_unmodified_install_reports_no_drift
    initialized_app do |root|
      add(root, "button")
      result = diff(root, "button")

      assert(result[:entries].all? { |e| e[:status] == "unchanged" })
      refute result[:drifted]
    end
  end

  def test_locally_modified_file_reports_modified_with_a_diff
    initialized_app do |root|
      add(root, "button")
      target = "app/components/ui/button_component.rb"
      File.write(File.join(root, target), "# edited locally\n")

      result = diff(root, "button")

      modified = result[:entries].select { |e| e[:status] == "modified" }
      assert_equal [target], modified.map { |e| e[:file] }
      assert result[:drifted]
      assert_match(/button component/, result[:diffs]["button:#{target}"])
    end
  end

  def test_deleted_file_reports_missing
    initialized_app do |root|
      add(root, "button")
      File.delete(File.join(root, "app/components/ui/button_component.rb"))

      result = diff(root, "button")

      assert(result[:entries].any? { |e| e[:file].end_with?("button_component.rb") && e[:status] == "missing" })
      assert result[:drifted]
    end
  end

  def test_no_name_checks_every_installed_item
    initialized_app do |root|
      add(root, "button")
      add(root, "chart")

      names = diff(root).fetch(:entries).map { |e| e[:name] }.uniq
      assert_includes names, "button"
      assert_includes names, "chart"
    end
  end

  def test_json_emits_status_array
    initialized_app do |root|
      add(root, "button")
      out = StringIO.new
      diff(root, "button", json: true, ui: silent_ui(out:))

      parsed = JSON.parse(out.string)
      assert_kind_of Array, parsed
      assert(parsed.all? { |e| e.key?("name") && e.key?("file") && e.key?("status") })
    end
  end

  def test_diffing_an_uninstalled_name_raises
    initialized_app do |root|
      error = assert_raises(Shadwire::Error) { diff(root, "button") }
      assert_match(/not installed/, error.message)
    end
  end
end
