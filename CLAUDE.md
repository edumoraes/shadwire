# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Shadwire ports the shadcn/ui "Open Code" model to Ruby on Rails: open, copyable
Rails component source that an app installs and then owns. It is **not** a
runtime gem/engine — installed files must work without any Shadwire dependency.

The MVP builds the foundation only. The CLI is deferred (`packages/cli/` is a
reserved placeholder). See `docs/superpowers/specs/2026-05-21-shadwire-mvp-design.md`
for the full design and `docs/superpowers/plans/` for the phased implementation plans.

## Critical workflow rule

`registry/` is the **source of truth**. `sandbox/` is a downstream consumer.

- Edit component source in `registry/rails/ui/...` — never directly in `sandbox/app/...`.
- Run `bin/sync_registry` to copy registry files into the sandbox.
- Synced files under `sandbox/app/components/`, `sandbox/app/helpers/ui_helper.rb`,
  and `sandbox/vendor/shadwire/` are generated artifacts. Changes there are lost
  on the next sync. If validation surfaces a fix, apply it in `registry/` and re-sync.

## Commands

Run from the repo root:

```bash
bin/sync_registry                 # sync every registry item whose source files all exist
bin/sync_registry button badge    # sync only the named items (errors on unknown names)
```

Run from `sandbox/`:

```bash
bin/rails test test/components test/integration/ui_accessibility_test.rb   # component + a11y tests
bin/rails test test/components/ui/button_component_test.rb                 # one test file
bin/rails test test/components/ui/button_component_test.rb:42              # one test by line
bin/rubocop                        # lint (rubocop-rails-omakase)
bin/ci                             # full CI pipeline (see config/ci.rb)
bin/dev                            # dev server + Tailwind watch (Procfile.dev)
```

The sandbox targets Ruby 3.4.8 / Rails 8.1. The `dependencies` block in
`registry.json` (`ruby >= 3.2`, `rails >= 7.1`, `view_component >= 4.0`) is the
*consuming app's* support floor — keep registry component code compatible with it.

## Architecture

Monorepo; the repo root is **not** a Rails app.

- `registry/registry.json` — public install manifest. Each `items[]` entry lists
  a component's `files[]` as `source` (path in registry) → `target` (path in a
  consuming Rails app). Every item bundles the shared `ui_component.rb`,
  `ui_helper.rb`, and `shadwire.css` alongside its own component file(s).
- `registry/rails/ui/` — source of truth: `components/`, `helpers/ui_helper.rb`,
  `styles/shadwire.css`, `javascript/controllers/` (reserved for future Stimulus).
- `sandbox/` — Rails app (ViewComponent, Tailwind v4, importmap, Turbo, Stimulus)
  that validates synced components via render tests and accessibility checks.
- `bin/sync_registry` — copies registry files into the sandbox. With no args it
  skips items with missing source files (warns); validates that targets stay
  inside `sandbox/` and that no two sources map to the same target.

Tailwind loads Shadwire tokens via `@import` in `sandbox/app/assets/tailwind/application.css`,
pointing at the synced `vendor/shadwire/shadwire.css`.

## Component conventions

- Components live in the `Ui` namespace and subclass `UiComponent` (`ViewComponent::Base`).
  Files are flat at the root (`ui/button_component.rb`) with nested subcomponents
  for named parts (`ui/card/header_component.rb` → `Ui::Card::HeaderComponent`).
- `UiComponent` provides shared helpers: `extract_class_name`, `fetch_variant`, `html_attrs`.
- ViewComponent classes are the official API. `ui_*` methods in `ui_helper.rb` are
  thin convenience wrappers — add one per new root component / common subcomponent.
- Rendering is hybrid: start with a `call` method; add an ERB template only when
  structure, conditionals, or slots would make `call` hard to read.
- Accept both `class:` and `class_name:`, normalized to `@class_name`. Pass free
  HTML attributes through `**attrs`, preserving Rails nested forms (`data: { turbo: false }`).
- Compose classes in this order: `class_names(base_classes, variant_classes, size_classes, @class_name)`.
- Use shadcn semantic Tailwind tokens (`bg-primary`, `text-muted-foreground`,
  `border-input`, …) — no hardcoded colors unless upstream shadcn does so.

### Adding a component

1. Create the component file(s) under `registry/rails/ui/components/`.
2. Add an `items[]` entry in `registry/registry.json` (include `ui_component.rb`,
   `ui_helper.rb`, `shadwire.css` in `files[]`).
3. Add a `ui_*` wrapper in `registry/rails/ui/helpers/ui_helper.rb`.
4. `bin/sync_registry`, then add render tests in `sandbox/test/components/`.

React → Rails translation: `cva` variants → frozen Ruby hashes; `cn()`/`className`
→ `class_names(..., @class_name)`; props → `initialize` keyword args; `children`
→ `content`; `asChild` → configurable `tag:` or conditional rendering.

## Commits

Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).
