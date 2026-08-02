# shadwire

shadcn/ui components for Ruby on Rails, delivered the shadcn **Open Code** way:
the CLI copies component *source* into your app and records it in `shadwire.json`.
Installed files are yours to edit — there is no runtime dependency on Shadwire.

Part of the [Shadwire](https://github.com/edumoraes/shadwire) monorepo. The
component source lives in that repo's `registry/` and is published to a static
registry the CLI installs from over HTTP.

## Install

```bash
gem install shadwire                      # or: bundle add shadwire --group development
shadwire init                             # writes bin/shadwire; use it from then on
```

`init` adds `shadwire` to the app's `development` group and writes the
`bin/shadwire` binstub. That binstub is the canonical entry point: it is pinned to
the app's bundle, so every developer and CI job runs the same CLI version. `init`
is the one command you run un-prefixed, because it is what creates the binstub.

Requires Ruby >= 3.2 and a Rails app (>= 7.1) using ViewComponent and Tailwind CSS.

## Commands

Run `bin/shadwire help COMMAND` for the built-in usage of any command.

| Command | What it does | Flags (besides `--cwd`) |
| --- | --- | --- |
| `init` | Bootstrap Shadwire: write `shadwire.json`, install the shared base files (`ui_component.rb`, `shadwire.css`) and base gems, add `shadwire` to the `development` group, write the `bin/shadwire` binstub, add the Tailwind `@import`. | `--yes`, `--registry URL`, `--force`, `--json` |
| `add NAME...` | Install one or more components and their registry dependencies; apply their gems and importmap pins; record them in `shadwire.json`. | `--yes`, `--overwrite`, `--no-deps`, `--registry URL`, `--json` |
| `list` | List every component in the registry catalog. | `--registry URL`, `--json` |
| `search QUERY` | Search the catalog by name, title, or description. | `--registry URL`, `--json` |
| `info NAME` | Show a component's metadata: files, gems, importmap pins, registry dependencies. | `--registry URL`, `--json` |
| `diff [NAME...]` | Show how installed files have drifted from the registry (`unchanged` / `modified` / `missing`). | `--registry URL`, `--json`, `--exit-code` |
| `update [NAME...]` | Re-apply the registry version of installed components (all, or the named ones). | `--yes`, `--overwrite`, `--no-deps`, `--registry URL`, `--json` |
| `remove NAME...` | Uninstall components, deleting only their own files (never the shared base, never files still used by another component). | `--yes`, `--registry URL`, `--json` |
| `status` | Report app context: stack detection, installed components with the helpers they define, and drift. | `--registry URL`, `--json` |
| `version` | Print the installed CLI version. | — |

### `status` and coding agents

`status --json` is the one call that describes the whole install, which is why
the Shadwire agent skill injects it:

```json
{
  "rails": true, "configPresent": true, "registryVersion": "0.2.0",
  "stack": { "importmap": true, "stimulus": true, "tailwindcssRails": true },
  "cli": { "gem": true, "binstub": true },
  "helpers": { "includeAllHelpers": true, "legacyHelperPresent": false },
  "installed": [
    { "name": "card", "drift": "unchanged",
      "helpers": ["ui_card", "ui_card_header", "ui_card_title"],
      "classes": ["Ui::CardComponent", "Ui::Card::HeaderComponent"] }
  ],
  "availableCount": 58
}
```

`installed[].helpers` lists the `ui_*` methods that actually exist in the app, so
there is no guessing about which helpers are callable.

`status` never raises: a directory that is not a Rails app, a missing
`shadwire.json`, and an unreachable registry are all reported as fields
(`"rails": false`, `"registryError": "..."`) with exit code 0.

### Flags

- `--cwd DIR` — run against another app directory (default: the current directory). Available on every command.
- `--yes`, `-y` — apply file and dependency changes without prompting (the agent / CI path).
- `--overwrite` — overwrite locally-modified files without prompting (`add` / `update`).
- `--no-deps` — skip transitive registry dependencies (`add` / `update`; deps are on by default).
- `--registry URL` — install or read from this registry instead of the configured one.
- `--json` — emit machine-readable JSON instead of human output.
- `--force` — overwrite an existing `shadwire.json` (`init`).
- `--exit-code` — make `diff` exit non-zero when any drift is found (for CI).

## `shadwire.json`

`init` writes `shadwire.json` at the app root. It records the registry, where
files install (aliases), the Tailwind entrypoint, and what is installed:

```json
{
  "registry": "https://shadwire.edumoraes.dev.br/r",
  "tailwind": { "css": "app/assets/tailwind/application.css" },
  "aliases": {
    "components":  "app/components",
    "ui":          "app/components/ui",
    "helpers":     "app/helpers",
    "controllers": "app/javascript/controllers",
    "vendorCss":   "vendor/shadwire"
  },
  "installed": {
    "button": { "version": "1.0.0", "files": ["app/components/ui/button_component.rb"] }
  }
}
```

- `registry` — base URL the CLI installs from (persisted from `init --registry`).
- `tailwind.css` — the app's Tailwind entrypoint that receives the `@import`.
- `aliases` — install targets for each kind of file.
- `installed` — per-component `version` plus the files it owns (used by `diff`, `update`, and `remove`).

## Registry resolution

For any command, the registry base URL is resolved in this order:

1. the `--registry` flag, if given;
2. the `registry` field in the app's `shadwire.json`;
3. the built-in default, `https://shadwire.edumoraes.dev.br/r`.

Both `https://` and local `file://` bases are supported. Point `--registry` at a
`file://` path to install from a registry built locally with `bin/build_registry`
(for example `file://$PWD/build/r`). The CLI reads `index.json` (the catalog and
shared base) and `<name>.json` (a component with its files inlined) from that base.

## License

MIT.
