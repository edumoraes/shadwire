# Shadwire Agent Skill & Helper Modularization — Design

Date: 2026-07-27
Status: approved (pending implementation plan)

## Context

Shadwire's CLI is functionally complete (`init`, `add`, `list`, `search`, `info`,
`diff`, `update`, `remove`; 131 passing tests) and the published registry is live
at `https://edumoraes.github.io/shadwire/r`. An audit of the CLI from a coding
agent's perspective found the primitives are right — `--json`, `--yes`, `--cwd`,
correct exit codes, a `file://` registry for hermetic testing — but three things
block agent use:

1. **Discovery is empty.** 53 of 58 registry items have no `title` and no
   `description`. `bin/build_registry` falls back to `humanize(name)` for both, so
   the published data reads `{"name": "dropdown-menu", "title": "Dropdown Menu",
   "description": "Dropdown Menu"}`. `shadwire search form` returns nothing despite
   ten form components existing.
2. **The helper file is 97% dead code.** Installing any single component writes a
   919-line `app/helpers/ui_helper.rb` defining 229 `ui_*` methods that reference
   229 component classes. With one component installed, 228 of them raise
   `NameError` at request time.
3. **There is no agent-facing packaging.** No skill, no plugin, no `llms.txt`.

This design delivers an agent skill distributed via
[skills.sh](https://skills.sh) (`npx skills add edumoraes/shadwire`), modelled on
shadcn/ui's skill at `shadcn-ui/ui:skills/shadcn/`, plus the minimum registry and
CLI work that skill depends on, plus the helper restructure that removes the dead
code at its source.

## Goals

- A `shadwire` skill installable into **any** consuming Rails app, giving a coding
  agent enough context to install, choose, compose, theme and update components.
- Per-component API context (variants, sizes, props, subcomponents) that **cannot
  drift** from the source it describes.
- Installing a component brings **only that component's** helper methods.
- Automated verification that the skill's claims stay true.

## Non-goals

- Fixing every agent-safety bug found in the audit. Explicitly deferred; see
  "Known gaps" below.
- Converting bundled files into real `registryDependencies`. Worthwhile follow-up,
  separate refactor.
- Translating or expanding the `sandbox/` docs site.
- LLM-based evals. Verification is deterministic (see §6).

## Guiding principle

**The skill contains no data that can drift.**

Every documentation failure found in the audit is the same bug: facts copied into
prose. The root `README.md` lists 28 components while the registry has 58. The
docs site still says *"A CLI de instalação ainda está por vir"* three phases after
the CLI shipped.

So the skill carries **procedure** — workflow, conventions, rules. It pulls
**data** — component names, variants, props, helpers — from the CLI at runtime.
The only enumeration that stays in the skill is the Component Selection table
(`need → component name`), because intent is not derivable from code; CI asserts
every name in it exists in the built registry.

```
registry/rails/ui/components/*.rb ──┐  code = source of truth for API
registry/registry.json ─────────────┤  prose = source of truth for intent
                                    │
                    bin/build_registry
                      ├── inline file contents          (exists)
                      ├── NEW: Prism AST → "api" block
                      ├── NEW: validate required prose fields (hard fail)
                      └── NEW: llms.txt / llms-full.txt
                                    ↓
              build/r/{name}.json + index.json  →  GitHub Pages
                                    ↓
   shadwire info NAME --json     shadwire status --json      llms.txt
   (pre-install: pick + use)     (post-install: context)     (no CLI needed)
                                    ↓
              skills/shadwire/SKILL.md   ← !`shadwire status --json`
                                    ↓
                 npx skills add edumoraes/shadwire
```

---

## 1. Helper modularization

### Current state

`registry/rails/ui/helpers/ui_helper.rb` is a single 919-line module with 229
`ui_*` methods. It is listed in **every** item's `files[]` and installs to
`app/helpers/ui_helper.rb`. It is also part of the shared base, so `remove` never
deletes it.

### Design

One helper module per registry item, under `app/helpers/ui/`:

```
registry/rails/ui/helpers/ui/button_helper.rb  →  app/helpers/ui/button_helper.rb
                                                   module Ui::ButtonHelper
                                                     def ui_button(**options, &block)

registry/rails/ui/helpers/ui/card_helper.rb    →  app/helpers/ui/card_helper.rb
                                                   module Ui::CardHelper
                                                     def ui_card, ui_card_header,
                                                         ui_card_title, ui_card_content, …
```

An item's helper file carries the helpers for the component classes that item
owns — for `card`, that is `ui/card_component.rb` plus everything under
`ui/card/`. This matches the flat-root + nested-subcomponent convention already
documented in `CLAUDE.md`, so the grouping is deterministic.

Items of `type: "block"` ship **no** helper file (verified: `sidebar-01` has no
`ui_*` methods today).

`app/helpers/ui_helper.rb` is removed from the registry entirely. The shared base
becomes `ui_component.rb` + `shadwire.css`.

### Why this works

Verified against Rails 8.1 source, `actionpack-8.1.3/lib/abstract_controller/helpers.rb`:

- `all_helpers_from_path` (line 48) globs `#{path}/**/*_helper.rb` — recursive,
  so nested directories are discovered.
- For `app/helpers/ui/button_helper.rb` the extracted name is `ui/button`.
- `modules_for_helpers` (line 33) camelizes it and appends `Helper`:
  `"ui/button".camelize` → `Ui::Button` → `Ui::ButtonHelper` → `constantize`.

With `config.action_controller.include_all_helpers` at its default of `true`
(`action_controller/metal/helpers.rb:71`), every `Ui::*Helper` module is
auto-included into views. No aggregator file is
needed, so the CLI never has to merge or regenerate a file the user owns.

### What it buys

| | Today | After |
|---|---|---|
| Install `button` | 919 lines, 229 methods, 228 dead | ~5 lines, 1 method |
| Call an uninstalled helper | `NameError: uninitialized constant Ui::CarouselComponent` | `undefined method 'ui_carousel'` |
| `remove card` | helper kept forever as shared | deletes `ui/card_helper.rb` |
| Ownership | one file all components share | one file per component |

The error-quality row matters as much as the dead-code row. Today the method
exists, so an agent assumes the component is installed and misdiagnoses the class.
After, the error names the real problem.

### Complication: bundled component files

`dropdown-menu` ships `button_component.rb` in its own `files[]`, so it must also
ship `ui/button_helper.rb`. Helper files stay explicitly listed in each item's
`files[]` (no magic), and a CI check asserts that the helper files an item ships
match the component files it ships (§6).

### Migration

Splitting 229 methods into ~57 files is scriptable: helper → component class
resolution was verified 100% derivable (229/229) by regex over the existing
monolith. A one-time migration script performs the split; thereafter the files are
hand-maintained, and `CLAUDE.md`'s "Adding a component" step 3 changes from
"add a `ui_*` wrapper in `ui_helper.rb`" to "add
`registry/rails/ui/helpers/ui/<item>_helper.rb`".

The gem is unpublished at `0.1.0`, so there are effectively no installs to
migrate. `shadwire status --json` reports `legacyHelperPresent: true` when a stale
monolithic `app/helpers/ui_helper.rb` is found, so an agent can tell the user to
delete it. The CLI never deletes it automatically.

---

## 2. Registry metadata contract

### Hand-written, in `registry/registry.json`

Four fields per item, all **required**. `bin/build_registry` fails the build when
any is missing — this is what replaces today's silent `humanize(name)` fallback.

```json
{
  "name": "dropdown-menu",
  "type": "component",
  "title": "Dropdown Menu",
  "description": "A menu of actions or options triggered by a button.",
  "whenToUse": "Row actions, overflow menus, account menus. For navigation between pages use navigation-menu; for right-click use context-menu.",
  "usage": [
    "<%= ui_dropdown_menu do %>\n  <%= ui_dropdown_menu_trigger { ui_button(variant: :outline) { \"Open\" } } %>\n  <%= ui_dropdown_menu_content do %>\n    <%= ui_dropdown_menu_item { \"Edit\" } %>\n  <% end %>\n<% end %>"
  ]
}
```

`whenToUse` carries the disambiguation between neighbouring components. It is the
field that makes `shadwire search form` useful, and the one thing an AST can never
infer.

### Generated by `bin/build_registry`

Extraction uses Prism and runs in `bin/build_registry` — repo tooling on Ruby
3.4.8, **not** the CLI gem. This distinction matters: Prism is stdlib only from
Ruby 3.3, while `shadwire.gemspec` declares `required_ruby_version >= 3.2`. The
extraction must therefore never be moved into the shipped gem without adding an
explicit `prism` dependency. Published item JSON carries the *result*, so the CLI
itself needs no parser.

Verified across all 234 component files: 0 parse errors, 232 have an `initialize`.

```json
"requiresStimulus": true,
"api": {
  "components": [
    {
      "class": "Ui::CardComponent",
      "helper": "ui_card",
      "root": true,
      "variants": [],
      "sizes": [],
      "props": [{ "name": "class_name", "default": "nil" }],
      "attrs": true
    },
    {
      "class": "Ui::Card::HeaderComponent",
      "helper": "ui_card_header",
      "root": false,
      "props": [{ "name": "class_name", "default": "nil" }],
      "attrs": true
    }
  ]
}
```

Extraction rules:

- **variants / sizes** — frozen constant hashes assigned at class body level
  (`VARIANTS = {...}.freeze`); keys only. Verified working on `button`
  (`["default","destructive","outline","secondary","ghost","link"]` /
  `["default","sm","lg","icon"]`).
- **props** — `initialize` keyword parameters with their default source text.
  `attrs: true` when a `**` keyword-rest is present.
- **class** — from module/class nesting.
- **helper** — from the per-item helper module (§1).
- **subcomponents** — additional entries with `root: false`. There are **zero**
  `renders_one`/`renders_many` calls in the codebase (verified); composition is by
  nested classes, so "slots" is not a meaningful axis and is not emitted.
- **requiresStimulus** — true when the item ships any `app/javascript/` file.
  28 of 58 items do.

---

## 3. CLI surface additions

Additive only. No changes to existing command behavior.

### `shadwire status --json` (new)

The skill's injected project context.

```json
{
  "rails": true,
  "configPresent": true,
  "registry": "https://edumoraes.github.io/shadwire/r",
  "registryVersion": "0.2.0",
  "stack": { "importmap": true, "stimulus": true, "tailwindcssRails": true },
  "gems": { "view_component": true, "lucide-rails": false },
  "tailwind": { "css": "app/assets/tailwind/application.css", "importPresent": true },
  "helpers": { "includeAllHelpers": true, "legacyHelperPresent": false },
  "installed": [
    {
      "name": "card",
      "version": "0.2.0",
      "drift": "unchanged",
      "helpers": ["ui_card", "ui_card_header", "ui_card_title", "ui_card_content"],
      "classes": ["Ui::CardComponent", "Ui::Card::HeaderComponent"]
    }
  ],
  "availableCount": 58
}
```

- `includeAllHelpers` is grepped from `config/application.rb`. When an app sets it
  to `false`, `Ui::*Helper` modules need per-controller inclusion. This is equally
  true of today's monolith, so it is not a regression — but the agent should know.
- `legacyHelperPresent` flags a stale monolithic `app/helpers/ui_helper.rb`.
- `drift` reuses the existing `Diff` comparison (`unchanged` / `modified` /
  `missing`).

**Contract rule:** `status --json` must emit valid JSON and exit 0 even when the
directory is not a Rails app or `shadwire.json` is absent — `{"rails": false,
"configPresent": false, …}`. If it raised instead, the skill's `!` injection would
break and the agent would start with a backtrace where its project context should
be. Failure states are data here, not exceptions.

A human-readable (non-`--json`) rendering is also provided, consistent with the
other commands.

### `shadwire info NAME --json` (enriched)

Gains `api`, `whenToUse`, `usage`, and `requiresStimulus` from §2, so an agent can
choose and correctly call a component **before** installing it. The existing
behavior of stripping file `content` is retained — `info` stays a manifest, not a
payload.

### Unchanged

`search`, `add`, `diff`, `update`, `remove` already carry what the skill needs.

---

## 4. Static agent entry points

`bin/build_registry` also emits, into `build/r/`:

- **`llms.txt`** — one `name — whenToUse` line per component, plus a short header
  describing what Shadwire is and how to install the CLI.
- **`llms-full.txt`** — full API cards per component (class, helper, variants,
  sizes, props, subcomponents, usage).

Both are deployed alongside the registry by the existing `deploy_pages` job. They
cover agents that never install the skill, and cost nothing extra because the data
is already assembled for the item JSON.

---

## 5. The skill package

Distributed via skills.sh from this repo, mirroring `shadcn-ui/ui:skills/shadcn/`:

```
skills/shadwire/
├── SKILL.md          entry point: context injection, principles, rules, workflow
├── cli.md            full command + flag reference
├── theming.md        CSS tokens, :root/.dark, @theme inline, custom colors
└── rules/
    ├── composition.md  nested subcomponent classes, no slots, no `icon:` props
    ├── styling.md      semantic tokens, class-order precedence, class: vs class_name:
    ├── forms.md        the field family, passing form attrs through **attrs
    └── icons.md        lucide-rails kebab names, decorative default, size: :icon
```

Users install with `npx skills add edumoraes/shadwire`.

### Frontmatter

```yaml
name: shadwire
description: Manages shadcn/ui components in Ruby on Rails apps via the shadwire CLI —
  adding, searching, composing, theming and updating ViewComponent-based UI. Applies to
  any Rails project with a shadwire.json, or when asked to add UI components to Rails.
user-invocable: false
allowed-tools: Bash(shadwire *), Bash(bundle exec shadwire *)
```

### SKILL.md structure

1. **Current Project Context** — `` !`shadwire status --json` ``
2. **Principles** — use existing components first; compose, don't reinvent; built-in
   variants before custom classes; semantic tokens only.
3. **Critical Rules** — one line each, linking to `rules/*.md` with Wrong/Right pairs.
4. **Component Selection** — `need → component name` table (CI-verified).
5. **Workflow** — `search → info → add → verify`.
6. **Quick Reference** — command cheatsheet.

### Critical Rules

Each is grounded in something verified in the source:

1. **Confirm a component is installed before calling its helper.** After §1 the
   helper simply will not exist; `status` lists what is live.
2. **Compose, don't pass props.** `ui_card_header` as a nested block, never a
   `header:` prop. Icons go *inside* components via nested `ui_icon` — there is no
   `icon:` prop anywhere in the registry.
3. **Semantic tokens only** — `bg-primary`, `text-muted-foreground`, `border-input`.
   Never `bg-blue-500`.
4. **User classes win, and both spellings work.** `class:` and `class_name:`
   normalize to `@class_name`, which lands last in
   `class_names(base, variant, size, @class_name)`. Extra HTML attributes pass
   through `**attrs`, preserving Rails nested forms (`data: { turbo: false }`).
5. **Check `requiresStimulus` before adding.** 28 of 58 components ship a Stimulus
   controller and need importmap with eager loading; `status.stack` reports it.
6. **Never hand-fetch registry files from GitHub.** Always use the CLI, so
   `shadwire.json` bookkeeping stays correct.
7. **Installed files belong to the user.** Edit them freely — but `update`
   overwrites. Run `diff` first and pass `--yes` deliberately (see Known gaps).

### Forms

`rules/forms.md` documents the `field` family (`field_component.rb` plus
`field/{group,label,error,description,legend,content,separator}_component.rb`) and
the fact that there is **no form-builder wrapper**: `Ui::InputComponent` takes
`**attrs`, so `name:`, `id:` and `value:` are passed through by the caller. Exact
rules are pinned during implementation by reading the source.

---

## 6. Verification

A CI job `skill_check`, deterministic and LLM-free:

- Every `ui_*` named in `SKILL.md` / `rules/*.md` exists in the registry's helper
  modules.
- Every component named in the Component Selection table exists in
  `build/r/index.json`.
- Every `shadwire` command and flag cited in `SKILL.md` / `cli.md` exists in
  `shadwire help`.
- Every `usage` snippet's helper exists, and the keyword arguments it passes match
  the extracted `props` for that component.
- Each item's helper files in `files[]` match the component files it ships (§1).
- `bin/build_registry` hard-fails on a missing `title` / `description` /
  `whenToUse`.
- **Smoke test:** `init → add → status → diff` runs green against a `file://`
  registry in a fixture app.

The smoke test is what would have caught the silent `bundle add` failure.

## 7. Prerequisites and sequencing

**Publishing the gem to RubyGems is a hard prerequisite.** The skill's `!`
injection shells out to `shadwire`; a skill shipped against an uninstallable CLI is
dead on arrival. `shadwire` is currently not on RubyGems (`This rubygem could not
be found`) and no release workflow exists. Both READMEs already instruct
`gem install shadwire` / `bundle add shadwire`, so this is also a standing
documentation bug.

Suggested order, each independently verifiable:

1. Helper modularization (§1) — registry restructure + migration script + sandbox sync.
2. Registry metadata (§2) — required prose fields, Prism extraction, build validation.
3. CLI additions (§3) — `status`, enriched `info`.
4. Static entry points (§4) — `llms.txt`, `llms-full.txt`.
5. Skill package (§5).
6. Verification (§6).
7. Gem release workflow + publish.

## 8. Known gaps (deliberately out of scope)

Scoped out by decision; recorded so the skill works around them honestly rather
than pretending they do not exist.

- **`bundle add` failure is reported as success.** `Dependencies#ensure_gems`
  discards the `system()` return value and returns `applied:` unconditionally;
  the CLI exits 0. Demonstrated with a stub `bundle` exiting 1.
- **Unhandled exceptions leak Ruby backtraces.** `run_command` rescues only
  `Shadwire::Error`; a malformed `shadwire.json` raises `JSON::ParserError` and an
  unreachable registry raises `Socket::ResolutionError`, both with backtraces.
- **`update --yes --json` clobbers local edits silently.** `Update#call` computes
  `diffs` but `json_payload` omits them; the human path prints them, the JSON path
  does not. Critical Rule 7 warns about this.
- **`init` and `add` have no `--json`.** `add --json` is consumed as a component
  name, yielding `Registry item "--json" not found`.
- **Arity errors bypass `run_command`.** `add`/`search`/`remove` with no arguments
  raise outside the rescue and print a backtrace.
- **Root `README.md` lists 28 components; the registry has 58.**
- **The docs site is Portuguese and states the CLI does not exist yet.**

## Appendix — verified facts

| Claim | How verified |
|---|---|
| Nested helper modules auto-include | Rails 8.1 `abstract_controller/helpers.rb:33,48` |
| `include_all_helpers` defaults true | Rails 8.1 `action_controller/metal/helpers.rb:71` |
| Prism is stdlib on Ruby 3.4, not 3.2 | `require "prism"` without bundler → 1.9.0 on 3.4.10 |
| Prism extracts variants/sizes/props | Ran on `button_component.rb`; exact expected output |
| Extraction is safe repo-wide | 234 files parsed, 0 errors, 232 with `initialize` |
| No ViewComponent slots in use | 0 `renders_one`/`renders_many` across the registry |
| helper → class is 100% derivable | 229/229 resolved from the existing monolith |
| 28/58 items ship Stimulus | Scanned `files[]` for `app/javascript/` targets |
| Blocks have no helpers | No `Ui::Blocks::` reference in `ui_helper.rb` |
| 53/58 items lack title/description | Scanned `registry/registry.json` |
| Gem not published | `rubygems.org/api/v1/gems/shadwire.json` → not found |
| Registry is live | `index.json` and `button.json` → HTTP 200 |
| CLI suite green | 131 runs, 391 assertions, 0 failures |
