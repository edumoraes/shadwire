# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

# Drives the real Thor entrypoint (Shadwire::CLI.start) end to end against the
# file:// fixture registry — the layer the per-command unit tests bypass. It
# exercises option parsing, the global --cwd, --registry/--json/--exit-code,
# run_command's error handling and exit codes, and the whole
# init → browse → add → diff → update → remove workflow.
#
# The scaffolded app pre-declares the base gems (view_component, lucide-rails)
# so `ensure_gems` finds them present and the CLI never shells out to bundler;
# no fixture item declares its own gems, so the suite runs without a real bundle.
class CliIntegrationTest < Minitest::Test
  FILE_REGISTRY = "file://#{File.expand_path("../fixtures/registry", __dir__)}"

  Result = Struct.new(:stdout, :stderr, :status)

  def setup
    @dir = Dir.mktmpdir
    @app = File.join(@dir, "app")
    scaffold_app(@app)
  end

  def teardown
    FileUtils.remove_entry(@dir) if @dir && File.directory?(@dir)
  end

  # Runs `shadwire <argv> --cwd <app>` in-process through the real Thor CLI,
  # capturing stdout/stderr and the exit status (0 unless the command called
  # exit or raised a Shadwire::Error).
  def shadwire(*argv)
    out = StringIO.new
    err = StringIO.new
    old_out = $stdout
    old_err = $stderr
    $stdout = out
    $stderr = err
    status = 0
    begin
      Shadwire::CLI.start([*argv.map(&:to_s), "--cwd", @app])
    rescue SystemExit => e
      status = e.status
    rescue Shadwire::Error => e
      err.puts(e.message)
      status = 1
    ensure
      $stdout = old_out
      $stderr = old_err
    end
    Result.new(out.string, err.string, status)
  end

  def app_path(relative)
    File.join(@app, relative)
  end

  def test_init_browse_add_diff_update_remove_workflow
    init = shadwire("init", "--registry", FILE_REGISTRY, "--yes")
    assert_equal 0, init.status
    assert File.exist?(app_path("shadwire.json"))
    assert File.exist?(app_path("app/components/ui_component.rb"))

    # After init the registry is recorded in shadwire.json, so later commands
    # resolve it without --registry.
    catalog = JSON.parse(shadwire("list", "--json").stdout)
    assert(catalog.any? { |item| item["name"] == "button" })

    names = JSON.parse(shadwire("search", "table", "--json").stdout).map { |item| item["name"] }
    assert_equal %w[table data-table], names

    info = JSON.parse(shadwire("info", "button", "--json").stdout)
    assert(info["files"].none? { |file| file.key?("content") }, "info must not leak file content")

    add = shadwire("add", "button", "card", "--yes")
    assert_equal 0, add.status
    assert File.exist?(app_path("app/components/ui/button_component.rb"))
    assert File.exist?(app_path("app/components/ui/card/header_component.rb"))

    # No drift right after install → --exit-code is 0.
    assert_equal 0, shadwire("diff", "--exit-code").status

    # Hand-edit → drift is reported and --exit-code is non-zero.
    File.write(app_path("app/components/ui/button_component.rb"), "# edited\n")
    entry = JSON.parse(shadwire("diff", "button", "--json").stdout)
            .find { |e| e["file"].end_with?("button_component.rb") }
    assert_equal "modified", entry["status"]
    assert_equal 1, shadwire("diff", "button", "--exit-code").status

    # update restores upstream → clean again.
    assert_equal 0, shadwire("update", "button", "--yes").status
    assert_equal "# button component\n", File.read(app_path("app/components/ui/button_component.rb"))
    assert_equal 0, shadwire("diff", "--exit-code").status

    # remove deletes only button's own file, keeping the shared base and card.
    payload = JSON.parse(shadwire("remove", "button", "--yes", "--json").stdout)
    assert_equal ["app/components/ui/button_component.rb"], payload["deleted"]
    refute File.exist?(app_path("app/components/ui/button_component.rb"))
    assert File.exist?(app_path("app/components/ui_component.rb"))
    assert File.exist?(app_path("app/components/ui/card_component.rb"))
  end

  def test_add_pins_importmap_and_remove_reports_unused_pin
    shadwire("init", "--registry", FILE_REGISTRY, "--yes")
    shadwire("add", "chart", "--yes")

    importmap = File.read(app_path("config/importmap.rb"))
    assert_match(%r{pin "chart.js/auto"}, importmap)

    payload = JSON.parse(shadwire("remove", "chart", "--yes", "--json").stdout)
    assert(payload["unusedPins"].any? { |pin| pin["name"] == "chart.js/auto" })
    assert_equal importmap, File.read(app_path("config/importmap.rb")),
                 "remove must not auto-edit importmap.rb"
  end

  def test_command_errors_exit_nonzero
    shadwire("init", "--registry", FILE_REGISTRY, "--yes")

    assert_equal 1, shadwire("remove").status,                     "remove with no name"
    assert_equal 1, shadwire("add", "nonexistent", "--yes").status, "unknown registry item"
    assert_equal 1, shadwire("diff", "button").status,             "diff of an uninstalled item"
  end

  private

  def scaffold_app(app)
    FileUtils.mkdir_p(File.join(app, "config"))
    FileUtils.mkdir_p(File.join(app, "app/assets/tailwind"))
    FileUtils.mkdir_p(File.join(app, "app/javascript/controllers"))

    File.write(File.join(app, "Gemfile"), <<~RUBY)
      # frozen_string_literal: true
      source "https://rubygems.org"
      gem "rails", "~> 8.1"
      gem "importmap-rails"
      gem "stimulus-rails"
      gem "tailwindcss-rails"
      gem "view_component"
      gem "lucide-rails"
    RUBY
    File.write(File.join(app, "config/application.rb"), <<~RUBY)
      require "rails"
      module ShadwireDemo
        class Application < Rails::Application; end
      end
    RUBY
    File.write(File.join(app, "config/importmap.rb"), <<~RUBY)
      pin "application"
      pin_all_from "app/javascript/controllers", under: "controllers"
    RUBY
    File.write(File.join(app, "app/assets/tailwind/application.css"), %(@import "tailwindcss";\n))
    File.write(File.join(app, "app/javascript/controllers/index.js"), "// controllers\n")
  end
end
