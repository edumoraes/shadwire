# CLI reference

Run as `shadwire` (installed globally) or `bundle exec shadwire` (in the app's
Gemfile). Check the app's `Gemfile` for `gem "shadwire"`.

Every command accepts:

| Flag | Effect |
| --- | --- |
| `--cwd DIR` | Run against another app directory (default: current directory) |
| `--registry URL` | Read from this registry instead of the configured one. `https://` or `file://` |

## Commands

### `status`

Project context in one call — the command to run first.

```bash
shadwire status --json
```

```json
{
  "rails": true, "configPresent": true, "registryVersion": "0.2.0",
  "stack": { "importmap": true, "stimulus": true, "tailwindcssRails": true },
  "gems": { "view_component": true, "lucide-rails": true },
  "tailwind": { "css": "app/assets/tailwind/application.css", "importPresent": true },
  "helpers": { "includeAllHelpers": true, "legacyHelperPresent": false },
  "installed": [
    { "name": "button", "version": "0.2.0", "drift": "unchanged",
      "helpers": ["ui_button"], "classes": ["Ui::ButtonComponent"] }
  ],
  "availableCount": 58
}
```

- `installed[].helpers` — the `ui_*` methods that exist. Check before calling.
- `installed[].drift` — `unchanged`, `modified`, `missing`, or `unknown`.
- `helpers.includeAllHelpers` — `false` means the app disabled Rails' automatic
  helper inclusion, so `Ui::*Helper` modules need per-controller `helper` calls.
- `helpers.legacyHelperPresent` — a pre-split `app/helpers/ui_helper.rb` is still
  around. It defines helpers for components that are not installed; safe to delete.

`status` never fails: outside a Rails app it returns `"rails": false`, and an
unreachable registry becomes `"registryError"`. Exit code is always 0.

### `search QUERY`

```bash
shadwire search form
shadwire search modal --json
```

Matches name, title, description **and** when-to-use text, so conceptual terms
work: `form`, `modal`, `overlay`, `loading`, `right-click`, `navigation`.

### `info NAME`

The component's full API. Read this before writing ERB.

```bash
shadwire info dialog --json
```

Returns `whenToUse`, `usage` snippets, `requiresStimulus`, `registryDependencies`,
the install `files`, and `api.components[]` with each class's helper, `variants`,
`sizes`, `props` (with defaults) and `attrs`.

`helper` is `null` for components with no `ui_*` wrapper — the shared base,
internal parts a parent renders itself, and blocks. Do not try to call those.

File bodies are stripped; `info` is a manifest, not a payload.

### `list`

```bash
shadwire list --json
```

The whole catalog. Prefer `search` when you know what you are looking for.

### `init`

```bash
shadwire init --yes
```

Writes `shadwire.json`, installs the shared base (`ui_component.rb`,
`shadwire.css`), adds the base gems and the Tailwind `@import`. Idempotent;
`--force` resets `shadwire.json`.

### `add NAME...`

```bash
shadwire add button dialog --yes
```

Installs components and their registry dependencies, applies gems and importmap
pins, and records them in `shadwire.json`.

| Flag | Effect |
| --- | --- |
| `--yes` | Apply without prompting (the agent path) |
| `--overwrite` | Overwrite locally-modified files without prompting |
| `--no-deps` | Skip transitive registry dependencies |

Without `--yes`, files matching the registry are skipped silently and only
locally-modified files prompt. In a non-interactive shell with no `--yes`,
everything is skipped — safe, but nothing is installed.

### `diff [NAME...]`

```bash
shadwire diff
shadwire diff --json
shadwire diff --exit-code    # non-zero when drift exists — for CI
```

Reports `unchanged` / `modified` / `missing` per file, with a unified diff for
modified ones. Read-only.

### `update [NAME...]`

```bash
shadwire diff button          # look first
shadwire update button --yes  # then overwrite
```

Re-applies the registry version. **This overwrites local edits.** Always run
`diff` first.

### `remove NAME...`

```bash
shadwire remove chart --yes
```

Deletes only files unique to the removed components — never the shared base, and
never a file another installed component still uses. Importmap pins that nothing
uses any more are reported, not removed.

## Known gaps to work around

Real behaviour of the current CLI. Do not trust output that these affect.

**`bundle add` failure is reported as success.** `init` and `add` print gems as
applied and exit 0 even when `bundle add` failed. After either command, verify:

```bash
grep -E 'view_component|lucide-rails' Gemfile
```

If they are missing, add them yourself. Otherwise the app raises
`uninitialized constant ViewComponent` at request time, which looks unrelated.

**`init` and `add` have no `--json`.** Passing `--json` to `add` is parsed as a
component name and fails with `Registry item "--json" not found`. Parse the
human output, or run `status --json` afterwards.

**`update --yes --json` does not report what it overwrote.** The human output
prints the diff of clobbered edits; the JSON payload omits it. Run
`shadwire diff --json` *before* updating if you need to know.

**Some errors surface as Ruby backtraces.** A malformed `shadwire.json` raises
`JSON::ParserError` and an unreachable host raises a socket error, both with a
stack trace. Exit code is still non-zero, so trust the exit code over the output
shape. `status` is the exception — it degrades gracefully by design.

**Missing arguments print a backtrace.** `shadwire add` with no names raises
outside the error handler. The message is on the first line; ignore the trace.

## Registry resolution

1. `--registry` flag
2. `registry` in the app's `shadwire.json`
3. built-in default: `https://edumoraes.github.io/shadwire/r`

`file://` bases work, which is how you test against a locally built registry.

## Without the CLI

If the gem is not installed and cannot be, the same catalog is published as
plain text:

- `https://edumoraes.github.io/shadwire/r/llms.txt` — catalog with when-to-use
- `https://edumoraes.github.io/shadwire/r/llms-full.txt` — every component's API

Installing by hand from these is possible but leaves `shadwire.json` inaccurate,
so `diff`, `update` and `remove` stop working correctly. Prefer the CLI.
