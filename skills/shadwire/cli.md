# CLI reference

<!-- canonical-exempt:start -->
Run the CLI as `bin/shadwire`. `shadwire init` writes that binstub; until it
exists, reach the CLI as `bundle exec shadwire` (Gemfile) or `shadwire` (global).
<!-- canonical-exempt:end -->

Every command accepts:

| Flag | Effect |
| --- | --- |
| `--cwd DIR` | Run against another app directory (default: current directory) |
| `--registry URL` | Read from this registry instead of the configured one. `https://` or `file://` |

## Commands

### `status`

Project context in one call — the command to run first.

```bash
bin/shadwire status --json
```

```json
{
  "rails": true, "configPresent": true, "registryVersion": "0.2.0",
  "stack": { "importmap": true, "stimulus": true, "tailwindcssRails": true },
  "gems": { "view_component": true, "lucide-rails": true },
  "cli": { "gem": true, "binstub": true },
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
- `cli.binstub` — whether `bin/shadwire` exists. False means run `init` once.
- `helpers.includeAllHelpers` — `false` means the app disabled Rails' automatic
  helper inclusion, so `Ui::*Helper` modules need per-controller `helper` calls.
- `helpers.legacyHelperPresent` — a pre-split `app/helpers/ui_helper.rb` is still
  around. It defines helpers for components that are not installed; safe to delete.

`status` never fails: outside a Rails app it returns `"rails": false`, an
unreachable registry becomes `"registryError"`, and an unreadable `shadwire.json`
becomes `"configError"` with the rest of the payload falling back to defaults.
Exit code is always 0.

### `search QUERY`

```bash
bin/shadwire search form
bin/shadwire search modal --json
```

Matches name, title, description **and** when-to-use text, so conceptual terms
work: `form`, `modal`, `overlay`, `loading`, `right-click`, `navigation`.

### `info NAME`

The component's full API. Read this before writing ERB.

```bash
bin/shadwire info dialog --json
```

Returns `whenToUse`, `usage` snippets, `requiresStimulus`, `registryDependencies`,
the install `files`, and `api.components[]` with each class's helper, `variants`,
`sizes`, `props` (with defaults) and `attrs`.

`helper` is `null` for components with no `ui_*` wrapper — the shared base,
internal parts a parent renders itself, and blocks. Do not try to call those.

File bodies are stripped; `info` is a manifest, not a payload.

### `list`

```bash
bin/shadwire list --json
```

The whole catalog. Prefer `search` when you know what you are looking for.

### `init`

```bash
shadwire init --yes
```

Writes `shadwire.json`, installs the shared base (`ui_component.rb`,
`shadwire.css`), adds the base gems, adds `shadwire` itself to the `development`
group, writes the `bin/shadwire` binstub, and adds the Tailwind `@import`.
Idempotent; an existing binstub is left alone. `--force` resets `shadwire.json`
and rewrites the binstub.

The binstub is the reason `init` is the one command you run un-prefixed: it is
what creates the canonical entry point every later command goes through.

### `add NAME...`

```bash
bin/shadwire add button dialog --yes
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
bin/shadwire diff
bin/shadwire diff --json
bin/shadwire diff --exit-code    # non-zero when drift exists — for CI
```

Reports `unchanged` / `modified` / `missing` per file, with a unified diff for
modified ones. Read-only.

### `update [NAME...]`

```bash
bin/shadwire diff button          # look first
bin/shadwire update button --yes  # then overwrite
```

Re-applies the registry version. **This overwrites local edits.** Always run
`diff` first.

### `remove NAME...`

```bash
bin/shadwire remove chart --yes
```

Deletes only files unique to the removed components — never the shared base, and
never a file another installed component still uses. Importmap pins that nothing
uses any more are reported, not removed.

## Error handling

**Exit code 0 means it worked.** A command that could not install a dependency
reports it and exits non-zero:

```console
$ shadwire init --yes
Initialized shadwire (2 base files).
  create  app/components/ui_component.rb
  FAILED  view_component (bundle add failed)
Failed to install: view_component. Run `bundle add view_component` in the app
and re-run this command.
$ echo $?
1
```

So you can trust the exit code rather than re-checking the Gemfile.

**Errors are sentences, not backtraces.** A malformed `shadwire.json`, an
unreachable registry, a registry serving HTML, and a missing argument each
produce one actionable line on stderr with a non-zero exit:

```text
shadwire.json is not valid JSON: expected object key, got 'not' at line 1 column 3
Could not reach the registry at https://…/index.json: getaddrinfo(3): Name or service not known
add requires at least one component name
```

**`update` discloses what it overwrote.** Both the human output and
`--json` report it — `overwritten` lists the files whose local edits were
replaced, and `diffs` carries the patch for each. Still run `bin/shadwire diff`
first when you care about local changes.

**`status` never fails at all** — it reports `"rails": false`, `"registryError"`
or `"configError"` and exits 0, so it is always safe to inject.

## Registry resolution

1. `--registry` flag
2. `registry` in the app's `shadwire.json`
3. built-in default: `https://shadwire.edumoraes.dev.br/r`

`file://` bases work, which is how you test against a locally built registry.

## Without the CLI

If the gem is not installed and cannot be, the same catalog is published as
plain text:

- `https://shadwire.edumoraes.dev.br/r/llms.txt` — catalog with when-to-use
- `https://shadwire.edumoraes.dev.br/r/llms-full.txt` — every component's API

Installing by hand from these is possible but leaves `shadwire.json` inaccurate,
so `diff`, `update` and `remove` stop working correctly. Prefer the CLI.
