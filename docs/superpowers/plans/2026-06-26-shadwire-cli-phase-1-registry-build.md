# Shadwire CLI Phase 1: Registry Build & Hosting

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Use superpowers:test-driven-development for the build/test work. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the registry publishable to a remote URL so a future CLI can fetch components over HTTP. Extend the registry schema with machine-actionable dependency metadata, add a build step that inlines file content into per-item JSON, and publish the built registry alongside the existing GitHub Pages deploy.

**Architecture:** `registry/registry.json` stays the source of truth (it keeps `source`→`target` file entries). A new `bin/build_registry` transforms it into a *published* format under `build/r/` where each item's files carry inlined `content` (no `source` paths) — the shape the CLI consumes. The published files are served from GitHub Pages at `https://edumoraes.github.io/shadwire/r/...`.

**Tech Stack:** Ruby 3.4 (stdlib only: `json`, `fileutils`, `pathname`), Minitest, GitHub Actions.

**Why this design:** The CLI was confirmed to use a **remote registry URL** (shadcn-style, inlined content). That requires a build step + hosting. The source `registry.json` format and its existing invariant tests (`test/registry_schema_test.rb`, `test/registry_manifest_test.rb`) must stay intact — the build produces a separate artifact.

---

**Phase Order:** Run this phase first. Continue with `2026-06-26-shadwire-cli-phase-2-gem-foundation.md` after Task 3 passes and is committed.

## File Structure

### Registry source
- Modify: `registry/registry.json`
  Add machine-actionable dependency metadata and optional descriptions (see Task 1).

### Build script
- Create: `bin/build_registry`
  Reads `registry/registry.json`, inlines each file's content, writes `build/r/{name}.json` + `build/r/index.json`.

### Tests
- Modify: `test/registry_schema_test.rb`
  Validate the new optional `gems` / `importmap` / `title` / `description` fields.
- Create: `test/registry_build_test.rb`
  Build into a tmp dir; assert valid JSON, non-empty `content` matching source, resolved transitive deps, and a `base` block in the index.
- Modify: `Rakefile`
  Run `test/registry_build_test.rb` in the default `test` task.

### CI / hosting
- Modify: `.github/workflows/ci.yml`
  Run `bin/build_registry` in the `test` job (drift/validity) and copy `build/r` into the Pages artifact in `deploy_pages`.

### Housekeeping
- Modify: `.gitignore`
  Ignore the generated `build/` directory at repo root.

---

## Task 1: Extend the registry schema

**Files:** `registry/registry.json`, `test/registry_schema_test.rb`

- [ ] **Step 1: Add explicit dependency keys**

Today base gems live in top-level `dependencies` (a hash: ruby/rails/view_component/lucide-rails) and `chart` carries `"dependencies": ["chart.js"]` — which is actually a JS importmap pin, not a gem. Make intent explicit:

- Add a top-level `gems` array for the base install: `["view_component", "lucide-rails"]`.
- Keep top-level `dependencies` (the ruby/rails/* floors) as an informational compatibility gate.
- On items, support optional `gems` (array of gem names → `bundle add`) and `importmap` (array of `{ "name", "to" }` CDN pins).
- Migrate `chart`: remove `"dependencies": ["chart.js"]`; add
  ```json
  "importmap": [{ "name": "chart.js/auto", "to": "https://cdn.jsdelivr.net/npm/chart.js@4.4.6/auto/+esm" }]
  ```
  This is the exact pin already in `sandbox/config/importmap.rb`.

- [ ] **Step 2: Add optional item descriptions**

Support optional `title` and `description` on items (consumed by `list`/`search`/`info`). Do **not** block on filling all 58 — absent values fall back to a humanized name at build time. Optionally fill a handful of common ones (button, card, dialog, chart, data-table).

- [ ] **Step 3: Extend the schema test**

In `test/registry_schema_test.rb` add assertions that, when present: `gems` is an array of non-empty strings; `importmap` is an array of `{ name, to }` objects with string values; `title`/`description` are strings. Keep all existing assertions passing (source-file invariants are unchanged).

- [ ] **Step 4: Verify**

```bash
ruby test/registry_schema_test.rb
ruby test/registry_manifest_test.rb
```
Both green.

- [ ] **Step 5: Commit** — `feat(registry): add gems/importmap/description metadata`

---

## Task 2: Write `bin/build_registry`

**Files:** `bin/build_registry`, `.gitignore`

- [ ] **Step 1: Implement the build script**

Mirror `bin/sync_registry` style (`Pathname`, `JSON`, frozen string literal, executable). For each item in `registry/registry.json`, emit `build/r/{name}.json`:

```json
{
  "name": "button",
  "type": "component",
  "title": "Button",
  "description": "…",
  "gems": [],
  "importmap": [],
  "registryDependencies": [],
  "files": [
    { "target": "app/components/ui/button_component.rb", "content": "…inlined…", "type": "component" }
  ]
}
```

- Inline each file's content by reading the `source` path from disk.
- `title`/`description` fall back to a humanized name when absent.
- Emit `build/r/index.json`:
  - `items`: catalog of `{ name, type, title, description }`.
  - `base`: the shared install consumed by `init` — the `ui_component.rb` + `ui_helper.rb` + `shadwire.css` files (with inlined content), the top-level `gems`, and `tailwind` (version + the css filename).
- Reuse the transitive `registryDependencies` walk from `bin/sync_registry` (`expand_with_dependencies`) — extract it into a small shared helper or copy it — so the published data is internally consistent.

- [ ] **Step 2: Ignore the build output**

Add `/build/` to root `.gitignore` (the artifact is regenerated in CI; not committed).

- [ ] **Step 3: Verify**

```bash
bin/build_registry
ls build/r | head
ruby -rjson -e 'puts JSON.parse(File.read("build/r/button.json"))["files"].first["content"][0,40]'
ruby -rjson -e 'j=JSON.parse(File.read("build/r/index.json")); puts j["items"].size; puts j["base"].keys.inspect'
```
Expect 58+ per-item files, an index with all items, and a `base` block.

- [ ] **Step 4: Commit** — `feat(registry): add bin/build_registry`

---

## Task 3: Test the build + wire into Rake and CI

**Files:** `test/registry_build_test.rb`, `Rakefile`, `.github/workflows/ci.yml`

- [ ] **Step 1: Write `test/registry_build_test.rb`**

Build into a `Dir.mktmpdir` (or shell out to `bin/build_registry` with an output-dir env/arg — add a `BUILD_DIR` env override to the script if cleaner). Assert:
- every item produces a parseable `{name}.json`;
- every file has non-empty `content` equal to the on-disk source;
- `registryDependencies` resolve (e.g. `data-table` pulls in `table`/`button`/`input`/`checkbox`/`dropdown-menu`);
- `index.json` has a `base` block whose files include `ui_component.rb`, `ui_helper.rb`, `shadwire.css`, and `gems` includes `view_component` + `lucide-rails`.

- [ ] **Step 2: Wire into Rake**

Add `ruby "test/registry_build_test.rb"` to the default `test` task in the root `Rakefile` (next to the existing two registry tests).

- [ ] **Step 3: Wire into CI**

In `.github/workflows/ci.yml`:
- In the `test` job, add a step `Registry build test` running `ruby test/registry_build_test.rb`.
- In `deploy_pages`, after asset precompile / before "Freeze the docs site", run `bin/build_registry`, and after the `_site` is assembled copy `build/r` into it: `cp -r build/r ../_site/r`. This serves the registry at `/shadwire/r/...`.

- [ ] **Step 4: Verify**

```bash
ruby test/registry_build_test.rb
rake test            # full suite still green (or run sandbox tests per CLAUDE.md)
```

- [ ] **Step 5: Commit** — `test(registry): cover build output + publish via Pages`

---

## Phase Verification

- `ruby test/registry_build_test.rb` passes.
- `bin/build_registry` produces `build/r/index.json` + one JSON per item with inlined content.
- `chart.json` carries the `chart.js/auto` importmap pin and no `dependencies` array.
- Existing `registry_sync`, schema, and manifest tests still pass (source format unchanged).
- CI `deploy_pages` publishes `build/r` to Pages (verify after merge to `main`: `https://edumoraes.github.io/shadwire/r/button.json` resolves).
