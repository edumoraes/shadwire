# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"
require "tmpdir"
require "fileutils"
require "shellwords"
require "set"

# Guards the agent skill against drifting from the registry and CLI it
# documents. Deterministic — no model in the loop.
#
# Every documentation failure this repo has had was the same bug: facts copied
# into prose and left to rot (the README naming 28 components while the registry
# had 58). The skill is designed to carry procedure rather than data, and this
# suite enforces that the little data it does carry stays true.
class SkillCheckTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  SKILL_DIR = ROOT.join("skills/shadwire")
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)

  SKILL_FILES = Dir[SKILL_DIR.join("**/*.md")].sort.freeze
  SKILL_TEXT = SKILL_FILES.map { |file| File.read(file) }.join("\n").freeze

  HELPER_SOURCE = Dir[ROOT.join("registry/rails/ui/helpers/ui/*.rb")]
                    .map { |file| File.read(file) }.join("\n").freeze
  DEFINED_HELPERS = HELPER_SOURCE.scan(/def (ui_\w+)/).flatten.to_set.freeze

  ITEM_NAMES = REGISTRY.fetch("items").map { |item| item.fetch("name") }.to_set.freeze

  CLI_COMMANDS = %w[init add list search info diff update remove status version help].freeze

  # `init` is excluded by definition: it is the command that creates the binstub,
  # so it is the one thing you necessarily run before the binstub exists. Same
  # for `version` and `help`, which are not app-scoped at all.
  CANONICAL_COMMANDS = (CLI_COMMANDS - %w[init version help]).freeze

  # Two places legitimately name a non-canonical form: the bootstrap prose that
  # tells the agent how to create a missing binstub, and the injection block,
  # which must name all three forms by construction. Both are delimited with
  # explicit markers rather than matched by heuristic, so a stray bare example
  # can never smuggle itself past the check by resembling one of them.
  EXEMPT_START = "<!-- canonical-exempt:start -->"
  EXEMPT_END = "<!-- canonical-exempt:end -->"

  # Tokens that look like helper calls but are not, and must stay out of the
  # helper check: file names, the bare glob used in prose, and one name cited
  # precisely because it does not exist.
  NON_HELPER_TOKENS = %w[ui_ ui_component ui_helper ui_card_body].freeze

  def test_the_skill_exists
    refute_empty SKILL_FILES
    assert_path_exists SKILL_DIR.join("SKILL.md")
  end

  def test_skill_frontmatter_declares_a_name_and_description
    body = SKILL_DIR.join("SKILL.md").read

    assert_match(/\A---\n/, body, "SKILL.md must open with YAML frontmatter")
    frontmatter = body[/\A---\n(.*?)\n---\n/m, 1].to_s
    assert_match(/^name: shadwire$/, frontmatter)
    assert_match(/^description: \S/, frontmatter)
  end

  # The whole point of the injected block: without it the skill would have to
  # hardcode what is installed. It chains the three invocation forms by exit
  # code, because it is a static string that must return data in any app —
  # including apps initialized before bin/shadwire existed.
  def test_skill_injects_live_project_context
    body = SKILL_DIR.join("SKILL.md").read

    assert_includes body, "bin/shadwire status --json"
    assert_includes body, "bundle exec shadwire status --json"
    assert_includes body, "shadwire status --json"
    assert_includes body, %("cliMissing":true), "the injection must always emit parseable JSON"
  end

  def test_every_helper_mentioned_in_the_skill_exists
    mentioned = SKILL_TEXT.scan(/\bui_[a-z0-9_]+/).uniq - NON_HELPER_TOKENS
    missing = mentioned.reject { |helper| DEFINED_HELPERS.include?(helper) }

    assert_empty missing, "skill references helpers that no helper module defines: #{missing.inspect}"
  end

  # Guards the exclusion list itself: if one of these ever becomes a real helper,
  # the entry is stale and must be dropped.
  def test_excluded_tokens_are_still_not_helpers
    wrongly_excluded = NON_HELPER_TOKENS.select { |token| DEFINED_HELPERS.include?(token) }

    assert_empty wrongly_excluded,
                 "NON_HELPER_TOKENS lists names that are now real helpers: #{wrongly_excluded.inspect}"
  end

  def test_every_component_mentioned_in_the_skill_exists
    cited = SKILL_TEXT.scan(/shadwire (?:add|info|remove) ([a-z0-9-]+)/).flatten.uniq
                      .reject { |name| name.start_with?("-") || name == "NAME" }
    missing = cited.reject { |name| ITEM_NAMES.include?(name) }

    assert_empty missing, "skill references components that are not in the registry: #{missing.inspect}"
  end

  def test_the_component_selection_table_only_names_real_components
    table = SKILL_DIR.join("SKILL.md").read[/## Component Selection\n(.*?)\n## /m, 1].to_s
    refute_empty table, "SKILL.md has no Component Selection table"

    cited = table.scan(/`([a-z0-9-]+)`/).flatten.uniq
    missing = cited.reject { |name| ITEM_NAMES.include?(name) }

    assert_empty missing, "selection table names components that do not exist: #{missing.inspect}"
  end

  def test_every_cli_command_mentioned_exists
    cited = SKILL_TEXT.scan(/`?shadwire ([a-z][a-z-]*)/).flatten.uniq
    unknown = cited.reject { |command| CLI_COMMANDS.include?(command) }

    refute_empty cited, "the command scan matched nothing — the regex no longer sees the examples"
    assert_empty unknown, "skill references unknown CLI commands: #{unknown.inspect}"
  end

  # A usage snippet that calls a helper nothing defines would teach an agent a
  # method that raises at request time.
  def test_registry_usage_snippets_only_call_helpers_that_exist
    REGISTRY.fetch("items").each do |item|
      Array(item["usage"]).each do |snippet|
        snippet.scan(/\bui_[a-z0-9_]+\b(?!:)/).uniq.each do |helper|
          assert_includes DEFINED_HELPERS, helper,
                          "#{item.fetch("name")} usage calls #{helper}, which no helper module defines"
        end
      end
    end
  end

  def test_every_command_example_is_canonical
    checked = 0

    offenders = SKILL_FILES.flat_map do |file|
      exempt = false

      File.readlines(file).each_with_index.filter_map do |line, index|
        exempt = true if line.include?(EXEMPT_START)
        skip_line = exempt
        exempt = false if line.include?(EXEMPT_END)
        next if skip_line

        checked += 1
        next unless line.match?(/(?<!bin\/)\bshadwire (#{CANONICAL_COMMANDS.join("|")})\b/)

        "#{File.basename(file)}:#{index + 1}: #{line.strip}"
      end
    end

    assert_empty offenders, "command examples must be written as `bin/shadwire`:\n#{offenders.join("\n")}"
    assert_operator checked, :>, 100, "almost everything was exempted — the markers are too broad"
  end

  def test_exempt_markers_are_balanced
    SKILL_FILES.each do |file|
      body = File.read(file)

      assert_equal body.scan(EXEMPT_START).size, body.scan(EXEMPT_END).size,
                   "#{File.basename(file)} has an unclosed canonical-exempt region"
    end
  end

  # The check that would have caught the original bug report: a form the skill
  # tells the agent to run, with no matching allowed-tools pattern, prompts on
  # every call.
  def test_allowed_tools_covers_every_form_the_skill_runs
    frontmatter = SKILL_DIR.join("SKILL.md").read[/\A---\n(.*?)\n---\n/m, 1].to_s
    granted = frontmatter[/^allowed-tools:(.*)$/, 1].to_s

    ["bin/shadwire", "./bin/shadwire", "bundle exec shadwire", "shadwire"].each do |form|
      assert_includes granted, "Bash(#{form} *)",
                      "allowed-tools must grant `#{form}` or every call prompts"
    end
  end

  def test_referenced_skill_files_exist
    SKILL_FILES.each do |file|
      File.read(file).scan(/\]\((\.[^)]+\.md)\)/).flatten.uniq.each do |link|
        target = Pathname.new(File.dirname(file)).join(link).cleanpath

        assert_path_exists target, "#{file} links to a missing file: #{link}"
      end
    end
  end

  # The end-to-end proof: the workflow the skill documents actually works, and
  # installing one component installs only that component's helper.
  #
  # Hermetic by design. The app's Gemfile already declares the base gems, so
  # `init` finds them present and never shells out to `bundle add` — no network,
  # and no dependency on the runner's gem environment.
  def test_documented_workflow_runs_end_to_end
    build_dir = Dir.mktmpdir("shadwire-skill-build")

    Dir.mktmpdir("shadwire-skill-app") do |app|
      FileUtils.mkdir_p(File.join(app, "config"))
      FileUtils.mkdir_p(File.join(app, "app/assets/tailwind"))
      File.write(File.join(app, "config/application.rb"), "# rails\n")
      File.write(File.join(app, "Gemfile"), <<~GEMFILE)
        source "https://rubygems.org"
        gem "rails"
        gem "view_component"
        gem "lucide-rails"
        gem "shadwire"
      GEMFILE
      File.write(File.join(app, "app/assets/tailwind/application.css"), %(@import "tailwindcss";\n))

      assert system({ "BUILD_DIR" => build_dir }, ROOT.join("bin/build_registry").to_s, out: File::NULL),
             "bin/build_registry failed"

      registry = "file://#{build_dir}/r"
      # Run through the CLI's own bundle so thor resolves the same way it does
      # for the gem's suite, rather than relying on the ambient gem path.
      env = { "BUNDLE_GEMFILE" => ROOT.join("packages/cli/Gemfile").to_s }
      shadwire = lambda do |*args|
        command = [
          "bundle", "exec", "ruby", "-I#{ROOT.join("packages/cli/lib")}",
          ROOT.join("packages/cli/exe/shadwire").to_s,
          *args.map(&:to_s), "--cwd", app, "--registry", registry
        ]
        output = IO.popen(env, command, err: [:child, :out], &:read)
        [output, $?.success?]
      end

      out, ok = shadwire.call("init", "--yes")
      assert ok, "init failed:\n#{out}"

      out, ok = shadwire.call("add", "button", "--yes")
      assert ok, "add failed:\n#{out}"

      raw, ok = shadwire.call("status", "--json")
      assert ok, "status failed:\n#{raw}"
      status = JSON.parse(raw.lines.last)

      assert_equal true, status.fetch("rails")
      assert_includes status.fetch("installed").flat_map { |item| item["helpers"] }, "ui_button"
      assert_equal "unchanged", status.fetch("installed").first.fetch("drift")

      out, ok = shadwire.call("diff")
      assert ok, "diff failed: #{out}"
      refute_match(/^(modified|missing)/, out, "a fresh install should not have drifted")

      # The canonical entry point the skill documents.
      binstub = File.join(app, "bin/shadwire")
      assert_path_exists binstub
      assert_equal 0o755, File.stat(binstub).mode & 0o777

      # The point of the per-item helper split: only what you installed.
      assert_path_exists File.join(app, "app/helpers/ui/button_helper.rb")
      refute_path_exists File.join(app, "app/helpers/ui_helper.rb"),
                         "the monolithic helper must no longer be installed"
      assert_equal ["button_helper.rb"], Dir.children(File.join(app, "app/helpers/ui")).sort
    end
  ensure
    FileUtils.remove_entry(build_dir, true) if build_dir
  end
end
