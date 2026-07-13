# Shadwire CLI Phase 2: Gem Foundation (client, resolver, installer)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Use superpowers:test-driven-development for every lib module. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the `shadwire` Ruby gem in `packages/cli/` and build the non-interactive core: a registry client that fetches per-item JSON, a dependency resolver, and a file installer. No user-facing commands yet — these are the pieces every command in Phase 3/4 composes.

**Architecture:** The gem is a Thor CLI. It reads a consuming app's `shadwire.json` config, fetches published registry JSON (HTTP, plus `file://` for tests/local builds — the Phase 1 `build/r/` output), resolves transitive `registryDependencies`, and writes files to their targets with the same safety checks `bin/sync_registry` enforces.

**Tech Stack:** Ruby 3.4, Thor (only runtime dep), stdlib `net/http` + `uri` + `json` + `fileutils` + `pathname`, Minitest.

**Why this design:** Confirmed decisions — Ruby gem (Thor), remote registry URL. Keeping deps to Thor alone keeps the gem light and installable in any Rails app. `file://` support lets tests and local development run fully offline against `bin/build_registry` output.

---

**Phase Order:** Requires Phase 1 (`build/r/` published format). Continue with `2026-06-26-shadwire-cli-phase-3-init-add.md` after Task 4 passes and is committed.

## File Structure

### Gem skeleton
- Create: `packages/cli/shadwire.gemspec` — name `shadwire`, executable `shadwire`, runtime dep `thor`, dev deps `minitest`/`rake`.
- Create: `packages/cli/Gemfile` — `gemspec` + dev group.
- Create: `packages/cli/Rakefile` — `rake test` runs Minitest.
- Create: `packages/cli/.gitignore` — `pkg/`, `Gemfile.lock` (gem convention), `tmp/`.
- Create: `packages/cli/exe/shadwire` — loads `shadwire` and invokes `Shadwire::CLI.start`.
- Create: `packages/cli/lib/shadwire.rb` — requires the lib tree.
- Create: `packages/cli/lib/shadwire/version.rb` — `VERSION = "0.1.0"`.
- Create: `packages/cli/lib/shadwire/cli.rb` — Thor subclass; subcommands are stubbed here, implemented in later phases.
- Replace: `packages/cli/.keep` is removed once real files exist.

### Core libs (this phase)
- Create: `packages/cli/lib/shadwire/errors.rb` — `Shadwire::Error` hierarchy (e.g. `RegistryError`, `ConfigError`, `ProjectError`).
- Create: `packages/cli/lib/shadwire/config.rb` — read/write `shadwire.json` in the target app; defaults; `installed` map.
- Create: `packages/cli/lib/shadwire/registry_client.rb` — fetch `index.json` and `{name}.json` from the registry base (HTTP + `file://`), with a small in-process cache.
- Create: `packages/cli/lib/shadwire/resolver.rb` — port of `expand_with_dependencies` (transitive `registryDependencies`).
- Create: `packages/cli/lib/shadwire/installer.rb` — write files to targets; overwrite policy; safety checks (port `inside_directory?` + conflicting-target check from `bin/sync_registry`).

### Tests + fixtures
- Create: `packages/cli/test/test_helper.rb`
- Create: `packages/cli/test/fixtures/registry/` — a small built registry (`index.json` + a couple item JSONs) for `file://` tests.
- Create: `packages/cli/test/registry_client_test.rb`
- Create: `packages/cli/test/resolver_test.rb`
- Create: `packages/cli/test/installer_test.rb`
- Create: `packages/cli/test/config_test.rb`

---

## Task 1: Gem skeleton

**Files:** gemspec, Gemfile, Rakefile, exe, `lib/shadwire.rb`, `lib/shadwire/version.rb`, `lib/shadwire/cli.rb`

- [ ] **Step 1: Create the gemspec + Bundler files**

`shadwire.gemspec`: summary, homepage `https://github.com/edumoraes/shadwire`, license MIT, `spec.files` from the `lib`/`exe` dirs, `spec.executables = ["shadwire"]`, `spec.bindir = "exe"`, `add_dependency "thor"`, `required_ruby_version >= 3.2` (match the registry floor). `Gemfile` references `gemspec` and adds `minitest`, `rake`. `Rakefile` defines a Minitest `test` task.

- [ ] **Step 2: Create the entrypoint**

`exe/shadwire` (executable): `#!/usr/bin/env ruby`, `require "shadwire"`, `Shadwire::CLI.start(ARGV)`. `lib/shadwire.rb` requires version, errors, config, registry_client, resolver, installer, cli. `lib/shadwire/cli.rb` is a `Thor` subclass with `package_name "shadwire"`; command methods are added in later phases (stub a `version` command now).

- [ ] **Step 3: Verify**

```bash
cd packages/cli && bundle install && bundle exec exe/shadwire version
```
Prints the version. `bundle exec rake test` runs (0 tests OK).

- [ ] **Step 4: Commit** — `feat(cli): scaffold shadwire gem`

---

## Task 2: Config (`shadwire.json`)

**Files:** `lib/shadwire/config.rb`, `test/config_test.rb`

- [ ] **Step 1: Write the test first**

A `Config` loads/initializes from an app root: default `registry` URL `https://edumoraes.github.io/shadwire/r`, default `tailwind.css` `app/assets/tailwind/application.css`, default `aliases` (components/ui/helpers/controllers/vendorCss), empty `installed`. Round-trips to/from `shadwire.json`. `installed` records `name → { version, files: [...] }`.

- [ ] **Step 2: Implement `Config`**

`Config.load(root)` reads `shadwire.json` if present else returns defaults; `#save` writes pretty JSON; accessors for `registry`, `tailwind_css`, `aliases`, `installed`; `#record_installed(name, version, files)` and `#forget(name)`.

- [ ] **Step 3: Verify** — `bundle exec rake test` green for config.

- [ ] **Step 4: Commit** — `feat(cli): shadwire.json config`

---

## Task 3: Registry client + resolver

**Files:** `lib/shadwire/registry_client.rb`, `lib/shadwire/resolver.rb`, fixtures, `test/registry_client_test.rb`, `test/resolver_test.rb`

- [ ] **Step 1: Build the test fixture registry**

Under `test/fixtures/registry/` create `index.json` (a few items incl. one with `registryDependencies`) and matching `{name}.json` files with tiny inlined `content`. Tests point the client at `file://#{fixtures}/registry`.

- [ ] **Step 2: Write tests first**

`RegistryClient.new(base_url)`:
- `#index` returns the parsed `index.json`;
- `#item(name)` returns the parsed `{name}.json`, raising `RegistryError` on 404/missing;
- supports both `http(s)://` (via `Net::HTTP`) and `file://` (read from disk);
- caches within an instance.

`Resolver.expand(names, client)` returns items in dependency-first order, de-duplicated, pulling transitive `registryDependencies` (port `expand_with_dependencies` from `bin/sync_registry`; unknown deps raise rather than warn — the CLI surfaces a clear error).

- [ ] **Step 3: Implement both**

- [ ] **Step 4: Verify** — `bundle exec rake test` green.

- [ ] **Step 5: Commit** — `feat(cli): registry client + dependency resolver`

---

## Task 4: Installer

**Files:** `lib/shadwire/installer.rb`, `test/installer_test.rb`

- [ ] **Step 1: Write the test first**

Given a resolved item's `files[]` (target + content) and a target app root + an overwrite policy, the installer:
- writes each file to `root/target`, creating parent dirs;
- refuses targets that escape the app root (port `inside_directory?`);
- refuses two files mapping to the same target with different content (port the conflicting-target check);
- overwrite policy: `:prompt` (callback returns yes/no), `:always`, `:never` (skip + report);
- returns a report of written/skipped files.

Use a `Dir.mktmpdir` app root.

- [ ] **Step 2: Implement `Installer`**

Keep prompting out of this class — it takes an `overwrite:` policy and an optional `confirm:` callable, so commands own the UI and tests stay deterministic.

- [ ] **Step 3: Verify** — `bundle exec rake test` green; cover the escape-path and conflict cases.

- [ ] **Step 4: Commit** — `feat(cli): file installer with safety checks`

---

## Phase Verification

- `cd packages/cli && bundle exec rake test` is green.
- `bundle exec exe/shadwire version` works.
- The client resolves a transitive dependency against the `file://` fixture; the installer writes files into a tmp root and rejects unsafe/conflicting targets.
- No user-facing `init`/`add` yet — those are Phase 3.
