# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

class UpdateTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def noop_runner
    ->(_cmd, chdir:) { true }
  end

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:, yes: true)
  end

  def ui_with_prompt(answer:)
    prompts = []
    confirm_proc = ->(q) { prompts << q; answer }
    [Shadwire::UI.new(out: StringIO.new, err: StringIO.new, yes: false, confirm_proc:), prompts]
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

  def add(root, name, **opts)
    Shadwire::Commands::Add.new(
      root:, names: Array(name), registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: noop_runner, **opts
    ).call
  end

  def update(root, names = [], ui: silent_ui, **opts)
    Shadwire::Commands::Update.new(
      root:, names: Array(names), registry: FILE_REGISTRY, ui:, runner: noop_runner, **opts
    ).call
  end

  def installed(root)
    JSON.parse(File.read(File.join(root, "shadwire.json")))["installed"]
  end

  def test_update_restores_a_locally_modified_file_and_surfaces_the_diff
    initialized_app do |root|
      add(root, "button")
      target = "app/components/ui/button_component.rb"
      File.write(File.join(root, target), "# hand-edited\n")

      result = update(root, "button", yes: true)

      assert_equal "# button component\n", File.read(File.join(root, target))
      assert result[:diffs].key?(target), "local edit must be surfaced before overwrite"
      assert installed(root)["button"]["version"]
    end
  end

  def test_update_no_deps_does_not_pull_dependencies
    initialized_app do |root|
      add(root, "data-table")
      table = "app/components/ui/table_component.rb"
      File.delete(File.join(root, table))

      update(root, "data-table", yes: true, no_deps: true)

      refute File.exist?(File.join(root, table)),
             "with --no-deps update must not re-fetch transitive deps"
    end
  end

  def test_update_with_no_name_updates_all_installed
    initialized_app do |root|
      add(root, "button")
      add(root, "input")
      File.write(File.join(root, "app/components/ui/button_component.rb"), "# edited\n")
      File.write(File.join(root, "app/components/ui/input_component.rb"), "# edited\n")

      result = update(root, yes: true)

      assert_equal "# button component\n", File.read(File.join(root, "app/components/ui/button_component.rb"))
      assert_equal "# input component\n", File.read(File.join(root, "app/components/ui/input_component.rb"))
      assert_includes result[:updated], "button"
      assert_includes result[:updated], "input"
    end
  end

  def test_update_without_yes_does_not_clobber_a_declined_edit
    initialized_app do |root|
      add(root, "button")
      target = "app/components/ui/button_component.rb"
      File.write(File.join(root, target), "# precious local edit\n")
      ui, prompts = ui_with_prompt(answer: false)

      update(root, "button", ui:)

      assert_equal "# precious local edit\n", File.read(File.join(root, target))
      refute_empty prompts
    end
  end

  def test_update_json_summary
    initialized_app do |root|
      add(root, "button")
      out = StringIO.new
      update(root, "button", yes: true, json: true, ui: silent_ui(out:))

      parsed = JSON.parse(out.string)
      assert_includes parsed["updated"], "button"
      assert parsed.key?("written")
    end
  end

  def test_update_uninstalled_name_raises
    initialized_app do |root|
      error = assert_raises(Shadwire::Error) { update(root, "button", yes: true) }
      assert_match(/not installed/, error.message)
    end
  end
end
