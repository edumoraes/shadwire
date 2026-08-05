# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Shadwire ports the shadcn/ui "Open Code" model to Ruby on Rails: open, copyable
Rails component source that an app installs and then owns. It is **not** a
runtime gem/engine — installed files must work without any Shadwire dependency.

`registry/` holds the component source; the `shadwire` CLI in `packages/cli/`
installs it into a consuming app. The CLI is a development-time tool — a gem the
consuming app runs, not something the *installed* components depend on at runtime.
See `docs/superpowers/specs/2026-05-21-shadwire-mvp-design.md` for the full design
and `docs/superpowers/plans/` for the phased implementation plans.

## Critical workflow rule

`registry/` is the **source of truth**. `sandbox/` is a downstream consumer.

- Edit component source in `registry/rails/ui/...` — never directly in `sandbox/app/...`.
- Run `bin/sync_registry` to copy registry files into the sandbox.
- Synced files under `sandbox/app/components/`, `sandbox/app/helpers/ui_helper.rb`,
  and `sandbox/vendor/shadwire/` are generated artifacts. Changes there are lost
  on the next sync. If validation surfaces a fix, apply it in `registry/` and re-sync.
- `registry/` is also published for the CLI: `bin/build_registry` inlines each
  item's file contents into `build/r/{name}.json` (plus `index.json`), the format
  the CLI installs from over HTTP. `build/` is generated (gitignored) and rebuilt
  in CI — never hand-edit it; fix the source in `registry/` and rebuild.

## Commands

Run from the repo root:

```bash
bin/sync_registry                 # sync every registry item whose source files all exist
bin/sync_registry button badge    # sync only the named items (errors on unknown names)
bin/build_registry                # build the published registry the CLI installs from → build/r/
```

Run from `packages/cli/` (the CLI gem):

```bash
bundle exec rake test             # the shadwire CLI's Minitest suite (serial)
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
`registry.json` (`ruby >= 3.2`, `rails >= 7.1`, `view_component >= 4.0`,
`lucide-rails >= 0.7`) is the *consuming app's* support floor — keep registry
component code compatible with it.

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
  It is also the **docs site**: CI freezes it to static HTML and publishes it.
- `bin/sync_registry` — copies registry files into the sandbox. With no args it
  skips items with missing source files (warns); validates that targets stay
  inside `sandbox/` and that no two sources map to the same target.
- `bin/build_registry` — builds the *published* registry consumed by the CLI:
  transforms `registry/registry.json` into `build/r/{name}.json` + `index.json`
  with each file's `content` inlined (no source paths). The `deploy_pages` CI job
  runs it and serves the output at `https://shadwire.edumoraes.dev.br/r/...`.
- `packages/cli/` — the `shadwire` CLI gem (Thor). Installs components from the
  published registry into a consuming Rails app (`init`, `add`, `list`, `search`,
  `info`, `diff`, `update`, `remove`); has its own serial Minitest suite. See
  `packages/cli/README.md` for the command reference.

Tailwind loads Shadwire tokens via `@import` in `sandbox/app/assets/tailwind/application.css`,
pointing at the synced `vendor/shadwire/shadwire.css`.

## The docs site

The sandbox *is* the published site. Guides and components share one shell,
`sandbox/app/views/layouts/docs.html.erb`: header, sidebar grouped by topic,
breadcrumb, "Nesta página" rail, previous/next pager, ⌘K palette.

- `DocsNavHelper` is the single source of the sidebar. Guide pages are listed by
  hand; the **Componentes group is derived from `registry/registry.json`**, so a
  new component appears there as soon as it has a `get "components/<name>"`
  route. `test/helpers/docs_nav_helper_test.rb` fails if the two drift apart.
- Guide pages live in `sandbox/app/views/docs/` and are served by `DocsController`.
- **Code samples go in `sandbox/app/lib/docs_snippets.rb`, never inline in a view.**
  An ERB template cannot hold a heredoc containing ERB tags: the scanner closes
  the tag at the first `%>` and the heredoc never terminates. `DocsController`
  assigns the page's hash to `@snippets` in a `before_action`.
- The "Nesta página" rail is built client-side by `docs_toc_controller.js` from
  the `h2`/`h3` already in `<main>`, so no page declares its own outline.

### The site is bilingual

English is the default and owns the bare paths (`/docs`); Portuguese lives under
`/pt`. The locale is in the URL and nowhere else — no session, no cookie, no
Accept-Language — because the published site is a static crawl: nothing survives
to serve time that could negotiate one. Routes sit inside
`scope "(:locale)", locale: /pt/`, and `ApplicationController#default_url_options`
keeps generated links inside the language being read.

**Where a string goes depends on what it is:**

- **Chrome** (header, footer, sidebar, pager, search, code-block controls) and
  **tabular data** (CLI commands, theme tokens, example captions, API table
  headers) → `config/locales/{en,pt}.yml`. These repeat across pages; duplicating
  them is how they drift. `en.yml` is the reference and `pt.yml` mirrors it.
- **Page prose** → locale-suffixed templates, `installation.en.html.erb` /
  `installation.pt.html.erb`. This text is threaded through markup and inline
  `<code>` and reads as a document, not a string table.
- **Example partials** under `components/examples/` → English by default, one
  copy. They illustrate a registry whose language is English, and their source is
  shown verbatim as the documentation, so `ui_button { "Save" }` stays as it is.
  A demo whose *content* is prose or domain data (an accordion's FAQ, a table of
  invoices, a toast's message) gets a second file, `_foo.pt.html.erb`. Rails
  picks it by locale on its own; `DocsHelper#example_source` makes the same
  choice when reading the file back, so the snippet always matches the preview.
  `ExampleLocalisationTest` guards both directions — most of all that no English
  partial contains Portuguese, which is the leak that matters.

Two traps this arrangement sets:

- **Never hand-build an internal path.** `"/components/#{name}"` silently sends a
  Portuguese reader into the English tree. Use the route helper
  (`docs_component_path`), which carries the locale.
- **Heading anchors differ per language**, since `docs_h2` derives the id from
  the heading text. A cross-page `#anchor` link must be written per locale.

The language switcher is two plain `<a>` links, not a dropdown or a JS toggle:
the CI crawl starts at the English root and finds `/pt` only because every page
links straight at its counterpart. The freeze step compares the two trees' page
counts and fails if the Portuguese one comes up short.

Registry components carry their user-facing strings as `I18n.t(..., default:)`
with English defaults, so an installed component needs no setup; the sandbox's
`pt.yml` defines the `ui.*` overrides, which is both what keeps the `/pt` demos
in Portuguese and a worked example for consuming apps.

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
  See `README.md` for the Theme Tokens table that documents what each token
  controls and where it is used.

### Icons

Icons use the **lucide-rails** gem (`lucide_icon` helper) — the Rails port of
Lucide, shadcn/ui's icon set. `Ui::IconComponent` / `ui_icon(name, ...)` wraps it
with shadcn-style size variants (`:sm`/`:default`/`:lg`/`:xl`) and is decorative
(`aria-hidden`) by default; pass `label:` to expose a meaningful icon. Icon names
are Lucide kebab-case (`"chevron-down"`). Compose icons into other components
(shadcn-style) instead of adding `icon:` props — `ButtonComponent` carries
`[&_svg]` utilities so a nested `ui_icon` is sized correctly, and `size: :icon`
gives an icon-only button.

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

## Project tracking

GitHub is this project's planner, not just a code remote. Anything that has to
outlive the conversation it came up in belongs in an **issue**: planned work not
yet started, technical debt, deferred decisions, open questions, and anything
needing input from outside the repo. Group related issues under a **milestone**
(a release, or a themed body of work).

**A deferral becomes an issue before the PR that defers it merges.** This is the
rule with teeth. "Known gaps", "out of scope for now" and "follow-up" recorded
only in a spec or a PR description are invisible the moment the thread closes —
`docs/superpowers/specs/` already carries lists of deferred items that nobody
greps. Specs and plans stay as the *rationale*; the issue is the *tracker*. If it
is worth writing down, it is worth a number that can be closed.

Label every issue with its area — `area:registry`, `area:cli`, `area:skills`,
`area:sandbox`, `area:ci`, `area:docs` — plus `bug` / `enhancement` /
`documentation`. PRs get the same `area:*` labels automatically from
`.github/labeler.yml`; keep that file in step when a new top-level directory
appears. Close issues from the PR that resolves them (`Closes #12`) so the
tracker maintains itself.
