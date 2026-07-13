# Shadwire CLI Phase 5: CI, End-to-End Verification & Docs

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Use superpowers:verification-before-completion before claiming done. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the gem into CI, prove the whole flow works against a real Rails app (the sandbox or a fresh `rails new`), and document the CLI so humans and agents can use it. After this phase the CLI is no longer "deferred".

**Architecture:** Adds a `cli` CI job (gem tests). Real end-to-end verification builds the registry locally and runs the actual `shadwire` binary against a throwaway Rails app, confirming files land at the right targets and components render. Docs are updated across `README.md`, `CLAUDE.md`, and the design spec.

**Tech Stack:** GitHub Actions, Ruby 3.4, the sandbox Rails stack (importmap + tailwindcss-rails + stimulus), Minitest.

**Why this design:** Confirmed full surface + agent usage. CI keeps the gem honest; the end-to-end run is the real proof per superpowers:verification-before-completion (tests alone don't prove a real Rails app renders installed components).

---

**Phase Order:** Final phase. Requires Phases 1–4 merged.

## File Structure

### CI
- Modify: `.github/workflows/ci.yml`
  Add a `cli` job that installs the gem's deps and runs its tests.

### Docs
- Modify: `README.md` — a "CLI" section (install, `init`, `add`, `list`, agent usage with `--yes`/`--json`).
- Modify: `CLAUDE.md` — the CLI is implemented; document `packages/cli/` layout, the build step, and the registry-build/host workflow; note `bin/build_registry`.
- Modify: `docs/superpowers/specs/2026-05-21-shadwire-mvp-design.md` — update "Future Phases" to reflect the CLI shipped; cross-reference these phase plans.
- Create: `packages/cli/README.md` — gem-level usage + command reference (also the gem's `homepage`/rubygems description source).

---

## Task 1: CI job for the gem

**Files:** `.github/workflows/ci.yml`

- [ ] **Step 1: Add the `cli` job**

```yaml
  cli:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v7
      - uses: ruby/setup-ruby@v1
        with:
          working-directory: packages/cli
          ruby-version: .ruby-version   # add packages/cli/.ruby-version, or set "3.4"
          bundler-cache: true
      - name: CLI tests
        working-directory: packages/cli
        run: bundle exec rake test
```

Keep `PARALLEL_WORKERS` concerns out (the gem tests are serial Minitest). If `deploy_pages` should gate on the CLI, add `cli` to its `needs:`.

- [ ] **Step 2: Verify** — push a branch; the `cli` job passes. Locally: `cd packages/cli && bundle exec rake test`.

- [ ] **Step 3: Commit** — `ci: run shadwire CLI tests`

---

## Task 2: Real end-to-end against a Rails app

**Files:** none committed (a scratch verification run); capture results in the PR description.

- [ ] **Step 1: Build + serve the registry locally**

```bash
bin/build_registry          # produces build/r/
```
Use `--registry file://$PWD/build/r` so no network/host is needed.

- [ ] **Step 2: Run the CLI against a throwaway app**

Either copy `sandbox/` to a tmp dir, or `rails new` a fresh importmap+tailwind app. Then:

```bash
cd /tmp/shadwire-e2e
ruby -I /path/to/packages/cli/lib /path/to/packages/cli/exe/shadwire init --yes \
  --registry file:///path/to/repo/build/r
… add button dialog chart --yes --registry file:///path/to/repo/build/r
```

Confirm:
- files land at `app/components/ui/...`, `app/javascript/controllers/ui_dialog_controller.js`, `vendor/shadwire/shadwire.css`;
- `bundle add lucide-rails` ran (Gemfile updated);
- the `chart.js/auto` importmap pin and the Tailwind `@import` were added;
- `bin/rails test test/components` (in the copied sandbox) and `bin/dev` render the installed components.

- [ ] **Step 3: Exercise the drift + removal loop**

Edit an installed file → `shadwire diff` shows it → `shadwire update button --yes` restores → `shadwire remove dialog --yes` removes only dialog's files. Re-run `add … --yes --json` and confirm clean non-interactive JSON + exit 0 (agent path).

- [ ] **Step 4: Record results** in the PR (commands + key output). Per superpowers:verification-before-completion, paste real output — do not assert success without it.

---

## Task 3: Documentation

**Files:** `README.md`, `packages/cli/README.md`, `CLAUDE.md`, `docs/superpowers/specs/2026-05-21-shadwire-mvp-design.md`

- [ ] **Step 1: Top-level README** — add a CLI section: install (`gem install shadwire` / `bundle add shadwire --group development`), `init`, `add NAME`, `list`, and an "Agents/CI" note (`--yes`, `--json`, `--cwd`).

- [ ] **Step 2: `packages/cli/README.md`** — full command reference + flags + the `shadwire.json` schema + how the remote registry resolves.

- [ ] **Step 3: CLAUDE.md** — under Commands/Architecture: document `bin/build_registry`, the `build/r` published format, the Pages hosting, and `packages/cli/` (no longer "reserved placeholder"). Note the registry-build workflow alongside the existing `bin/sync_registry` rule.

- [ ] **Step 4: Design spec** — update "Future Phases": mark the CLI as delivered; link these five phase plans.

- [ ] **Step 5: Commit** — `docs: document the shadwire CLI`

---

## Phase Verification

- CI is green including the new `cli` job; existing jobs (`lint`, `test`, `registry_sync`, `deploy_pages`) still pass.
- The real end-to-end run (Task 2) is captured with actual output: a fresh Rails app went from zero to rendering `button`, `dialog`, and `chart` via the CLI, with deps installed.
- `https://edumoraes.github.io/shadwire/r/button.json` resolves after merge to `main` (Pages publish from Phase 1).
- Docs describe install + agent usage; `packages/cli/` is documented as implemented.

## Follow-ups (out of scope — note, do not build)

- MCP wrapper around the CLI (the `--yes`/`--json` surface already makes it agent-drivable).
- Custom/third-party namespaced registries (`registries` map in `shadwire.json`).
- A hosted JSON Schema at `shadwire.dev` for `shadwire.json` and the registry-item format.
