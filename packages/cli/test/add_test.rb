# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

class AddTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def noop_runner
    ->(_cmd, chdir:) { true }
  end

  def silent_ui(yes: true)
    Shadwire::UI.new(out: StringIO.new, err: StringIO.new, yes:)
  end

  # A UI that records prompt questions and answers each with `answer`.
  def ui_with_prompt(answer:, yes: false)
    prompts = []
    confirm_proc = ->(q) { prompts << q; answer }
    ui = Shadwire::UI.new(out: StringIO.new, err: StringIO.new, yes:, confirm_proc:)
    [ui, prompts]
  end

  # Copies the fixture app into a tmpdir, runs `init`, and yields the app root.
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

  def add(root, names, **opts)
    Shadwire::Commands::Add.new(
      root:, names: Array(names), registry: FILE_REGISTRY,
      ui: opts.delete(:ui) || silent_ui, runner: noop_runner, **opts
    ).call
  end

  def installed(root)
    JSON.parse(File.read(File.join(root, "shadwire.json")))["installed"]
  end

  # ── basic add ────────────────────────────────────────────────────────────────

  def test_add_button_writes_component_and_records_it
    initialized_app do |root|
      ui, prompts = ui_with_prompt(answer: false)
      add(root, "button", ui:)

      assert_equal "# button component\n",
                   File.read(File.join(root, "app/components/ui/button_component.rb"))
      assert installed(root).key?("button")
      assert_includes installed(root)["button"]["files"], "app/components/ui/button_component.rb"
      # shared base files already exist identical → skipped silently, no prompt
      assert_empty prompts
    end
  end

  # ── transitive dependencies ──────────────────────────────────────────────────

  def test_add_data_table_pulls_transitive_deps
    initialized_app do |root|
      add(root, "data-table", yes: true)

      assert File.exist?(File.join(root, "app/components/ui/data_table_component.rb"))
      %w[table button input checkbox dropdown_menu].each do |c|
        assert File.exist?(File.join(root, "app/components/ui/#{c}_component.rb")),
               "expected transitive dep #{c} to be installed"
      end
      assert File.exist?(File.join(root, "app/javascript/controllers/ui_data_table_controller.js"))
    end
  end

  def test_add_no_deps_installs_only_named_item
    initialized_app do |root|
      add(root, "data-table", yes: true, no_deps: true)

      assert File.exist?(File.join(root, "app/components/ui/data_table_component.rb"))
      refute File.exist?(File.join(root, "app/components/ui/table_component.rb")),
             "with --no-deps transitive deps must not be installed"
    end
  end

  # ── importmap pin ────────────────────────────────────────────────────────────

  def test_add_chart_appends_importmap_pin
    initialized_app do |root|
      add(root, "chart", yes: true)

      content = File.read(File.join(root, "config/importmap.rb"))
      assert_includes content,
                      %(pin "chart.js/auto", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.6/auto/+esm")
    end
  end

  def test_add_chart_pin_is_idempotent
    initialized_app do |root|
      add(root, "chart", yes: true)
      before = File.read(File.join(root, "config/importmap.rb"))
      add(root, "chart", yes: true)
      after = File.read(File.join(root, "config/importmap.rb"))

      assert_equal before, after
    end
  end

  # ── overwrite policy ─────────────────────────────────────────────────────────

  def test_add_prompts_and_skips_modified_file_when_declined
    initialized_app do |root|
      File.write(File.join(root, "app/components/ui_component.rb"), "# locally modified\n")
      ui, prompts = ui_with_prompt(answer: false)

      add(root, "button", ui:)

      assert_equal "# locally modified\n",
                   File.read(File.join(root, "app/components/ui_component.rb"))
      refute_empty prompts, "a locally-modified file must trigger a prompt"
    end
  end

  def test_add_overwrite_flag_replaces_without_prompt
    initialized_app do |root|
      File.write(File.join(root, "app/components/ui_component.rb"), "# locally modified\n")
      ui, prompts = ui_with_prompt(answer: false)

      add(root, "button", overwrite: true, ui:)

      assert_equal "# ui_component\n",
                   File.read(File.join(root, "app/components/ui_component.rb"))
      assert_empty prompts
    end
  end

  # ── errors ───────────────────────────────────────────────────────────────────

  def test_add_raises_registry_error_for_unknown_item
    initialized_app do |root|
      assert_raises(Shadwire::RegistryError) { add(root, "nonexistent", yes: true) }
    end
  end
end
