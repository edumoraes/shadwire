# Shadwire MVP Phase 3: Validation and Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the sandbox showcase, basic accessibility coverage, registry contract tests, final verification, and MVP workflow documentation.

**Architecture:** Continue from Phases 1 and 2. The sandbox demonstrates synced registry components in a real Rails route, root tests validate registry install metadata, and final documentation explains the registry-first workflow.

**Tech Stack:** Ruby 3.4, Rails, ViewComponent, Tailwind CSS v4, Turbo, Stimulus, Minitest, ActionDispatch integration tests.

---

**Prerequisite:** Complete `2026-05-21-shadwire-mvp-phase-2-components.md` through Task 7.

**Completion:** This phase finishes the Shadwire MVP implementation plan.

---

### Task 8: Add Sandbox Showcase and Basic Accessibility Coverage

**Files:**
- Create: `sandbox/app/controllers/showcase_controller.rb`
- Create: `sandbox/app/views/showcase/index.html.erb`
- Modify: `sandbox/config/routes.rb`
- Create: `sandbox/test/integration/ui_accessibility_test.rb`

- [ ] **Step 1: Add showcase controller**

Create `sandbox/app/controllers/showcase_controller.rb`:

```ruby
# frozen_string_literal: true

class ShowcaseController < ApplicationController
  def index
  end
end
```

- [ ] **Step 2: Add showcase view**

Create `sandbox/app/views/showcase/index.html.erb`:

```erb
<main class="mx-auto flex max-w-4xl flex-col gap-8 p-8">
  <section class="flex flex-col gap-4">
    <h1 class="text-3xl font-bold tracking-normal">Shadwire</h1>
    <p class="text-muted-foreground">Rails ViewComponent ports of shadcn/ui components.</p>
  </section>

  <section class="flex flex-wrap items-center gap-3">
    <%= ui_button { "Default" } %>
    <%= ui_button(variant: :outline) { "Outline" } %>
    <%= ui_badge { "Badge" } %>
    <%= ui_badge(variant: :secondary) { "Secondary" } %>
  </section>

  <%= ui_separator %>

  <%= ui_alert do %>
    Components render through ViewComponent helpers and keep Rails HTML attributes.
  <% end %>

  <%= ui_card(class_name: "max-w-md") do %>
    <%= ui_card_header do %>
      <%= ui_card_title { "Card title" } %>
      <%= ui_card_description { "Composed subcomponents match the shadcn structure." } %>
    <% end %>
    <%= ui_card_content do %>
      <p>Card content is rendered as server-side HTML.</p>
    <% end %>
    <%= ui_card_footer do %>
      <%= ui_button(size: :sm) { "Action" } %>
    <% end %>
  <% end %>

  <%= ui_avatar(src: "https://example.com/avatar.png", alt: "Example user", fallback: "EU") %>
</main>
```

- [ ] **Step 3: Wire route**

Edit `sandbox/config/routes.rb`:

```ruby
Rails.application.routes.draw do
  root "showcase#index"
end
```

- [ ] **Step 4: Add basic accessibility integration test**

Create `sandbox/test/integration/ui_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class UiAccessibilityTest < ActionDispatch::IntegrationTest
  test "showcase renders semantic component markup" do
    get root_path

    assert_response :success
    assert_select "main"
    assert_select "button[type='button']", text: "Default"
    assert_select "[role='alert']", text: /Components render/
    assert_select "[role='separator'][aria-orientation='horizontal']"
    assert_select "img[alt='Example user']"
  end
end
```

- [ ] **Step 5: Run route and accessibility tests**

Run:

```bash
cd sandbox
bin/rails test test/integration/ui_accessibility_test.rb
```

Expected:

Output contains `1 runs` and `0 failures, 0 errors, 0 skips`.

- [ ] **Step 6: Commit**

Run:

```bash
git add sandbox/app/controllers/showcase_controller.rb sandbox/app/views/showcase/index.html.erb sandbox/config/routes.rb sandbox/test/integration/ui_accessibility_test.rb
git commit -m "test: add sandbox showcase accessibility coverage"
```

Expected:

Commit succeeds with subject `test: add sandbox showcase accessibility coverage`.

---

### Task 9: Validate Registry Sources and Sync Contract

**Files:**
- Create: `test/registry_manifest_test.rb`
- Create: `Rakefile`

- [ ] **Step 1: Add registry manifest test**

Create `test/registry_manifest_test.rb`:

```ruby
# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"

class RegistryManifestTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)

  def test_all_declared_sources_exist
    REGISTRY.fetch("items").each do |item|
      item.fetch("files").each do |file|
        source = ROOT.join(file.fetch("source"))
        assert source.file?, "#{item.fetch("name")} source missing: #{source.relative_path_from(ROOT)}"
      end
    end
  end

  def test_all_targets_are_app_relative_or_vendor_relative
    allowed_prefixes = ["app/", "vendor/"]

    REGISTRY.fetch("items").each do |item|
      item.fetch("files").each do |file|
        target = file.fetch("target")
        assert allowed_prefixes.any? { |prefix| target.start_with?(prefix) }, "#{item.fetch("name")} target is outside install roots: #{target}"
      end
    end
  end

  def test_each_item_includes_shared_component_helper_and_style
    REGISTRY.fetch("items").each do |item|
      sources = item.fetch("files").map { |file| file.fetch("source") }

      assert_includes sources, "registry/rails/ui/components/ui_component.rb"
      assert_includes sources, "registry/rails/ui/helpers/ui_helper.rb"
      assert_includes sources, "registry/rails/ui/styles/shadwire.css"
    end
  end
end
```

- [ ] **Step 2: Add root Rakefile**

Create `Rakefile`:

```ruby
# frozen_string_literal: true

task default: :test

task :test do
  ruby "test/registry_manifest_test.rb"
  Dir.chdir("sandbox") do
    sh "bin/rails test test/components test/integration/ui_accessibility_test.rb"
  end
end
```

- [ ] **Step 3: Run registry tests**

Run:

```bash
ruby test/registry_manifest_test.rb
```

Expected:

Output contains `3 runs` and `0 failures, 0 errors, 0 skips`.

- [ ] **Step 4: Run full test suite**

Run:

```bash
rake test
```

Expected:

```text
0 failures, 0 errors, 0 skips
```

- [ ] **Step 5: Commit**

Run:

```bash
git add Rakefile test/registry_manifest_test.rb
git commit -m "test: validate registry manifest"
```

Expected:

Commit succeeds with subject `test: validate registry manifest`.

---

### Task 10: Final Verification and MVP Documentation

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update README with final MVP commands**

Replace `README.md` with:

```markdown
# Shadwire

Shadwire ports the shadcn/ui Open Code model to Ruby on Rails.

The source of truth is `registry/`. The Rails app in `sandbox/` consumes copied registry files so components are validated in a real Rails, ViewComponent, Tailwind CSS v4, and Hotwire environment.

## Components

The MVP includes:

- `Ui::ButtonComponent`
- `Ui::BadgeComponent`
- `Ui::CardComponent`
- `Ui::Card::HeaderComponent`
- `Ui::Card::TitleComponent`
- `Ui::Card::DescriptionComponent`
- `Ui::Card::ContentComponent`
- `Ui::Card::FooterComponent`
- `Ui::AlertComponent`
- `Ui::SeparatorComponent`
- `Ui::AvatarComponent`

Helpers use the `ui_*` prefix.

```erb
<%= render Ui::ButtonComponent.new(variant: :outline, size: :sm) do %>
  Save
<% end %>

<%= ui_button(variant: :outline, size: :sm) { "Save" } %>
```

## Registry Workflow

Edit source files in `registry/rails/ui`.

Sync registry files into the sandbox:

```bash
bin/sync_registry
```

Run all tests:

```bash
rake test
```

Run sandbox tests only:

```bash
cd sandbox
bin/rails test test/components test/integration/ui_accessibility_test.rb
```

## Translation Rules

| shadcn / React concept | Shadwire / Rails equivalent |
| --- | --- |
| Base class string | `base_classes` method |
| `cva` variants | frozen Ruby hashes |
| `cn(...)` and `className` | `class_names(..., @class_name)` |
| React props | `initialize(...)` keyword arguments |
| `children` | `content` |
| `asChild` | configurable `tag:` or conditional rendering |
| Radix/Base behavior | native HTML, Stimulus, or Hotwire |

## Commits

Use Conventional Commits:

```bash
git commit -m "feat: add button component"
git commit -m "test: cover card component"
git commit -m "docs: update registry workflow"
```
```

- [ ] **Step 2: Run sync**

Run:

```bash
bin/sync_registry
```

Expected output includes every source component copied into `sandbox/app/components`.

- [ ] **Step 3: Run full verification**

Run:

```bash
rake test
git status --short
```

Expected:

```text
0 failures, 0 errors, 0 skips
 M README.md
```

The status may also show synced sandbox files if registry files changed after the last sync commit. Include those files in the documentation commit only if the diff is caused by the final sync.

- [ ] **Step 4: Commit README**

Run:

```bash
git add README.md
git commit -m "docs: document mvp workflow"
```

Expected:

Commit succeeds with subject `docs: document mvp workflow`.

- [ ] **Step 5: Verify clean working tree**

Run:

```bash
git status --short
```

Expected:

```text
```

No output means the working tree is clean.

---

## Self-Review

Spec coverage:

- Monorepo structure is covered by Task 1.
- Rails sandbox is covered by Task 2.
- Registry source of truth and schema are covered by Task 3.
- Shared helpers, CSS tokens, and Tailwind v4 base are covered by Task 4.
- Button and Badge are covered by Task 5.
- Card and named subcomponents are covered by Task 6.
- Alert, Separator, and Avatar are covered by Task 7.
- Hotwire-compatible sandbox validation and basic accessibility are covered by Task 8.
- Registry validation is covered by Task 9.
- Documentation and final verification are covered by Task 10.

Placeholder scan:

- No task contains open gaps.
- Each code-creating step includes concrete file content.
- Each verification step has an exact command and expected result.

Type and API consistency:

- Components use `Ui::*Component`.
- Shared component base is `UiComponent`, copied to `app/components/ui_component.rb`.
- Public helpers use the `ui_*` prefix.
- Components accept `class_name:` and `class:` via `extract_class_name`.
- Registry sources and sync targets use the same paths declared in the spec.
