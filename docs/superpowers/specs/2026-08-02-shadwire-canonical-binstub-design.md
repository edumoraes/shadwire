# Canonical CLI Entry Point — `bin/shadwire` — Design

Date: 2026-08-02
Status: approved (pending implementation plan)

## Context

A user installed the `shadwire` agent skill into a Rails app and its agent
reported that the skill's `allowed-tools` did not cover how that project invokes
the CLI: the app runs `bin/shadwire`, while the frontmatter declares only
`Bash(shadwire *)` and `Bash(bundle exec shadwire *)`. Investigating the report
found the permission gap is the smallest of three problems, and that all three
share one root cause: **the CLI has no canonical invocation, so the skill
hardcodes guesses about how to reach it.**

What the investigation established:

1. **`allowed-tools` is a pre-approval, not a restriction, and it lasts one
   turn.** The Claude Code frontmatter reference states it grants "tools Claude
   can use without asking permission during the turn that invokes this skill.
   The grant clears when you send your next message," and that "to pre-approve
   tools for the whole session rather than a single turn, add allow rules to
   those permission settings instead." So adding a pattern to the frontmatter
   never eliminates the prompts on its own — it only covers the invoking turn.
2. **The context injection at `skills/shadwire/SKILL.md:23` hardcodes bare
   `shadwire`.** The `` !`command` `` syntax is documented as preprocessing —
   "this is preprocessing, not something Claude executes" — gated only by the
   `disableSkillShellExecution` setting, never by `allowed-tools`. In an app
   whose only entry point is `bin/shadwire`, that command does not resolve, the
   block comes back empty, and `SKILL.md:35` then instructs the agent to report
   that the CLI is not installed. A false negative on the first thing the skill
   does, which no permission change can fix.
3. **The prose steers away from the binstub.** `SKILL.md:17-18` and
   `skills/shadwire/cli.md:3-4` teach `shadwire` and `bundle exec shadwire` and
   check the Gemfile. `grep -rn "bin/shadwire"` across the repo returns nothing:
   the CLI has never generated one, and no document mentions one.

Rails apps overwhelmingly reach development tooling through `bin/*`. Rails 8
ships `bin/rails`, `bin/rubocop`, `bin/brakeman`, `bin/dev`, `bin/setup`,
`bin/ci`, and `bin/jobs` out of the box, and this repo's own `README.md:101`
recommends `bundle add shadwire --group development` — precisely the setup where
a developer's next move is `bundle binstubs shadwire`.

This design makes `bin/shadwire` the one way to invoke the CLI in a consuming
app, has `shadwire init` create it, and rewrites the skill and docs around that
single path.

## Goals

- One documented, permission-granted, agent-visible way to run the CLI in a
  consuming app.
- `shadwire status --json` reports whether that path exists, so the skill can
  carry procedure instead of a hardcoded invocation.
- The skill's context injection returns real data in every app state, including
  apps initialized before this change.

## Non-goals

- Adding the `shadwire` gem to `registry/registry.json`. The registry's `gems`
  are what the *components* need at runtime; installed files carry no Shadwire
  dependency, which is the core promise in `CLAUDE.md`.
- Generating the binstub from `add` or `update`. `init` is the bootstrap.
- Writing `.claude/settings.json` into a consuming app. The CLI does not manage
  another tool's agent configuration; the durable allow rule is documented.
- Retiring the global `gem install shadwire` path. It remains a valid bootstrap;
  it simply now terminates at the same canonical entry point.

## Guiding principle

Carried over from the 2026-07-27 skill design: **the skill contains no data that
can drift.** Today the skill hardcodes two invocation strings and picks between
them by inspecting the Gemfile — copied facts, free to rot. After this change the
skill names one form, and `status` reports whether it exists. Procedure in the
prose, data from the CLI.

---

## 1. `Shadwire::Binstub`

A new unit at `packages/cli/lib/shadwire/binstub.rb` whose single purpose is
knowing the binstub's path, contents, and mode.

```ruby
PATH = "bin/shadwire"

TEMPLATE = <<~RUBY
  #!/usr/bin/env ruby
  # frozen_string_literal: true
  require "rubygems"
  require "bundler/setup"
  load Gem.bin_path("shadwire", "shadwire")
RUBY

def self.write(root, force: false) # => { written: Boolean, skipped: Boolean }
```

The template is byte-for-byte the shape Rails 8 generates for `bin/rubocop` and
`bin/brakeman`, so it reads as native to the app it lands in.

`write` creates `bin/` when absent, writes the file, and chmods it `0755`. It
writes only when the target is absent, or when `force:` is true.

**Why not `Installer`.** `Shadwire::Installer` writes *published registry file
entries* — `{"target" =>, "content" =>}` hashes, with the escape-path and
conflict validation that mirrors `bin/sync_registry`. The binstub is neither
registry content nor tracked in `shadwire.json`, and `installer.rb:44` writes
with `path.write`, which never sets an execute bit. Routing the binstub through
it would be a category error that also produces a non-executable file.

## 2. `Project#binstub?`

```ruby
def binstub?
  File.exist?(path(Binstub::PATH))
end
```

`Project` is documented as detecting the app "by inspecting the Gemfile /
Gemfile.lock and a few conventional files" (`project.rb:6-7`), which is exactly
this. `Binstub` owns the path constant; `Project` asks.

## 3. `Dependencies#ensure_gems(..., group: nil)`

`ensure_gems` currently runs `bundle add <missing...>` with no group
(`dependencies.rb:60`). It gains an optional `group:` keyword that appends
`--group <group>` when present. Additive — existing call sites are unchanged.

## 4. `Commands::Init`

Between the existing gem/Tailwind step and `config.save`, `init` gains:

1. **Ensure `shadwire` itself, in the `development` group.** Separate from the
   registry's `base["gems"]`, for the reason under Non-goals. It flows through
   the same `Dependencies#ensure_gems` machinery, so it inherits the existing
   confirm-then-apply behaviour and the `--yes` path.
2. **Gate the binstub on the `ensure_gems` result, then write it.** The gem
   counts as present when `shadwire` comes back under `applied` (the `bundle
   add` succeeded) or `skipped` (it was already declared). Under `pending` (the
   user declined the confirm) or `failed`, the binstub is skipped and reported
   as a manual instruction rather than shipped broken. This ordering is
   load-bearing: a bundler binstub written while the gem is absent from the
   Gemfile raises `Gem::LoadError` on first run.

   The gate reads the result rather than re-reading the Gemfile. The two agree
   in all four cases, but the result is a direct record of what the command did,
   where a re-read depends on `bundle add` having written a line the
   `Project#gem?` regex recognizes. It is also what makes this testable: the CLI
   suite injects a `runner` that records invocations without touching the
   filesystem (`test/init_test.rb:24`, `test/status_test.rb:17`), so a Gemfile
   re-read would report the gem absent in every existing test and no binstub
   would ever be written under test.
3. **`--force` rewrites an existing binstub.** `--force` today resets
   `shadwire.json` (`init.rb:56`); extending it to re-lay the bootstrap file is
   a coherent reading of the same flag. Without it, an existing `bin/shadwire`
   is left untouched and reported as skipped.

Respecting an existing file matters because `bundle binstubs shadwire` produces
a longer, Bundler-generated binstub that works correctly. Overwriting it would
destroy a working file that `shadwire diff` does not track and therefore cannot
report.

Reporting, following `print_summary`'s existing vocabulary (`init.rb:88`):

```console
$ shadwire init --yes
Initialized shadwire (2 base files).
  create  app/components/ui_component.rb
  create  bin/shadwire
  gem     shadwire

$ shadwire init --yes
  skip    bin/shadwire (already exists)

$ shadwire init --yes --force
  create  bin/shadwire (overwritten)
```

`init --json` gains a `binstub` key alongside the existing `created` / `gems` /
`tailwind` keys:

```json
"binstub": { "path": "bin/shadwire", "written": true, "skipped": false }
```

### Error handling

`Dependencies.raise_on_failure!` already exits `init` non-zero when a
`bundle add` fails (`init.rb:41`). With `shadwire` among the ensured gems, a
failed `bundle add shadwire` now fails `init` — correct, because the binstub
depends on that gem being in the bundle, and the existing message already tells
the user how to recover.

## 5. `Commands::Status`

`context` (`status.rb:47`) gains a block alongside `gems`:

```ruby
"cli" => {
  "gem" => project.gem?("shadwire"),
  "binstub" => project.binstub?
}
```

This is the data that replaces the skill's hardcoded invocation. The
non-`--json` rendering gains a corresponding line.

The `status` contract is unchanged and still holds: valid JSON, exit 0, in every
app state (design doc 2026-07-27 §3).

---

## 6. The skill

### Frontmatter (`SKILL.md:5`)

```yaml
allowed-tools: Bash(bin/shadwire *), Bash(./bin/shadwire *), Bash(bundle exec shadwire *), Bash(shadwire *)
```

The prose becomes canonical; the permission list cannot. An agent in an app
without a binstub needs `shadwire init` or `bundle exec shadwire init` to create
one, and those calls must not prompt. Both binstub spellings are listed because
a Bash wildcard does not cross the `./` prefix — `Bash(bin/shadwire *)` matches
`bin/shadwire status` but not `./bin/shadwire status`.

The space before `*` is deliberate and correct: it enforces a word boundary, so
`Bash(shadwire *)` matches `shadwire status` and bare `shadwire`, but not
`shadwirefoo`.

These patterns grant every subcommand, `update` included, which overwrites local
edits. That is bounded by procedure rather than permission: Critical Rule 7 and
the "Editing installed components" section already require `diff` before
`update`. The alternative — enumerating safe subcommands — would put a list of
CLI commands in the frontmatter, which is exactly the kind of copied data the
guiding principle forbids.

### Context injection (`SKILL.md:23`)

The injection is a static string that must return usable data in every app,
including apps initialized before this change. It chains on exit code:

````markdown
```!
bin/shadwire status --json 2>/dev/null \
  || bundle exec shadwire status --json 2>/dev/null \
  || shadwire status --json 2>/dev/null \
  || echo '{"rails":false,"cliMissing":true}'
```
````

This leans on the `status` contract: because `status` emits valid JSON and exits
0 whenever it runs at all, a non-zero exit means precisely "this invocation form
does not exist here." Ordered most-correct-first — the binstub is pinned to the
app's bundle, `bundle exec` resolves the app's version, and a global gem may be
a different version than the app expects.

The final `echo` guarantees the block is always parseable JSON, so the skill's
"is the CLI reachable" branch reads a field instead of pattern-matching an error.

The chain costs one wasted Bundler startup — roughly a second — in an app that
has the gem globally but not in its Gemfile, since `bundle exec` must load and
fail before the third form runs. Acceptable for a once-per-invocation
preprocessing step, and it disappears entirely once the app has a binstub.

### Prose

`SKILL.md:17-18`, `cli.md:3-4`, the Quick Reference (`SKILL.md:145-155`), and the
examples throughout `cli.md` all move to `bin/shadwire`. The two-line rule
replacing the current Gemfile-inspection guidance:

> Run the CLI as `bin/shadwire`. If `cli.binstub` is false in the context above,
> run `shadwire init` once to create it.

`cli.md`'s `init` section documents the binstub among what `init` writes.

## 7. Documentation

`README.md:99-110` and `packages/cli/README.md:12-18`: both bootstraps — global
`gem install` or `bundle add` — are shown terminating at the same canonical
entry point.

Near the skill install instructions (`README.md:130`), a note that the
`allowed-tools` grant covers only the turn that invokes the skill, with the
durable alternative for a consuming app's `.claude/settings.json`:

```json
{ "permissions": { "allow": ["Bash(bin/shadwire *)"] } }
```

This is documented, not automated: the CLI does not write another tool's config.

## 8. Verification

Two existing tests break by design and must move with the change:

- **`test/skill_check_test.rb:56`** asserts the literal string
  `` !`shadwire status --json` ``. It becomes an assertion that the injection
  chains all three invocation forms and ends in the JSON fallback.
- **`test/skill_check_test.rb:129`** builds a tmpdir app whose Gemfile
  (lines 136-141) declares the base gems specifically so `init` never shells out
  to `bundle add` — the comment at lines 126-128 states the hermeticity this
  buys. With `shadwire` among the ensured gems, that fixture and the fixtures in
  `packages/cli/test/init_test.rb` must also declare `gem "shadwire"`, or the
  suite starts reaching the network.

`test/skill_check_test.rb:94` scans for CLI commands with
``/`?shadwire ([a-z][a-z-]*)/``, which still matches inside `bin/shadwire status`.
Rewriting the examples does not break the command check; a test asserts this
stays true.

New coverage in the CLI suite:

- binstub written on a fresh `init`, with mode `0755`
- existing binstub left untouched and reported as skipped
- `--force` rewrites it
- binstub **not** written when `shadwire` could not be added to the Gemfile
- `status --json` reports `cli.gem` and `cli.binstub`
- `init --json` reports the binstub

New coverage in `skill_check_test.rb`, both deterministic greps over the skill
text:

- **Every command example is canonical.** Scan `SKILL.md` and `cli.md` for
  occurrences of `shadwire <subcommand>` and assert each is preceded by `bin/`.
  Two exemptions, matched literally rather than by heuristic: the bootstrap
  sentence that tells the agent how to create a missing binstub, and the
  injection block, which must name all three forms by construction.
- **Every form the skill can run is granted.** Collect the distinct command
  prefixes appearing in those two exempted places plus the canonical `bin/`
  form, and assert each is covered by a pattern in `allowed-tools`. This is the
  check that would have caught the original report.

## 9. Version

A feature addition to the CLI: `0.3.0`.

## Appendix — verified facts

| Claim | How verified |
|---|---|
| `allowed-tools` pre-approves, does not restrict | Claude Code frontmatter reference, `allowed-tools` row |
| The grant lasts one turn | Same doc: "clears when you send your next message" |
| `` !`cmd` `` is preprocessing, not a tool call | Same doc: "this is preprocessing, not something Claude executes" |
| Only `disableSkillShellExecution` gates the injection | Same doc, dynamic context injection section |
| A space before `*` enforces a word boundary | Claude Code permissions reference: `Bash(ls *)` matches `ls -la`, not `lsof` |
| Wildcards do not cross `./` | Derived: rules match the command string, and `bin/shadwire ` is not a prefix of `./bin/shadwire status` |
| `bin/shadwire` appears nowhere in the repo | `grep -rn "bin/shadwire"` → no matches |
| The CLI has no binstub logic | `grep -rn "binstub" packages/cli/lib packages/cli/exe` → no matches |
| `Project#gem?` re-reads the Gemfile per call | `project.rb:22-25`, no memoization |
| `Installer` never sets an execute bit | `installer.rb:44` writes with `path.write` |
| `init` already shells out to `bundle add` | `init.rb:33`, `dependencies.rb:60` |
| `init --force` currently only resets `shadwire.json` | `init.rb:56` |
| The hermetic workflow test depends on no `bundle add` | `test/skill_check_test.rb:126-141` |
| Rails 8 ships gem binstubs in `bin/` | `bin/rubocop`, `bin/brakeman` in a stock Rails 8 app |
