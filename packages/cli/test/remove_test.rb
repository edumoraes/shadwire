# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

class RemoveTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  BASE_FILES = [
    "app/components/ui_component.rb",
    "app/helpers/ui_helper.rb",
    "vendor/shadwire/shadwire.css"
  ].freeze

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

  def add(root, name)
    Shadwire::Commands::Add.new(
      root:, names: Array(name), registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: noop_runner
    ).call
  end

  def remove(root, names, ui: silent_ui, **opts)
    Shadwire::Commands::Remove.new(
      root:, names: Array(names), registry: FILE_REGISTRY, ui:, **opts
    ).call
  end

  def installed(root)
    JSON.parse(File.read(File.join(root, "shadwire.json")))["installed"]
  end

  def exists?(root, target)
    File.exist?(File.join(root, target))
  end

  # ── deletes only the item's own files ──────────────────────────────────────

  def test_remove_deletes_only_the_items_own_files
    initialized_app do |root|
      add(root, "button")
      add(root, "card")

      remove(root, "button", yes: true)

      refute exists?(root, "app/components/ui/button_component.rb"), "button's own file must be deleted"
      BASE_FILES.each { |f| assert exists?(root, f), "shared base file #{f} must survive" }
      assert exists?(root, "app/components/ui/card_component.rb"), "card's files must survive"
      assert exists?(root, "app/components/ui/card/header_component.rb")
      refute installed(root).key?("button")
      assert installed(root).key?("card")
    end
  end

  def test_remove_never_deletes_shared_base_still_used_by_another_item
    initialized_app do |root|
      add(root, "button")
      add(root, "card")

      result = remove(root, "button", yes: true)

      assert_equal ["app/components/ui/button_component.rb"], result[:deleted]
      assert_includes result[:keptShared], "app/components/ui_component.rb"
    end
  end

  # ── prunes emptied directories ─────────────────────────────────────────────

  def test_remove_prunes_emptied_component_directory
    initialized_app do |root|
      add(root, "button")
      add(root, "card")
      assert File.directory?(File.join(root, "app/components/ui/card"))

      remove(root, "card", yes: true)

      refute File.directory?(File.join(root, "app/components/ui/card")),
             "the emptied card/ directory should be pruned"
      assert File.directory?(File.join(root, "app/components/ui")),
             "ui/ still holds button and must not be pruned"
    end
  end

  # ── confirmation ───────────────────────────────────────────────────────────

  def test_declined_confirmation_deletes_nothing
    initialized_app do |root|
      add(root, "button")
      ui, prompts = ui_with_prompt(answer: false)

      remove(root, "button", ui:, yes: false)

      assert exists?(root, "app/components/ui/button_component.rb"), "a declined removal deletes nothing"
      assert installed(root).key?("button")
      refute_empty prompts
    end
  end

  # ── unused importmap pins ──────────────────────────────────────────────────

  def test_removing_last_pinning_component_reports_unused_pin_without_editing_importmap
    initialized_app do |root|
      add(root, "chart")
      importmap_before = File.read(File.join(root, "config/importmap.rb"))

      result = remove(root, "chart", yes: true)

      pin_names = result[:unusedPins].map { |pin| pin["name"] }
      assert_includes pin_names, "chart.js/auto"
      assert_equal importmap_before, File.read(File.join(root, "config/importmap.rb")),
                   "remove must not auto-edit importmap.rb"
    end
  end

  def test_remove_json_summary
    initialized_app do |root|
      add(root, "button")
      out = StringIO.new
      remove(root, "button", yes: true, json: true, ui: silent_ui(out:))

      parsed = JSON.parse(out.string)
      assert_includes parsed["removed"], "button"
      assert_includes parsed["deleted"], "app/components/ui/button_component.rb"
    end
  end

  # ── errors ─────────────────────────────────────────────────────────────────

  def test_remove_with_no_name_raises
    initialized_app do |root|
      assert_raises(Shadwire::Error) { remove(root, [], yes: true) }
    end
  end

  def test_remove_uninstalled_name_raises
    initialized_app do |root|
      error = assert_raises(Shadwire::Error) { remove(root, "button", yes: true) }
      assert_match(/not installed/, error.message)
    end
  end
end
