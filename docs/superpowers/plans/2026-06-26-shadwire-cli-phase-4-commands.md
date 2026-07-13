# Shadwire CLI Phase 4: `list` / `info` / `search` / `diff` / `update` / `remove`

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Use superpowers:test-driven-development. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the command surface: catalog browsing (`list`, `search`, `info`), the "Open Code" drift workflow (`diff`, `update`), and clean removal (`remove`). Read commands support `--json` so agents can consume output mechanically.

**Architecture:** All commands reuse Phase 2/3 libs. `diff`/`update`/`remove` rely on the `installed` map written into `shadwire.json` by `add`, comparing local files against freshly fetched registry `content`.

**Tech Stack:** Ruby 3.4, Thor, stdlib (`json`; a minimal unified-diff via a tiny helper or comparing line arrays — avoid adding a diff gem), Minitest.

**Why this design:** Confirmed the full command surface. The Open Code model means users own and edit installed files; `diff` surfaces drift and `update` re-applies upstream with the local changes shown first. `remove` must never delete shared base files or files still used by another installed item.

---

**Phase Order:** Requires Phase 3. Continue with `2026-06-26-shadwire-cli-phase-5-ci-docs.md` after Task 4 passes and is committed.

## File Structure

### Commands
- Create: `packages/cli/lib/shadwire/commands/list.rb`
- Create: `packages/cli/lib/shadwire/commands/info.rb`
- Create: `packages/cli/lib/shadwire/commands/search.rb`
- Create: `packages/cli/lib/shadwire/commands/diff.rb`
- Create: `packages/cli/lib/shadwire/commands/update.rb`
- Create: `packages/cli/lib/shadwire/commands/remove.rb`
- Modify: `packages/cli/lib/shadwire/cli.rb` — register the six commands.

### Support
- Create: `packages/cli/lib/shadwire/differ.rb` — minimal unified-diff between two strings (or a per-file changed/unchanged summary for `--json`).

### Tests
- Create: `packages/cli/test/list_test.rb`
- Create: `packages/cli/test/info_test.rb`
- Create: `packages/cli/test/search_test.rb`
- Create: `packages/cli/test/diff_test.rb`
- Create: `packages/cli/test/update_test.rb`
- Create: `packages/cli/test/remove_test.rb`

---

## Task 1: `list` / `search` / `info`

**Files:** `commands/list.rb`, `commands/search.rb`, `commands/info.rb`, `cli.rb`, tests

- [ ] **Step 1: Write tests first (file:// registry)**

- `list`: prints all catalog items (name + title) from `index.json`; `--json` emits the catalog array.
- `search QUERY`: filters by name/title/description (case-insensitive); `--json` emits matches.
- `info NAME`: prints type, title, description, files (targets), gems, importmap pins, registryDependencies; `--json` emits the full item metadata (without file `content`).

- [ ] **Step 2: Implement**

These are read-only and need no app/config (only a registry); accept `--registry` and `--cwd` (to read a project's configured registry when present). Keep `--json` output stable and minimal.

- [ ] **Step 3: Verify, commit** — `feat(cli): list/search/info commands`

---

## Task 2: `diff`

**Files:** `lib/shadwire/differ.rb`, `commands/diff.rb`, `cli.rb`, `test/diff_test.rb`

- [ ] **Step 1: Write the test first**

After `add button`, modifying the installed `button_component.rb` and running `diff button` reports it as changed and shows the difference; an unmodified install reports no drift. `diff` with no NAME checks every item in `Config#installed`. `--json` returns `[{ name, file, status }]` where status ∈ `unchanged|modified|missing`.

- [ ] **Step 2: Implement `differ` + `diff`**

`differ` does a small line-based unified diff (stdlib only). `diff` fetches each installed item, compares local file bytes to registry `content`, prints human diffs or a `--json` summary. Exit non-zero when drift is found only if `--exit-code` is passed (so it composes in CI without breaking normal use).

- [ ] **Step 3: Verify, commit** — `feat(cli): diff command for drift detection`

---

## Task 3: `update`

**Files:** `commands/update.rb`, `cli.rb`, `test/update_test.rb`

- [ ] **Step 1: Write the test first**

`update button`: re-fetches and, when the registry content differs from local, shows the diff and (on confirm / `--yes`) overwrites; updates the recorded version in `Config#installed`. Local-only edits are surfaced before overwrite (no silent clobber). `--overwrite`/`--yes` skip the prompt.

- [ ] **Step 2: Implement**

Reuse `Resolver` (so an item's deps update too, unless `--no-deps`), `Differ` (show changes), `Installer` (overwrite policy), `Dependencies` (re-ensure gems/pins). Update `installed`.

- [ ] **Step 3: Verify, commit** — `feat(cli): update command`

---

## Task 4: `remove`

**Files:** `commands/remove.rb`, `cli.rb`, `test/remove_test.rb`

- [ ] **Step 1: Write the test first**

After installing `button` and `card`, `remove button`:
- deletes `button`'s **own** files only;
- never deletes the shared base (`ui_component.rb`, `ui_helper.rb`, `shadwire.css`) or any file still listed by another entry in `Config#installed`;
- removes `button` from `installed`;
- prompts before deleting unless `--yes`.
Removing the last component that pinned `chart.js` should *report* the now-unused importmap pin but not auto-edit importmap.rb (leave dep cleanup to the user — safer).

- [ ] **Step 2: Implement**

Compute the set of files unique to the removed item (target set minus the union of all other installed items' targets, minus the base file set). Delete only those; prune empty dirs under the components root. Confirm-then-apply; `--yes` to skip.

- [ ] **Step 3: Verify, commit** — `feat(cli): remove command`

---

## Phase Verification

- `cd packages/cli && bundle exec rake test` green across all command tests.
- Against a tmp app + `file://` registry: `list`/`search`/`info` (incl. `--json`) work without a project; `add` → edit a file → `diff` shows drift → `update --yes` restores → `remove --yes` deletes only the item's own files and keeps the shared base.
- Every read command emits stable `--json`; every mutating command honors `--yes`.
