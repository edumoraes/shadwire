# Shadwire CLI Phase 3: `init` + `add` + Dependency Manager

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Use superpowers:test-driven-development. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the core install loop end to end: `shadwire init` bootstraps a Rails app (config + base files + base deps + Tailwind import), and `shadwire add NAME...` installs components with their transitive registry dependencies and their gems/importmap pins. Dependency changes use **confirm-then-apply** with a `--yes` escape hatch for agents/CI.

**Architecture:** Commands compose the Phase 2 libs (`Config`, `RegistryClient`, `Resolver`, `Installer`) plus two new ones: `Project` (detect the Rails app + stack) and `Dependencies` (gems via `bundle add`, importmap pins, Tailwind `@import` — each detect → plan → apply on confirm). Targets are canonical Rails paths from the registry; `Config#aliases` allow remapping roots.

**Tech Stack:** Ruby 3.4, Thor (prompts via `yes?`/`say`), stdlib, Minitest. Target stack mirrors the sandbox: `importmap-rails` + `tailwindcss-rails` + `stimulus-rails` (no Node).

**Why this design:** Confirmed decisions — confirm-then-apply dependency handling, agent-drivable via `--yes`/`--cwd`. The sandbox proves a Rails consumer has no Node, so Stimulus controllers install as plain `*_controller.js` files auto-registered by `eagerLoadControllersFrom` + `pin_all_from`; only `chart.js` needs an explicit CDN pin.

---

**Phase Order:** Requires Phase 2. Continue with `2026-06-26-shadwire-cli-phase-4-commands.md` after Task 4 passes and is committed.

## File Structure

### New libs
- Create: `packages/cli/lib/shadwire/project.rb`
  Detect the Rails app root, parse `Gemfile`/`Gemfile.lock`, find `config/importmap.rb`, the Tailwind css entry, and Stimulus setup; expose booleans (`importmap?`, `tailwindcss_rails?`, `stimulus?`).
- Create: `packages/cli/lib/shadwire/dependencies.rb`
  `gems` (`bundle add`), `importmap` (append `pin` lines), Tailwind `@import` — each: detect missing → describe → apply on confirm. Falls back to printed instructions on an unsupported stack.
- Create: `packages/cli/lib/shadwire/ui.rb` (optional)
  Thin shell-IO wrapper (say/warn/confirm/`--yes`/`--json` aware) so commands stay terminal/agent friendly and tests can capture output.

### Commands
- Create: `packages/cli/lib/shadwire/commands/init.rb`
- Create: `packages/cli/lib/shadwire/commands/add.rb`
- Modify: `packages/cli/lib/shadwire/cli.rb`
  Register `init` and `add` with shared options (`--yes`, `--cwd`, `--registry`).

### Tests + fixtures
- Create: `packages/cli/test/fixtures/app/` — a minimal fake Rails app (Gemfile, `config/importmap.rb`, `app/assets/tailwind/application.css`, `app/javascript/controllers/index.js`) used as a copy-into-tmp target.
- Create: `packages/cli/test/project_test.rb`
- Create: `packages/cli/test/dependencies_test.rb`
- Create: `packages/cli/test/init_test.rb`
- Create: `packages/cli/test/add_test.rb`

---

## Task 1: Project detection

**Files:** `lib/shadwire/project.rb`, `test/fixtures/app/`, `test/project_test.rb`

- [ ] **Step 1: Build the fake-app fixture**

A minimal directory resembling a Rails 8 importmap app: `Gemfile` (with `rails`, `importmap-rails`, `tailwindcss-rails`, `stimulus-rails`), `Gemfile.lock` (or skip and parse Gemfile), `config/importmap.rb` (with `pin_all_from "app/javascript/controllers"`), `app/assets/tailwind/application.css` (`@import "tailwindcss";`), `app/javascript/controllers/index.js`. Tests copy it into a `Dir.mktmpdir` before mutating.

- [ ] **Step 2: Write tests first**

`Project.new(root)`: `#rails?`, `#importmap?`, `#tailwindcss_rails?`, `#stimulus?`, `#gem?(name)` (reads Gemfile.lock then Gemfile), `#importmap_path`, `#tailwind_css_path` (from config or default), `#raise_unless_rails!`.

- [ ] **Step 3: Implement, verify, commit** — `feat(cli): rails project detection`

---

## Task 2: Dependency manager (confirm-then-apply)

**Files:** `lib/shadwire/dependencies.rb`, `test/dependencies_test.rb`

- [ ] **Step 1: Write tests first (against a tmp copy of the fixture app)**

- `ensure_gems(["lucide-rails"], yes:)`: if absent from Gemfile.lock/Gemfile, plan a `bundle add lucide-rails`; with `yes: true` run it (stub the shell call in tests — assert the command line), skip if already present.
- `ensure_importmap_pins([{name:, to:}], yes:)`: if `config/importmap.rb` lacks the pin, append `pin "<name>", to: "<to>"`; idempotent.
- `ensure_tailwind_import(vendor_css_target, yes:)`: in the Tailwind css entry, ensure `@import "<relative>/vendor/shadwire/shadwire.css";` appears after `@import "tailwindcss";`. Compute the relative path from the css file to the vendor css target (sandbox value: `../../../vendor/shadwire/shadwire.css`). Idempotent.
- Unsupported stack (no importmap / no tailwindcss-rails): return a list of manual instructions instead of mutating; commands print them.

- [ ] **Step 2: Implement**

Run `bundle add` via `Bundler.with_unbundled_env { system(...) }` in the app root so it targets the consuming app, not the gem. Keep all prompts in the caller — `Dependencies` takes a `yes:` flag and returns a plan; the command decides to prompt or auto-apply.

- [ ] **Step 3: Verify, commit** — `feat(cli): dependency manager (gems, importmap, tailwind)`

---

## Task 3: `shadwire init`

**Files:** `lib/shadwire/commands/init.rb`, `lib/shadwire/cli.rb`, `test/init_test.rb`

- [ ] **Step 1: Write the test first**

Running `init` in a tmp app (registry via `--registry file://…fixtures/registry`):
- writes `shadwire.json` with the registry URL + defaults;
- installs the `base` files from `index.json` (`app/components/ui_component.rb`, `app/helpers/ui_helper.rb`, `vendor/shadwire/shadwire.css`);
- plans base gems (`view_component`, `lucide-rails`) and the Tailwind `@import`;
- with `--yes`, applies them non-interactively;
- warns (does not crash) when importmap/stimulus/tailwindcss-rails are missing.

- [ ] **Step 2: Implement `init`**

Detect via `Project` (raise a clear error if not a Rails app). Fetch `index.json#base`. Install base files via `Installer`. Drive `Dependencies` for base gems + Tailwind import. Verify Stimulus/importmap and print guidance if absent. Write `Config`. Idempotent on re-run.

Options: `--yes`, `--cwd`, `--registry`, `--force` (rewrite existing `shadwire.json`).

- [ ] **Step 3: Verify, commit** — `feat(cli): init command`

---

## Task 4: `shadwire add`

**Files:** `lib/shadwire/commands/add.rb`, `lib/shadwire/cli.rb`, `test/add_test.rb`

- [ ] **Step 1: Write the test first**

After `init`, `add button` (file:// registry):
- writes `app/components/ui/button_component.rb` (+ shared base, skipped if identical);
- records `button` in `Config#installed`.

`add data-table --yes` pulls transitive deps (`table`, `button`, `input`, `checkbox`, `dropdown-menu`) and installs all their files + any gems/pins. `add chart --yes` adds the `chart.js/auto` importmap pin. Overwrite of a locally-modified file prompts unless `--overwrite` (or `--yes`).

- [ ] **Step 2: Implement `add`**

Resolve names via `Resolver` → fetch each item → collect files, gems, importmap pins → `Installer.install` (overwrite policy from flags, prompt via the UI wrapper) → `Dependencies.ensure_*` for the union of gems/pins → `Config#record_installed`. Print a concise summary (file list + applied deps).

Options: `--yes`, `--overwrite`, `--no-deps`, `--cwd`, `--registry`.

- [ ] **Step 3: Verify, commit** — `feat(cli): add command with transitive deps`

---

## Phase Verification

- `cd packages/cli && bundle exec rake test` green.
- In a tmp copy of the fixture app: `exe/shadwire init --yes --registry file://$PWD/test/fixtures/registry` writes config + base; `exe/shadwire add button --yes …` writes the component and records it; a multi-dep item installs its whole tree.
- `--yes` runs the full loop with zero prompts (agent path).
- Real end-to-end against the sandbox is exercised in Phase 5.
