# Shadwire Agent Skill & Helper Modularization — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `shadwire` agent skill installable via skills.sh into any consuming Rails app, backed by a registry that carries per-component API data and a helper layer that installs only what you use.

**Architecture:** `registry/` stays the source of truth. `bin/build_registry` gains a Prism-based extractor that derives each component's API from its Ruby source, so the published registry can never drift from the code it ships. The CLI gains `status --json` (project context) and richer `info --json` (component API). The skill at `skills/shadwire/` carries only procedure and pulls all data from those two commands at runtime. The 919-line monolithic `ui_helper.rb` splits into one `Ui::*Helper` module per item, which Rails auto-includes from `app/helpers/ui/`.

**Tech Stack:** Ruby 3.4.8, Prism (stdlib), Thor 1.5, Minitest, Rails 8.1 / ViewComponent 4 (sandbox), GitHub Actions, GitHub Pages.

Design spec: `docs/superpowers/specs/2026-07-27-shadwire-agent-skill-design.md`

## Global Constraints

- `registry/` is the source of truth. Never edit `sandbox/app/components/`, `sandbox/app/helpers/`, or `sandbox/vendor/shadwire/` by hand — edit `registry/` and run `bin/sync_registry`.
- `build/` is generated and gitignored. Never hand-edit; fix `registry/` and rebuild.
- Installed component files must work with **no** runtime dependency on Shadwire.
- Consuming-app support floor: `ruby >= 3.2`, `rails >= 7.1`, `view_component >= 4.0`, `lucide-rails >= 0.7`. Registry component code must stay compatible.
- Prism is stdlib only from Ruby **3.3**. It may be used in `bin/build_registry` (repo tooling, Ruby 3.4.8) but **never** inside the shipped `shadwire` gem, whose gemspec declares `required_ruby_version >= 3.2`.
- Components live in the `Ui` namespace, subclass `UiComponent`, flat at root with nested subcomponents (`ui/card/header_component.rb` → `Ui::Card::HeaderComponent`).
- Use shadcn semantic Tailwind tokens (`bg-primary`, `text-muted-foreground`, `border-input`). No hardcoded colors.
- Commits follow Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).
- Run the CLI suite with `PARALLEL_WORKERS=1`; the sandbox parallel runner deadlocks otherwise.
- Every phase lands as its own small PR and must leave CI fully green.

## File Structure

**New — repo tooling**
- `lib/shadwire_registry/api_extractor.rb` — Prism AST → component API hash. Pure; no I/O.
- `lib/shadwire_registry/llms_writer.rb` — built item hashes → `llms.txt` / `llms-full.txt` strings. Pure.
- `test/api_extractor_test.rb`, `test/llms_writer_test.rb`, `test/skill_check_test.rb`

**New — registry source**
- `registry/rails/ui/helpers/ui/<item>_helper.rb` × 55 — one `Ui::<Item>Helper` module per item.
- Deleted: `registry/rails/ui/helpers/ui_helper.rb`

**New — CLI**
- `packages/cli/lib/shadwire/commands/status.rb` — `Shadwire::Commands::Status`
- `packages/cli/test/status_test.rb`

**New — skill**
- `skills/shadwire/SKILL.md`, `cli.md`, `theming.md`, `rules/{composition,styling,forms,icons}.md`

**Modified**
- `registry/registry.json` — helper file entries; required `title`/`description`/`whenToUse`/`usage`.
- `bin/build_registry` — base files, API extraction, prose validation, llms output.
- `packages/cli/lib/shadwire/cli.rb` — register `status`.
- `packages/cli/lib/shadwire/commands/info.rb` — pass through new fields.
- `test/registry_schema_test.rb` — require the new prose fields.
- `.github/workflows/ci.yml` — `skill_check` job; gem release workflow.

## Ownership rule (used by Phases 1 and 8)

An item `X` owns a component file when, with `x = X.name.tr("-", "_")` and prefix
`p = "blocks/#{x}"` for `type: "block"` else `x`:

- `path == "#{p}_component.rb"`, or
- `path.start_with?("#{p}/")`, or
- `path.start_with?("#{p}_")`

When several items match, **the longest prefix wins**. Verified: this maps
229/229 helpers, resolving `input_group_component.rb` → `input-group` (not
`input`) and `resizable_panel_component.rb` → `resizable`. `combobox` and
`date-picker` own no component files — they are pure composition items and get no
helper file.

---

# Phase 1 (PR 1): Helper modularization

Splits the monolith so installing a component brings only its own helpers.

### Task 1.1: Generate the per-item helper modules

**Files:**
- Create: `registry/rails/ui/helpers/ui/<item>_helper.rb` × 55
- Delete: `registry/rails/ui/helpers/ui_helper.rb`
- Modify: `registry/registry.json`

**Interfaces:**
- Produces: modules named `Ui::<ItemCamel>Helper` at `app/helpers/ui/<item_snake>_helper.rb`, where `ItemCamel` is the item name kebab→camel (`dropdown-menu` → `DropdownMenu`, `sidebar-01` → `Sidebar01`).

- [ ] **Step 1: Write the migration script**

Save to the scratchpad (it is one-shot tooling, not a repo deliverable):

```ruby
# /tmp/split_helpers.rb
require "json"
require "fileutils"

ROOT = File.expand_path("../..", __dir__) # adjust to repo root when running
reg = JSON.parse(File.read("registry/registry.json"))
items = reg["items"]
src = File.read("registry/rails/ui/helpers/ui_helper.rb")

# Each helper's full source body, in file order.
defs = src.scan(/^  def (ui_\w+)\(.*?^  end$/m)
bodies = src.scan(/^  def ui_\w+\(.*?^  end$/m)
raise "def/body mismatch" unless defs.size == bodies.size

def class_to_path(k)
  k.sub(/\AUi::/, "").gsub("::", "/").gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase + ".rb"
end

prefixes = items.to_h { |it|
  s = it["name"].tr("-", "_")
  [it["name"], it["type"] == "block" ? "blocks/#{s}" : s]
}

def owner_for(path, items, prefixes)
  items.select { |it|
    p = prefixes[it["name"]]
    path == "#{p}_component.rb" || path.start_with?("#{p}/") || path.start_with?("#{p}_")
  }.max_by { |it| prefixes[it["name"]].length }
end

grouped = Hash.new { |h, k| h[k] = [] }
bodies.each do |body|
  klass = body[/Ui::[A-Za-z:]*Component/]
  raise "no class in: #{body[0, 60]}" unless klass
  owner = owner_for(class_to_path(klass), items, prefixes)
  raise "no owner for #{klass}" unless owner
  grouped[owner["name"]] << body
end

FileUtils.mkdir_p("registry/rails/ui/helpers/ui")
grouped.each do |name, methods|
  mod = name.split("-").map { |s| s[0].upcase + s[1..] }.join
  path = "registry/rails/ui/helpers/ui/#{name.tr("-", "_")}_helper.rb"
  File.write(path, <<~RB)
    # frozen_string_literal: true

    module Ui
      module #{mod}Helper
    #{methods.join("\n\n").gsub(/^/, "  ")}
      end
    end
  RB
end
puts "wrote #{grouped.size} helper files"
```

- [ ] **Step 2: Run it and verify the split is lossless**

```bash
ruby /tmp/split_helpers.rb
# every ui_* method must survive the split
diff <(grep -ho "def ui_\w*" registry/rails/ui/helpers/ui_helper.rb | sort) \
     <(grep -rho "def ui_\w*" registry/rails/ui/helpers/ui/ | sort)
```
Expected: `55 helper files written`, and the `diff` prints nothing.

- [ ] **Step 3: Verify every generated file parses and defines the expected module**

```bash
for f in registry/rails/ui/helpers/ui/*.rb; do ruby -c "$f" >/dev/null || echo "SYNTAX FAIL $f"; done
ruby -e '
Dir["registry/rails/ui/helpers/ui/*.rb"].each do |f|
  base = File.basename(f, "_helper.rb")
  mod  = base.split("_").map { |s| s[0].upcase + s[1..] }.join
  src  = File.read(f)
  puts "MODULE MISMATCH #{f}" unless src.include?("module #{mod}Helper")
end
puts "module names ok"'
```
Expected: no `SYNTAX FAIL`, no `MODULE MISMATCH`, prints `module names ok`.

- [ ] **Step 4: Delete the monolith**

```bash
rm registry/rails/ui/helpers/ui_helper.rb
```

- [ ] **Step 5: Rewrite `files[]` in `registry/registry.json`**

For every item, remove the `ui_helper.rb` entry and add the helper files matching
the component files that item ships (an item that bundles another item's
component must also bundle that item's helper). Script it:

```ruby
# /tmp/relink_helpers.rb  — run from repo root
require "json"
path = "registry/registry.json"
reg = JSON.parse(File.read(path))
items = reg["items"]
prefixes = items.to_h { |it|
  s = it["name"].tr("-", "_")
  [it["name"], it["type"] == "block" ? "blocks/#{s}" : s]
}
def owner_for(path, items, prefixes)
  items.select { |it|
    p = prefixes[it["name"]]
    path == "#{p}_component.rb" || path.start_with?("#{p}/") || path.start_with?("#{p}_")
  }.max_by { |it| prefixes[it["name"]].length }
end

items.each do |item|
  files = item["files"].reject { |f| f["target"] == "app/helpers/ui_helper.rb" }
  owners = files.filter_map { |f|
    t = f["target"]
    next unless t.start_with?("app/components/ui/")
    next if t == "app/components/ui_component.rb"
    o = owner_for(t.sub("app/components/ui/", ""), items, prefixes)
    o && o["name"]
  }.uniq
  helper_files = owners.filter_map { |name|
    src = "registry/rails/ui/helpers/ui/#{name.tr("-", "_")}_helper.rb"
    next unless File.exist?(src)
    { "source" => src, "target" => "app/helpers/ui/#{name.tr("-", "_")}_helper.rb" }
  }
  # keep ui_component.rb first, then components, then helpers, then css
  css = files.select { |f| f["target"].start_with?("vendor/") }
  rest = files - css
  item["files"] = rest + helper_files + css
end
File.write(path, JSON.pretty_generate(reg) + "\n")
puts "relinked helper files"
```

```bash
ruby /tmp/relink_helpers.rb
ruby -e 'require "json"; JSON.parse(File.read("registry/registry.json")); puts "json ok"'
```
Expected: `relinked helper files`, `json ok`.

- [ ] **Step 6: Drop the monolith from the shared base**

Modify `bin/build_registry:22-26` — remove the `ui_helper.rb` entry so `BASE_FILES` is:

```ruby
BASE_FILES = [
  { "source" => "registry/rails/ui/components/ui_component.rb", "target" => "app/components/ui_component.rb" },
  { "source" => "registry/rails/ui/styles/shadwire.css", "target" => "vendor/shadwire/shadwire.css" }
].freeze
```

- [ ] **Step 7: Run the registry tests**

```bash
ruby test/registry_manifest_test.rb && ruby test/registry_schema_test.rb && ruby test/registry_build_test.rb
```
Expected: all pass. If `registry_build_test.rb` asserts `ui_helper.rb` is in `base`, update that assertion to the new two-file base.

- [ ] **Step 8: Sync the sandbox and remove the stale monolith**

```bash
bin/sync_registry
rm -f sandbox/app/helpers/ui_helper.rb
grep -rn "UiHelper\b" sandbox/test sandbox/app --include=*.rb | grep -v "app/helpers/ui/" || echo "no stale references"
```
Expected: sync succeeds; no stale `UiHelper` references remain.

- [ ] **Step 9: Run the sandbox component + a11y suite**

```bash
cd sandbox && PARALLEL_WORKERS=1 bin/rails test test/components test/integration/ui_accessibility_test.rb
```
Expected: all pass — this is the real proof Rails auto-includes the nested `Ui::*Helper` modules.

- [ ] **Step 10: Lint**

```bash
cd sandbox && bin/rubocop
```
Expected: clean.

- [ ] **Step 11: Commit**

```bash
git add registry/ bin/build_registry sandbox/ test/
git commit -m "refactor(registry): split ui_helper into one module per item

Installing a component wrote a 919-line helper defining 229 ui_* methods;
with one component installed, 228 raised NameError at request time. Each
item now ships app/helpers/ui/<item>_helper.rb defining Ui::<Item>Helper,
which Rails auto-includes from app/helpers/**. Calling an uninstalled
component's helper is now a plain NoMethodError naming the helper."
```

### Task 1.2: Guard the split with a schema test

**Files:**
- Modify: `test/registry_schema_test.rb`

- [ ] **Step 1: Write the failing test**

```ruby
def test_component_items_ship_helper_files_for_the_components_they_bundle
  REGISTRY.fetch("items").each do |item|
    component_targets = item.fetch("files").map { |f| f["target"] }
      .select { |t| t.start_with?("app/components/ui/") }
    next if component_targets.empty?

    helper_targets = item.fetch("files").map { |f| f["target"] }
      .select { |t| t.start_with?("app/helpers/ui/") }

    component_targets.each do |target|
      owner = owner_for(target.sub("app/components/ui/", ""))
      next unless owner
      expected = "app/helpers/ui/#{owner.tr("-", "_")}_helper.rb"
      next unless File.exist?(ROOT.join("registry/rails/ui/helpers/ui/#{owner.tr("-", "_")}_helper.rb"))
      assert_includes helper_targets, expected,
        "#{item["name"]} ships #{target} but not #{expected}"
    end
  end
end

def test_no_item_ships_the_legacy_monolithic_helper
  REGISTRY.fetch("items").each do |item|
    refute_includes item.fetch("files").map { |f| f["target"] }, "app/helpers/ui_helper.rb",
      "#{item["name"]} still ships the removed monolithic helper"
  end
end
```

Add the shared ownership helper to the test class:

```ruby
PREFIXES = REGISTRY.fetch("items").to_h { |it|
  s = it.fetch("name").tr("-", "_")
  [it.fetch("name"), it.fetch("type") == "block" ? "blocks/#{s}" : s]
}.freeze

def owner_for(path)
  REGISTRY.fetch("items").select { |it|
    p = PREFIXES[it.fetch("name")]
    path == "#{p}_component.rb" || path.start_with?("#{p}/") || path.start_with?("#{p}_")
  }.max_by { |it| PREFIXES[it.fetch("name")].length }&.fetch("name")
end
```

- [ ] **Step 2: Run it**

```bash
ruby test/registry_schema_test.rb
```
Expected: PASS (Task 1.1 already satisfies it; this locks the invariant in).

- [ ] **Step 3: Verify it actually catches a regression**

Temporarily delete a helper entry from one item in `registry/registry.json`, re-run, confirm FAIL, then restore.

- [ ] **Step 4: Commit**

```bash
git add test/registry_schema_test.rb
git commit -m "test(registry): assert items ship helpers for bundled components"
```

- [ ] **Step 5: Open the PR**

```bash
git push -u origin refactor/helper-modularization
gh pr create --title "refactor(registry): split ui_helper into one module per item" \
  --body "Installing any component wrote a 919-line helper with 229 ui_* methods, 228 of which raised NameError. Each item now ships its own Ui::<Item>Helper under app/helpers/ui/, auto-included by Rails.

Verified: Rails 8.1 all_helpers_from_path globs app/helpers/**/*_helper.rb and modules_for_helpers camelizes ui/button -> Ui::ButtonHelper. Sandbox component + a11y suites pass, which exercises the real autoload path.

Part of docs/superpowers/specs/2026-07-27-shadwire-agent-skill-design.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

---

# Phase 2 (PR 2): Registry prose metadata

Makes discovery work. 53 of 58 items currently publish `description == title == humanize(name)`.

### Task 2.1: Require the prose fields at build time

**Files:**
- Modify: `bin/build_registry:88-102`
- Modify: `test/registry_schema_test.rb`

- [ ] **Step 1: Write the failing schema test**

```ruby
REQUIRED_PROSE = %w[title description whenToUse].freeze

def test_every_item_has_hand_written_prose
  REGISTRY.fetch("items").each do |item|
    REQUIRED_PROSE.each do |key|
      value = item[key]
      refute_nil value, "#{item.fetch("name")} is missing #{key}"
      refute value.to_s.strip.empty?, "#{item.fetch("name")} has an empty #{key}"
    end
  end
end

def test_descriptions_are_not_just_the_humanized_name
  REGISTRY.fetch("items").each do |item|
    humanized = item.fetch("name").split("-").map(&:capitalize).join(" ")
    refute_equal humanized, item.fetch("description"),
      "#{item.fetch("name")} description is a placeholder"
  end
end

def test_usage_snippets_are_present_for_components
  REGISTRY.fetch("items").select { |i| i.fetch("type") == "component" }.each do |item|
    snippets = Array(item["usage"])
    refute_empty snippets, "#{item.fetch("name")} has no usage snippet"
    snippets.each { |s| assert_match(/<%=/, s, "#{item.fetch("name")} usage is not ERB") }
  end
end
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
ruby test/registry_schema_test.rb
```
Expected: FAIL — 53 items missing `title`/`description`/`whenToUse`, 57 missing `usage`.

- [ ] **Step 3: Fill in the prose for all 58 items**

Edit `registry/registry.json`. For each item write:
- `title` — Title Case display name.
- `description` — one sentence, what it renders.
- `whenToUse` — one or two sentences that **disambiguate from neighbours**. This is what makes `shadwire search` useful. Example for `dropdown-menu`: `"Row actions, overflow menus, account menus. For navigation between pages use navigation-menu; for right-click use context-menu."`
- `usage` — one or two ERB snippets using the item's real helper names. Read `registry/rails/ui/helpers/ui/<item>_helper.rb` and the component's `initialize` to get names and kwargs right; do not invent props.

Mirror upstream shadcn wording where it applies, but describe what **this** implementation actually does.

- [ ] **Step 4: Run the schema test**

```bash
ruby test/registry_schema_test.rb
```
Expected: PASS.

- [ ] **Step 5: Make the build hard-fail on missing prose**

Replace the `humanize` fallbacks in `bin/build_registry`. Delete the `humanize`
method and its two call sites, and add validation before the item loop:

```ruby
REQUIRED_PROSE = %w[title description whenToUse].freeze

items.each do |item|
  missing = REQUIRED_PROSE.reject { |key| item[key].to_s.strip != "" }
  raise "Item #{item.fetch("name")} is missing required prose: #{missing.join(", ")}" unless missing.empty?
end
```

Then in the published payload and index, use `item.fetch("title")`,
`item.fetch("description")`, and add `"whenToUse" => item.fetch("whenToUse")` and
`"usage" => Array(item["usage"])`. Add `whenToUse` to the index entries too, so
`list`/`search` can use it without fetching every item.

- [ ] **Step 6: Build and confirm the fallback is gone**

```bash
ruby bin/build_registry
ruby -e 'require "json"
d = JSON.parse(File.read("build/r/dropdown-menu.json"))
raise "still placeholder" if d["description"] == "Dropdown Menu"
puts d["description"]; puts d["whenToUse"]'
```
Expected: real prose, not `Dropdown Menu`.

- [ ] **Step 7: Confirm search now works**

```bash
cd packages/cli && ruby -Ilib exe/shadwire search form --cwd /tmp --registry "file://$PWD/../../build/r"
```
Expected: matches include `input`, `label`, `checkbox`, `field`, `select` — where today it prints `No matches for "form".`

- [ ] **Step 8: Run the full registry suite**

```bash
cd /home/edu/Work/shadwire && ruby test/registry_manifest_test.rb && ruby test/registry_schema_test.rb && ruby test/registry_build_test.rb
```
Expected: all pass.

- [ ] **Step 9: Commit and open the PR**

```bash
git add registry/registry.json bin/build_registry test/registry_schema_test.rb
git commit -m "feat(registry): require title, description, whenToUse and usage

53 of 58 items published description == title == humanize(name), so
'shadwire search form' matched nothing despite ten form components. The
build now hard-fails on missing prose instead of silently humanizing."
git push -u origin feat/registry-prose-metadata
gh pr create --title "feat(registry): require per-item prose metadata" --body "..."
```

---

# Phase 3 (PR 3): Prism API extraction

### Task 3.1: Build the extractor

**Files:**
- Create: `lib/shadwire_registry/api_extractor.rb`
- Create: `test/api_extractor_test.rb`

**Interfaces:**
- Produces: `ShadwireRegistry::ApiExtractor.call(source:, path:) -> Hash` with keys `"class"`, `"variants"`, `"sizes"`, `"props"`, `"attrs"`. Callers add `"helper"` and `"root"`.

- [ ] **Step 1: Write the failing test**

```ruby
# test/api_extractor_test.rb
require "minitest/autorun"
require "pathname"
require_relative "../lib/shadwire_registry/api_extractor"

class ApiExtractorTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path

  def extract(rel)
    ShadwireRegistry::ApiExtractor.call(source: ROOT.join(rel).read, path: rel)
  end

  def test_extracts_class_name
    assert_equal "Ui::ButtonComponent",
      extract("registry/rails/ui/components/button_component.rb")["class"]
  end

  def test_extracts_nested_class_name
    assert_equal "Ui::Card::HeaderComponent",
      extract("registry/rails/ui/components/card/header_component.rb")["class"]
  end

  def test_extracts_variant_and_size_keys
    api = extract("registry/rails/ui/components/button_component.rb")
    assert_equal %w[default destructive outline secondary ghost link], api["variants"]
    assert_equal %w[default sm lg icon], api["sizes"]
  end

  def test_extracts_props_with_defaults
    props = extract("registry/rails/ui/components/button_component.rb")["props"]
    assert_equal({ "name" => "tag", "default" => ":button" }, props.find { |p| p["name"] == "tag" })
    assert_equal({ "name" => "disabled", "default" => "false" }, props.find { |p| p["name"] == "disabled" })
  end

  def test_reports_keyword_rest
    assert_equal true, extract("registry/rails/ui/components/button_component.rb")["attrs"]
  end

  def test_every_component_in_the_registry_extracts_without_error
    files = Dir[ROOT.join("registry/rails/ui/components/**/*.rb")]
    refute_empty files
    files.each do |f|
      api = ShadwireRegistry::ApiExtractor.call(source: File.read(f), path: f)
      refute_nil api["class"], "no class extracted from #{f}"
    end
  end
end
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
ruby test/api_extractor_test.rb
```
Expected: FAIL — `cannot load such file -- ../lib/shadwire_registry/api_extractor`.

- [ ] **Step 3: Implement the extractor**

```ruby
# lib/shadwire_registry/api_extractor.rb
# frozen_string_literal: true

require "prism"

module ShadwireRegistry
  # Derives a component's public API from its Ruby source so the published
  # registry can never drift from the code it ships. Pure: takes source text,
  # returns a Hash. Requires Prism (Ruby >= 3.3) and therefore runs only in repo
  # tooling, never in the shipped gem (gemspec floor is 3.2).
  module ApiExtractor
    VARIANT_KEYS = { "VARIANTS" => "variants", "SIZES" => "sizes" }.freeze

    class << self
      def call(source:, path: nil)
        result = Prism.parse(source)
        raise ArgumentError, "unparsable component: #{path}" if result.failure?

        root = result.value
        definition = descendants(root, Prism::ClassNode).last

        api = { "class" => class_name(root), "variants" => [], "sizes" => [], "props" => [], "attrs" => false }
        constant_hashes(definition || root).each { |name, keys| api[name] = keys }
        merge_initialize(api, definition || root)
        api
      end

      private

      # Joins enclosing module/class names: module Ui; class ButtonComponent -> "Ui::ButtonComponent"
      def class_name(root)
        parts = []
        walk = lambda do |node|
          case node
          when Prism::ModuleNode, Prism::ClassNode then parts << node.constant_path.slice
          end
          node.compact_child_nodes.each { |c| walk.call(c) }
        end
        walk.call(root)
        parts.empty? ? nil : parts.join("::")
      end

      def constant_hashes(scope)
        descendants(scope, Prism::ConstantWriteNode).filter_map do |node|
          key = VARIANT_KEYS[node.name.to_s]
          next unless key

          value = node.value
          value = value.receiver if value.is_a?(Prism::CallNode) && value.name == :freeze
          next unless value.is_a?(Prism::HashNode)

          [key, value.elements.filter_map { |e| e.key.respond_to?(:unescaped) ? e.key.unescaped : nil }]
        end
      end

      def merge_initialize(api, scope)
        definition = descendants(scope, Prism::DefNode).find { |d| d.name == :initialize }
        return api unless definition

        parameters = definition.parameters
        return api unless parameters

        api["props"] = parameters.keywords.map do |keyword|
          default = keyword.respond_to?(:value) && keyword.value ? keyword.value.slice : nil
          { "name" => keyword.name.to_s.delete_suffix(":"), "default" => default }
        end
        api["attrs"] = !parameters.keyword_rest.nil?
        api
      end

      def descendants(node, type, acc = [])
        acc << node if node.is_a?(type)
        node.compact_child_nodes.each { |child| descendants(child, type, acc) }
        acc
      end
    end
  end
end
```

- [ ] **Step 4: Run the tests**

```bash
ruby test/api_extractor_test.rb
```
Expected: PASS, all 6 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/shadwire_registry/api_extractor.rb test/api_extractor_test.rb
git commit -m "feat(registry): extract component API from source via Prism"
```

### Task 3.2: Emit the API into the published registry

**Files:**
- Modify: `bin/build_registry`
- Modify: `test/registry_build_test.rb`

- [ ] **Step 1: Write the failing build test**

```ruby
def test_item_carries_generated_api
  api = item_json("button").fetch("api")
  button = api.fetch("components").find { |c| c["class"] == "Ui::ButtonComponent" }
  refute_nil button
  assert_equal "ui_button", button.fetch("helper")
  assert_equal true, button.fetch("root")
  assert_includes button.fetch("variants"), "destructive"
  assert_includes button.fetch("sizes"), "icon"
end

def test_item_marks_stimulus_requirement
  assert_equal true, item_json("dropdown-menu").fetch("requiresStimulus")
  assert_equal false, item_json("button").fetch("requiresStimulus")
end

def test_subcomponents_are_not_marked_root
  card = item_json("card").fetch("api").fetch("components")
  header = card.find { |c| c["class"] == "Ui::Card::HeaderComponent" }
  refute_nil header
  assert_equal false, header.fetch("root")
  assert_equal "ui_card_header", header.fetch("helper")
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
ruby test/registry_build_test.rb
```
Expected: FAIL — `key not found: "api"`.

- [ ] **Step 3: Wire the extractor into the build**

In `bin/build_registry`, add near the top:

```ruby
require_relative "../lib/shadwire_registry/api_extractor"
```

Add helper-name resolution and the API assembly:

```ruby
# helper method name for a component class, read from the item's helper modules
def helper_index(root)
  index = {}
  Dir[root.join("registry/rails/ui/helpers/ui/*.rb")].each do |file|
    source = File.read(file)
    source.scan(/def (ui_\w+)\(.*?\n(.*?)\n  end/m).each do |name, body|
      klass = body[/Ui::[A-Za-z:]*Component/]
      index[klass] = name if klass
    end
  end
  index
end

HELPERS = helper_index(ROOT)

def build_api(item, root)
  component_files = item.fetch("files").select { |f| f["target"].start_with?("app/components/ui/") }
  components = component_files.map do |file|
    api = ShadwireRegistry::ApiExtractor.call(
      source: root.join(file.fetch("source")).read, path: file.fetch("source")
    )
    api.merge(
      "helper" => HELPERS[api["class"]],
      "root" => file["target"].end_with?("/#{item.fetch("name").tr("-", "_")}_component.rb")
    )
  end
  { "components" => components }
end
```

Add to the published payload:

```ruby
"whenToUse" => item.fetch("whenToUse"),
"usage" => Array(item["usage"]),
"requiresStimulus" => item.fetch("files").any? { |f| f["target"].start_with?("app/javascript/") },
"api" => build_api(item, ROOT),
```

- [ ] **Step 4: Run the tests**

```bash
ruby bin/build_registry && ruby test/registry_build_test.rb
```
Expected: PASS.

- [ ] **Step 5: Spot-check the output**

```bash
ruby -e 'require "json"; d = JSON.parse(File.read("build/r/card.json"))
d["api"]["components"].each { |c| puts "#{c["root"] ? "root" : "sub "} #{c["class"]} -> #{c["helper"]}" }'
```
Expected: `Ui::CardComponent` marked root with `ui_card`; the `Ui::Card::*` subcomponents marked sub.

- [ ] **Step 6: Commit and open the PR**

```bash
git add bin/build_registry test/registry_build_test.rb
git commit -m "feat(registry): publish generated component API and stimulus flag"
git push -u origin feat/registry-api-extraction
gh pr create --title "feat(registry): generate component API from source" --body "..."
```

---

# Phase 4 (PR 4): `shadwire status --json`

### Task 4.1: The status command

**Files:**
- Create: `packages/cli/lib/shadwire/commands/status.rb`
- Create: `packages/cli/test/status_test.rb`
- Modify: `packages/cli/lib/shadwire.rb`, `packages/cli/lib/shadwire/cli.rb`
- Modify: `packages/cli/lib/shadwire/project.rb`

**Interfaces:**
- Consumes: `Config.load`, `RegistryClient#index`, `RegistryClient#item`, `Project`, `Differ`.
- Produces: `Commands::Status.new(root:, registry:, json:, ui:).call -> Hash` with string keys matching the spec's shape.

- [ ] **Step 1: Write the failing test**

```ruby
# packages/cli/test/status_test.rb
require "test_helper"

class StatusTest < Minitest::Test
  include CLITestHelpers # provides fixture_app / fixture_registry, per existing tests

  def test_reports_valid_json_outside_a_rails_app
    Dir.mktmpdir do |dir|
      result = Shadwire::Commands::Status.new(root: dir, registry: fixture_registry, ui: silent_ui).call
      assert_equal false, result["rails"]
      assert_equal false, result["configPresent"]
      assert_equal [], result["installed"]
    end
  end

  def test_lists_installed_components_with_their_helpers
    with_installed_app("button") do |dir|
      result = Shadwire::Commands::Status.new(root: dir, registry: fixture_registry, ui: silent_ui).call
      entry = result["installed"].find { |i| i["name"] == "button" }
      refute_nil entry
      assert_includes entry["helpers"], "ui_button"
      assert_equal "unchanged", entry["drift"]
    end
  end

  def test_reports_drift_for_locally_modified_files
    with_installed_app("button") do |dir|
      target = File.join(dir, "app/components/ui/button_component.rb")
      File.write(target, File.read(target) + "\n# local edit\n")
      result = Shadwire::Commands::Status.new(root: dir, registry: fixture_registry, ui: silent_ui).call
      assert_equal "modified", result["installed"].first["drift"]
    end
  end

  def test_flags_the_legacy_monolithic_helper
    with_installed_app("button") do |dir|
      FileUtils.mkdir_p(File.join(dir, "app/helpers"))
      File.write(File.join(dir, "app/helpers/ui_helper.rb"), "module UiHelper; end\n")
      result = Shadwire::Commands::Status.new(root: dir, registry: fixture_registry, ui: silent_ui).call
      assert_equal true, result["helpers"]["legacyHelperPresent"]
    end
  end
end
```

Extend the fixture registry (`packages/cli/test/fixtures/registry/button.json`) with an `api` block carrying `{"class": "Ui::ButtonComponent", "helper": "ui_button", "root": true}` so the helper list has something to read.

- [ ] **Step 2: Run to confirm it fails**

```bash
cd packages/cli && PARALLEL_WORKERS=1 bundle exec ruby -Ilib -Itest test/status_test.rb
```
Expected: FAIL — uninitialized constant `Shadwire::Commands::Status`.

- [ ] **Step 3: Add stack detection to `Project`**

Append to `packages/cli/lib/shadwire/project.rb`:

```ruby
    # False only when the app explicitly disables Rails' automatic helper
    # inclusion; Ui::*Helper modules then need per-controller `helper` calls.
    def include_all_helpers?
      path = path("config/application.rb")
      return true unless File.exist?(path)

      !File.read(path).match?(/include_all_helpers\s*=\s*false/)
    end

    def legacy_helper?
      File.exist?(path("app/helpers/ui_helper.rb"))
    end
```

- [ ] **Step 4: Implement the command**

```ruby
# packages/cli/lib/shadwire/commands/status.rb
# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Reports the consuming app's Shadwire context: stack detection, installed
    # components with the helpers they actually define, and per-component drift.
    # This is what the agent skill injects, so it must always succeed: a missing
    # Rails app or shadwire.json is reported as data, never raised.
    class Status
      def initialize(root:, registry: nil, json: false, ui: UI.new)
        @root = root.to_s
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        project = Project.new(@root)
        config = Config.load(@root)
        result = base_payload(project, config)

        begin
          client = RegistryClient.new(@registry_override || config.registry)
          result["registryVersion"] = client.index["version"]
          result["availableCount"] = Array(client.index["items"]).size
          result["installed"] = installed_entries(config, client)
        rescue Shadwire::Error => e
          result["registryError"] = e.message
        end

        emit(result)
        result
      end

      private

      def base_payload(project, config)
        {
          "rails" => project.rails?,
          "configPresent" => File.exist?(File.join(@root, Config::CONFIG_FILE)),
          "registry" => @registry_override || config.registry,
          "registryVersion" => nil,
          "stack" => {
            "importmap" => project.importmap?,
            "stimulus" => project.stimulus?,
            "tailwindcssRails" => project.tailwindcss_rails?
          },
          "gems" => { "view_component" => project.gem?("view_component"),
                      "lucide-rails" => project.gem?("lucide-rails") },
          "tailwind" => { "css" => config.tailwind_css, "importPresent" => tailwind_import?(config) },
          "helpers" => { "includeAllHelpers" => project.include_all_helpers?,
                         "legacyHelperPresent" => project.legacy_helper? },
          "installed" => [],
          "availableCount" => nil
        }
      end

      def tailwind_import?(config)
        path = File.join(@root, config.tailwind_css)
        File.exist?(path) && File.read(path).include?("shadwire.css")
      end

      def installed_entries(config, client)
        config.installed.map do |name, entry|
          item = client.item(name)
          components = Array(item.dig("api", "components"))
          {
            "name" => name,
            "version" => entry["version"],
            "drift" => drift_for(item),
            "helpers" => components.filter_map { |c| c["helper"] },
            "classes" => components.filter_map { |c| c["class"] }
          }
        rescue Shadwire::Error
          { "name" => name, "version" => entry["version"], "drift" => "unknown",
            "helpers" => [], "classes" => [] }
        end
      end

      def drift_for(item)
        statuses = Array(item["files"]).map do |file|
          path = File.join(@root, file["target"])
          next "missing" unless File.exist?(path)

          File.read(path) == file["content"] ? "unchanged" : "modified"
        end
        return "unchanged" if statuses.all? { |s| s == "unchanged" }

        statuses.include?("modified") ? "modified" : "missing"
      end

      def emit(result)
        return @ui.say(JSON.generate(result)) if @json

        human(result)
      end

      def human(result)
        @ui.say("Rails app: #{result["rails"] ? "yes" : "no"}   shadwire.json: #{result["configPresent"] ? "yes" : "no"}")
        @ui.say("Registry:  #{result["registry"]} (#{result["registryVersion"] || "unavailable"})")
        @ui.say("Stack:     importmap=#{result.dig("stack", "importmap")} stimulus=#{result.dig("stack", "stimulus")} tailwindcss-rails=#{result.dig("stack", "tailwindcssRails")}")
        @ui.say("Installed (#{result["installed"].size}):")
        result["installed"].each { |i| @ui.say("  #{i["drift"].ljust(9)} #{i["name"]}  #{i["helpers"].join(", ")}") }
        @ui.say("Warning: legacy app/helpers/ui_helper.rb found; it is no longer published and can be deleted.") if result.dig("helpers", "legacyHelperPresent")
      end
    end
  end
end
```

- [ ] **Step 5: Register it**

Add `require_relative "shadwire/commands/status"` to `packages/cli/lib/shadwire.rb` (before `shadwire/cli`), and to `packages/cli/lib/shadwire/cli.rb`:

```ruby
    desc "status", "Report app context: stack, installed components, helpers, drift"
    method_option :registry, type: :string, desc: "Registry base URL to reconcile against"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def status
      run_command do |root, ui|
        Commands::Status.new(root:, registry: options[:registry], json: options[:json], ui:).call
      end
    end
```

- [ ] **Step 6: Run the tests**

```bash
cd packages/cli && PARALLEL_WORKERS=1 bundle exec rake test
```
Expected: all pass, including the 4 new status tests.

- [ ] **Step 7: Verify it never breaks the skill's injection**

```bash
cd packages/cli && ruby -Ilib exe/shadwire status --json --cwd /tmp | ruby -rjson -e 'p JSON.parse($stdin.read)["rails"]'; echo "exit=$?"
```
Expected: prints `false` and `exit=0` — valid JSON, exit 0, outside a Rails app.

- [ ] **Step 8: Commit and open the PR**

```bash
git add packages/cli/
git commit -m "feat(cli): add status --json for agent project context

Reports stack detection, installed components with the helpers they
actually define, and per-component drift. Always emits valid JSON and
exits 0 — a missing Rails app or shadwire.json is data, not an exception,
so the agent skill's context injection can never break."
git push -u origin feat/cli-status
gh pr create --title "feat(cli): add status --json" --body "..."
```

---

# Phase 5 (PR 5): Enrich `info --json`

### Task 5.1: Pass the new fields through

**Files:**
- Modify: `packages/cli/lib/shadwire/commands/info.rb`
- Modify: `packages/cli/test/info_test.rb`
- Modify: `packages/cli/test/fixtures/registry/button.json`

- [ ] **Step 1: Write the failing test**

```ruby
def test_info_json_includes_api_and_intent
  payload = Shadwire::Commands::Info.new(
    root: fixture_app, name: "button", registry: fixture_registry, json: true, ui: silent_ui
  ).call
  assert payload.key?("whenToUse")
  assert payload.key?("usage")
  assert payload.key?("requiresStimulus")
  assert_equal "ui_button", payload.dig("api", "components", 0, "helper")
end

def test_human_output_lists_variants_and_helper
  ui = capturing_ui
  Shadwire::Commands::Info.new(root: fixture_app, name: "button", registry: fixture_registry, ui:).call
  assert_match(/ui_button/, ui.output)
  assert_match(/destructive/, ui.output)
end
```

Add `whenToUse`, `usage`, `requiresStimulus` and an `api` block to
`packages/cli/test/fixtures/registry/button.json`.

- [ ] **Step 2: Run to confirm it fails**

```bash
cd packages/cli && PARALLEL_WORKERS=1 bundle exec ruby -Ilib -Itest test/info_test.rb
```
Expected: FAIL.

- [ ] **Step 3: Implement**

`Info#strip_content` already `dup`s the item, so `api`/`whenToUse`/`usage`/`requiresStimulus` pass through the JSON path automatically. Extend only the human rendering, after the description line:

```ruby
        @ui.say("When to use: #{payload["whenToUse"]}") if payload["whenToUse"]

        Array(payload.dig("api", "components")).each do |component|
          label = component["helper"] ? "#{component["class"]} (#{component["helper"]})" : component["class"]
          @ui.say("  #{label}")
          @ui.say("    variants: #{component["variants"].join(" | ")}") if component["variants"]&.any?
          @ui.say("    sizes:    #{component["sizes"].join(" | ")}") if component["sizes"]&.any?
        end

        @ui.say("Requires Stimulus: yes") if payload["requiresStimulus"]

        Array(payload["usage"]).each { |snippet| @ui.say(snippet) }
```

- [ ] **Step 4: Run the tests**

```bash
cd packages/cli && PARALLEL_WORKERS=1 bundle exec rake test
```
Expected: all pass.

- [ ] **Step 5: Commit and open the PR**

```bash
git add packages/cli/
git commit -m "feat(cli): surface component API, whenToUse and usage in info"
git push -u origin feat/cli-info-api
gh pr create --title "feat(cli): enrich info with component API" --body "..."
```

---

# Phase 6 (PR 6): `llms.txt` static entry points

### Task 6.1: Generate and deploy

**Files:**
- Create: `lib/shadwire_registry/llms_writer.rb`
- Create: `test/llms_writer_test.rb`
- Modify: `bin/build_registry`

**Interfaces:**
- Produces: `ShadwireRegistry::LlmsWriter.index(registry:, items:) -> String` and `.full(registry:, items:) -> String`, where `items` is the array of published item hashes.

- [ ] **Step 1: Write the failing test**

```ruby
# test/llms_writer_test.rb
require "minitest/autorun"
require_relative "../lib/shadwire_registry/llms_writer"

class LlmsWriterTest < Minitest::Test
  REGISTRY = { "name" => "shadwire", "version" => "0.2.0" }.freeze
  ITEMS = [{
    "name" => "button", "title" => "Button",
    "description" => "Displays a button or a link styled as a button.",
    "whenToUse" => "Any clickable action.",
    "requiresStimulus" => false,
    "usage" => ["<%= ui_button { \"Save\" } %>"],
    "api" => { "components" => [{ "class" => "Ui::ButtonComponent", "helper" => "ui_button",
                                  "variants" => %w[default outline], "sizes" => %w[sm lg],
                                  "props" => [{ "name" => "tag", "default" => ":button" }] }] }
  }].freeze

  def test_index_lists_name_and_when_to_use
    out = ShadwireRegistry::LlmsWriter.index(registry: REGISTRY, items: ITEMS)
    assert_includes out, "shadwire add button"
    assert_includes out, "button — Any clickable action."
  end

  def test_full_includes_api_and_usage
    out = ShadwireRegistry::LlmsWriter.full(registry: REGISTRY, items: ITEMS)
    assert_includes out, "Ui::ButtonComponent"
    assert_includes out, "ui_button"
    assert_includes out, "default | outline"
    assert_includes out, "<%= ui_button"
  end
end
```

- [ ] **Step 2: Run to confirm it fails**

```bash
ruby test/llms_writer_test.rb
```
Expected: FAIL — cannot load `llms_writer`.

- [ ] **Step 3: Implement**

```ruby
# lib/shadwire_registry/llms_writer.rb
# frozen_string_literal: true

module ShadwireRegistry
  # Renders the published registry as plain text for agents that never install
  # the skill or the CLI. Pure: takes hashes, returns strings.
  module LlmsWriter
    module_function

    def index(registry:, items:)
      <<~TXT
        # #{registry.fetch("name")} #{registry.fetch("version")}

        shadcn/ui components for Ruby on Rails, installed as source you own.
        Install the CLI with `gem install shadwire`, then `shadwire init` and
        `shadwire add <name>`. Full API: llms-full.txt

        ## Components

        #{items.map { |i| "- #{i.fetch("name")} — #{i.fetch("whenToUse")}" }.join("\n")}
      TXT
    end

    def full(registry:, items:)
      body = items.map { |item| card(item) }.join("\n---\n\n")
      <<~TXT
        # #{registry.fetch("name")} #{registry.fetch("version")} — full component reference

        #{body}
      TXT
    end

    def card(item)
      lines = ["## #{item.fetch("name")} — #{item.fetch("title")}", "", item.fetch("description"), "",
               "When to use: #{item.fetch("whenToUse")}", "",
               "Install: `shadwire add #{item.fetch("name")}`"]
      lines << "Requires Stimulus (importmap + eager loading)." if item["requiresStimulus"]
      lines << ""

      Array(item.dig("api", "components")).each do |component|
        lines << "### #{component["class"]}#{component["helper"] ? " — `#{component["helper"]}`" : ""}"
        lines << "variants: #{component["variants"].join(" | ")}" if component["variants"]&.any?
        lines << "sizes: #{component["sizes"].join(" | ")}" if component["sizes"]&.any?
        props = Array(component["props"]).map { |p| p["default"] ? "#{p["name"]}: #{p["default"]}" : p["name"] }
        lines << "props: #{props.join(", ")}" unless props.empty?
        lines << ""
      end

      Array(item["usage"]).each { |snippet| lines << "```erb", snippet, "```", "" }
      lines.join("\n")
    end
  end
end
```

- [ ] **Step 4: Run the tests**

```bash
ruby test/llms_writer_test.rb
```
Expected: PASS.

- [ ] **Step 5: Wire it into the build**

In `bin/build_registry`, collect each published payload into a `published = []`
array inside the item loop, then after writing `index.json`:

```ruby
require_relative "../lib/shadwire_registry/llms_writer"

OUTPUT_DIR.join("llms.txt").write(ShadwireRegistry::LlmsWriter.index(registry: REGISTRY, items: published))
OUTPUT_DIR.join("llms-full.txt").write(ShadwireRegistry::LlmsWriter.full(registry: REGISTRY, items: published))
```

- [ ] **Step 6: Build and check the output**

```bash
ruby bin/build_registry && head -20 build/r/llms.txt && wc -l build/r/llms.txt build/r/llms-full.txt
```
Expected: `llms.txt` lists 58 components with real `whenToUse` text.

- [ ] **Step 7: Commit and open the PR**

```bash
git add lib/shadwire_registry/llms_writer.rb test/llms_writer_test.rb bin/build_registry
git commit -m "feat(registry): publish llms.txt and llms-full.txt"
git push -u origin feat/registry-llms-txt
gh pr create --title "feat(registry): publish llms.txt" --body "..."
```

---

# Phase 7 (PR 7): The skill package

### Task 7.1: Write the skill

**Files:**
- Create: `skills/shadwire/SKILL.md`, `cli.md`, `theming.md`, `rules/{composition,styling,forms,icons}.md`

- [ ] **Step 1: Write `SKILL.md`**

Frontmatter exactly:

```yaml
---
name: shadwire
description: Manages shadcn/ui components in Ruby on Rails apps via the shadwire CLI — adding, searching, composing, theming and updating ViewComponent-based UI. Applies to any Rails project with a shadwire.json, or when asked to add UI components to a Rails app.
user-invocable: false
allowed-tools: Bash(shadwire *), Bash(bundle exec shadwire *)
---
```

Body sections, in order:

1. `## Current Project Context` containing a fenced `json` block whose only content is `` !`shadwire status --json` ``, followed by one sentence explaining that `installed[].helpers` lists the helper methods that actually exist.
2. `## Principles` — use existing components first; compose, don't reinvent; built-in variants before custom classes; semantic tokens only.
3. `## Critical Rules` — the seven rules from the spec, one line each, each linking to its `rules/*.md`.
4. `## Component Selection` — a `need → component` table. Populate it from `registry/registry.json`'s `whenToUse` fields; every name must exist in the registry (Phase 8 enforces this).
5. `## Workflow` — `shadwire search <term>` → `shadwire info <name> --json` (read `api` before writing any ERB) → `shadwire add <name> --yes` → re-read `status` → verify the rendered output.
6. `## Quick Reference` — command cheatsheet mirroring `packages/cli/README.md`.

Do **not** enumerate variants, props, or helper names in `SKILL.md`. That data comes from `info --json`.

- [ ] **Step 2: Write the rules files**

Each rule gets a Wrong/Right ERB pair, read from real registry source so the
snippets compile:

- `rules/composition.md` — nested subcomponent helpers vs invented props (`ui_card_header` block, never `header:`); Dialog/Sheet need a title for accessibility; there are no ViewComponent slots, composition is nested classes.
- `rules/styling.md` — semantic tokens vs `bg-blue-500`; `class:`/`class_name:` equivalence; user classes land last in `class_names(base, variant, size, @class_name)` so they win; free attributes via `**attrs` preserving `data: { turbo: false }`.
- `rules/forms.md` — the `field` family (`ui_field`, `ui_field_group`, `ui_field_label`, `ui_field_error`, `ui_field_description`); there is no form-builder wrapper, so pass `name:`/`id:`/`value:` through `**attrs`. Verify each helper name against `registry/rails/ui/helpers/ui/field_helper.rb` before writing it.
- `rules/icons.md` — lucide-rails kebab-case names (`"chevron-down"`); decorative and `aria-hidden` by default, `label:` to expose; compose inside components rather than an `icon:` prop; `size: :icon` for icon-only buttons.

- [ ] **Step 3: Write `cli.md` and `theming.md`**

`cli.md` — every command with its flags, derived from `packages/cli/README.md` plus `status`. Include the agent path: `--yes`, `--json`, `--cwd`, and `diff --exit-code` for CI.

`cli.md` must also state the known CLI gaps recorded in the spec, so an agent does not trust misleading output:
- `bundle add` failure is currently reported as success with exit 0 — after `init`/`add`, verify the gems landed in the Gemfile.
- `init` and `add` do not accept `--json`.
- `update --yes` overwrites local edits; run `shadwire diff` first.

`theming.md` — the token table from `README.md`, `:root` / `.dark` blocks in `vendor/shadwire/shadwire.css`, Tailwind v4 `@theme inline`, and how to add a custom color without editing component classes.

- [ ] **Step 4: Verify every helper mentioned actually exists**

```bash
for h in $(grep -rho "ui_[a-z_]*" skills/shadwire/ | sort -u); do
  grep -rq "def $h\b" registry/rails/ui/helpers/ui/ || echo "MISSING HELPER: $h"
done
echo "helper check done"
```
Expected: no `MISSING HELPER` lines.

- [ ] **Step 5: Verify every component named exists**

```bash
ruby -e 'require "json"
names = JSON.parse(File.read("registry/registry.json"))["items"].map { |i| i["name"] }
text = Dir["skills/shadwire/**/*.md"].map { |f| File.read(f) }.join
cited = text.scan(/`(shadwire add ([a-z0-9-]+))`/).map { |_, n| n }.uniq
missing = cited - names
puts missing.empty? ? "component check ok" : "MISSING: #{missing.inspect}"'
```
Expected: `component check ok`.

- [ ] **Step 6: Commit and open the PR**

```bash
git add skills/
git commit -m "feat(skill): add the shadwire agent skill

Entry point plus progressive-disclosure references, modelled on
shadcn-ui/ui:skills/shadcn. Carries procedure only — component names,
variants, props and helpers are pulled at runtime from
\`shadwire status --json\` and \`shadwire info --json\`, so the skill
cannot drift from the registry."
git push -u origin feat/agent-skill
gh pr create --title "feat(skill): add the shadwire agent skill" --body "..."
```

---

# Phase 8 (PR 8): CI verification

### Task 8.1: The `skill_check` test

**Files:**
- Create: `test/skill_check_test.rb`
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Write the test**

```ruby
# test/skill_check_test.rb
# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"

# Guards the agent skill against drifting from the registry and CLI it documents.
# Deterministic — no model in the loop.
class SkillCheckTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)
  SKILL_FILES = Dir[ROOT.join("skills/shadwire/**/*.md")].sort.freeze
  SKILL_TEXT = SKILL_FILES.map { |f| File.read(f) }.join("\n").freeze
  HELPER_SOURCE = Dir[ROOT.join("registry/rails/ui/helpers/ui/*.rb")]
                    .map { |f| File.read(f) }.join("\n").freeze

  def test_skill_files_exist
    refute_empty SKILL_FILES
    assert_path_exists ROOT.join("skills/shadwire/SKILL.md")
  end

  def test_skill_frontmatter_declares_name_and_description
    body = ROOT.join("skills/shadwire/SKILL.md").read
    assert_match(/\A---\n/, body, "SKILL.md must start with YAML frontmatter")
    frontmatter = body[/\A---\n(.*?)\n---\n/m, 1].to_s
    assert_match(/^name: shadwire$/, frontmatter)
    assert_match(/^description: .+/, frontmatter)
  end

  def test_every_helper_mentioned_exists
    mentioned = SKILL_TEXT.scan(/\bui_[a-z0-9_]+/).uniq
    missing = mentioned.reject { |h| HELPER_SOURCE.match?(/def #{Regexp.escape(h)}\b/) }
    assert_empty missing, "skill references helpers that do not exist: #{missing.inspect}"
  end

  def test_every_component_mentioned_exists
    names = REGISTRY.fetch("items").map { |i| i.fetch("name") }
    cited = SKILL_TEXT.scan(/shadwire (?:add|info|remove) ([a-z0-9-]+)/).flatten.uniq
    assert_empty cited - names, "skill references unknown components: #{(cited - names).inspect}"
  end

  def test_every_cli_command_mentioned_exists
    known = %w[init add list search info diff update remove status version help]
    cited = SKILL_TEXT.scan(/`shadwire ([a-z-]+)/).flatten.uniq
    assert_empty cited - known, "skill references unknown commands: #{(cited - known).inspect}"
  end

  def test_usage_snippets_reference_real_helpers
    REGISTRY.fetch("items").each do |item|
      Array(item["usage"]).each do |snippet|
        snippet.scan(/\bui_[a-z0-9_]+/).uniq.each do |helper|
          assert_match(/def #{Regexp.escape(helper)}\b/, HELPER_SOURCE,
                       "#{item.fetch("name")} usage calls #{helper}, which no helper module defines")
        end
      end
    end
  end
end
```

- [ ] **Step 2: Run it**

```bash
ruby test/skill_check_test.rb
```
Expected: PASS. If it fails, the skill or the usage snippets are wrong — fix those, not the test.

- [ ] **Step 3: Add the smoke test**

Append to `test/skill_check_test.rb`:

```ruby
  def test_documented_workflow_runs_end_to_end
    require "tmpdir"
    require "fileutils"
    require "shellwords"

    Dir.mktmpdir("shadwire-smoke") do |app|
      FileUtils.mkdir_p(File.join(app, "config"))
      FileUtils.mkdir_p(File.join(app, "app/assets/tailwind"))
      File.write(File.join(app, "config/application.rb"), "# rails\n")
      File.write(File.join(app, "Gemfile"), %(source "https://rubygems.org"\ngem "rails"\n))
      File.write(File.join(app, "app/assets/tailwind/application.css"), %(@import "tailwindcss";\n))

      build = Dir.mktmpdir("shadwire-smoke-build")
      system({ "BUILD_DIR" => build }, ROOT.join("bin/build_registry").to_s, out: File::NULL) ||
        flunk("build_registry failed")
      registry = "file://#{build}/r"
      cli = ROOT.join("packages/cli/exe/shadwire").to_s
      lib = ROOT.join("packages/cli/lib").to_s

      run = lambda do |*args|
        out = `ruby -I#{lib.shellescape} #{cli.shellescape} #{args.map(&:to_s).shelljoin} --cwd #{app.shellescape} --registry #{registry.shellescape} 2>&1`
        [out, $?.success?]
      end

      _, ok = run.call("init", "--yes")
      assert ok, "init failed"
      _, ok = run.call("add", "button", "--yes")
      assert ok, "add failed"

      out, ok = run.call("status", "--json")
      assert ok, "status failed"
      status = JSON.parse(out.lines.last)
      assert_equal true, status["rails"]
      assert_includes status["installed"].flat_map { |i| i["helpers"] }, "ui_button"

      out, ok = run.call("diff")
      assert ok, "diff failed: #{out}"
      refute_match(/modified|missing/, out, "freshly installed files should not have drifted")

      assert_path_exists File.join(app, "app/helpers/ui/button_helper.rb")
      refute_path_exists File.join(app, "app/helpers/ui_helper.rb"),
        "the monolithic helper must no longer be installed"
    ensure
      FileUtils.remove_entry(build, true) if build
    end
  end
```

- [ ] **Step 4: Run it**

```bash
ruby test/skill_check_test.rb
```
Expected: PASS — this is the end-to-end proof that the documented workflow works and that only `button`'s helper is installed.

- [ ] **Step 5: Add the CI job**

In `.github/workflows/ci.yml`, after the `cli` job:

```yaml
  skill_check:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v7
      - uses: ruby/setup-ruby@v1
        with:
          working-directory: packages/cli
          ruby-version: .ruby-version
          bundler-cache: true
      - name: Extractor tests
        run: ruby test/api_extractor_test.rb
      - name: llms writer tests
        run: ruby test/llms_writer_test.rb
      - name: Skill accuracy + workflow smoke test
        run: ruby test/skill_check_test.rb
```

Add `skill_check` to the `deploy_pages` job's `needs:` list.

- [ ] **Step 6: Add the new tests to the root Rakefile**

```ruby
task :test do
  ruby "test/registry_manifest_test.rb"
  ruby "test/registry_schema_test.rb"
  ruby "test/registry_build_test.rb"
  ruby "test/api_extractor_test.rb"
  ruby "test/llms_writer_test.rb"
  ruby "test/skill_check_test.rb"
  Dir.chdir("sandbox") do
    sh "bin/rails test test/components test/integration/ui_accessibility_test.rb"
  end
end
```

- [ ] **Step 7: Commit and open the PR**

```bash
git add test/skill_check_test.rb .github/workflows/ci.yml Rakefile
git commit -m "test(skill): verify skill accuracy and workflow in CI"
git push -u origin test/skill-check
gh pr create --title "test(skill): CI-verify the agent skill" --body "..."
```

---

# Phase 9 (PR 9): Release the gem and publish the skill

### Task 9.1: Gem release workflow

**Files:**
- Create: `.github/workflows/release.yml`
- Modify: `packages/cli/lib/shadwire/version.rb`, `packages/cli/shadwire.gemspec`

- [ ] **Step 1: Align the version and gemspec files**

Set `Shadwire::VERSION = "0.2.0"` to match `registry.json`. In `shadwire.gemspec`,
add the metadata RubyGems needs:

```ruby
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "#{spec.homepage}/tree/main/packages/cli",
    "changelog_uri" => "#{spec.homepage}/releases",
    "rubygems_mfa_required" => "true"
  }
```

- [ ] **Step 2: Verify the gem builds and its file list is complete**

```bash
cd packages/cli && gem build shadwire.gemspec && tar -tf shadwire-0.2.0.gem | head
gem contents --spec-file shadwire.gemspec 2>/dev/null || tar -xOf shadwire-0.2.0.gem data.tar.gz | tar -tzf - | grep -c "lib/shadwire/commands/status.rb"
```
Expected: builds cleanly and the archive contains `lib/shadwire/commands/status.rb`.

- [ ] **Step 3: Add the release workflow**

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags: ["v*"]

permissions:
  contents: read
  id-token: write   # trusted publishing to RubyGems

jobs:
  publish:
    runs-on: ubuntu-latest
    environment: rubygems
    steps:
      - uses: actions/checkout@v7
      - uses: ruby/setup-ruby@v1
        with:
          working-directory: packages/cli
          ruby-version: .ruby-version
          bundler-cache: true
      - name: Verify the tag matches the gem version
        working-directory: packages/cli
        run: |
          gem_version=$(ruby -Ilib -e 'require "shadwire/version"; print Shadwire::VERSION')
          tag_version="${GITHUB_REF_NAME#v}"
          if [ "$gem_version" != "$tag_version" ]; then
            echo "::error::tag $tag_version does not match Shadwire::VERSION $gem_version"
            exit 1
          fi
      - name: Test
        working-directory: packages/cli
        env:
          PARALLEL_WORKERS: "1"
        run: bundle exec rake test
      - uses: rubygems/release-gem@v1
        with:
          working-directory: packages/cli
```

- [ ] **Step 4: Configure trusted publishing**

On rubygems.org, create the `shadwire` gem's trusted publisher entry for
repository `edumoraes/shadwire`, workflow `release.yml`, environment `rubygems`.
This is a manual step in the RubyGems UI and must be done before tagging.

- [ ] **Step 5: Fix the install instructions**

`README.md` and `packages/cli/README.md` already document `gem install shadwire`;
verify they are correct once published. Update the root `README.md` component list
— it names 28 components while the registry has 58. Generate it:

```bash
ruby -e 'require "json"
items = JSON.parse(File.read("registry/registry.json"))["items"]
items.select { |i| i["type"] == "component" }.each { |i| puts "- `#{i["name"]}` — #{i["description"]}" }'
```

Replace the hand-maintained `Ui::*Component` list with this output.

- [ ] **Step 6: Commit, tag and publish**

```bash
git add .github/workflows/release.yml packages/cli/ README.md
git commit -m "chore(release): add trusted-publishing workflow for the gem"
git push -u origin chore/gem-release
gh pr create --title "chore(release): publish the shadwire gem" --body "..."
# after merge:
git checkout main && git pull
git tag v0.2.0 && git push origin v0.2.0
```

- [ ] **Step 7: Verify publication**

```bash
sleep 60; curl -s "https://rubygems.org/api/v1/gems/shadwire.json" | ruby -rjson -e 'p JSON.parse($stdin.read)["version"]'
```
Expected: `"0.2.0"`.

### Task 9.2: Publish to skills.sh

- [ ] **Step 1: Confirm the repo layout matches what skills.sh expects**

`skills/shadwire/SKILL.md` at the repository root mirrors
`shadcn-ui/ui:skills/shadcn/SKILL.md`, which is installed with
`npx skills add shadcn/ui`.

- [ ] **Step 2: Install it from a clean directory to prove the path works**

```bash
cd "$(mktemp -d)" && npx -y skills add edumoraes/shadwire 2>&1 | tail -20
find . -name "SKILL.md" | head
```
Expected: the skill is fetched and written into the agent's skills directory. If
`skills add` requires the skill at a different path, move it and re-run — the
install path is the acceptance criterion.

- [ ] **Step 3: Document installation for users**

Add to the root `README.md`, under the CLI section:

```markdown
### Agent skill

Coding agents (Claude Code, Codex, Cursor, OpenCode and ~20 others) can install
the Shadwire skill for full context on the CLI and components:

```bash
npx skills add edumoraes/shadwire
```

The skill pulls live project context from `shadwire status --json`, so it always
reflects what is actually installed.
```

- [ ] **Step 4: Submit to the skills.sh directory**

Follow the submission process at <https://skills.sh> for listing
`edumoraes/shadwire` in the public directory. Record the outcome (listed / pending
review) in the PR description.

- [ ] **Step 5: Commit and open the PR**

```bash
git add README.md
git commit -m "docs: document agent skill installation via skills.sh"
git push -u origin docs/skill-install
gh pr create --title "docs: document skill installation" --body "..."
```

---

## Final verification

- [ ] `ruby -e 'require "rake"' && rake test` from the repo root — all suites pass.
- [ ] `cd packages/cli && PARALLEL_WORKERS=1 bundle exec rake test` — passes.
- [ ] `cd sandbox && bin/rubocop` — clean.
- [ ] `gh run list --limit 5` — CI green on `main`.
- [ ] `curl -s https://edumoraes.github.io/shadwire/r/llms.txt | head` — serves real content.
- [ ] `curl -s https://rubygems.org/api/v1/gems/shadwire.json` — gem is published.
- [ ] `npx skills add edumoraes/shadwire` from a clean directory — installs.

## Self-review notes

**Spec coverage:** §1 → Phase 1; §2 → Phases 2–3; §3 → Phases 4–5; §4 → Phase 6;
§5 → Phase 7; §6 → Phase 8; §7 → Phase 9. §8 (known gaps) is documented in
`cli.md` in Phase 7 Step 3 rather than fixed, as scoped.

**Ordering constraint:** Phase 4's `status` reads `api.components[].helper`, which
Phase 3 produces. Phase 8's smoke test asserts `app/helpers/ui/button_helper.rb`
exists, which Phase 1 produces. Phases must land in order.

**Known risk:** Phase 2 is the largest manual step — `whenToUse` and `usage` for
58 items. It is mechanical but not automatable; the value of `search` and the
skill's Component Selection table both depend on its quality.
