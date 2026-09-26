# shadwire

shadcn/ui components for Ruby on Rails. Like the shadcn CLI, this one copies the
component *source* into your app and records what it installed in
`shadwire.json`. You can edit the installed files freely, and your app does not
depend on Shadwire at runtime.

The CLI is part of the [Shadwire](https://github.com/edumoraes/shadwire) monorepo.
The component source lives in that repo's `registry/`, which is published as a
static registry that the CLI downloads from over HTTP.

## Install

```bash
gem install shadwire                       # global, then: shadwire init
bundle add shadwire --group development    # in the app, then: bundle exec shadwire init
```

`init` adds `shadwire` to the app's `development` group if it is not there yet,
and writes a `bin/shadwire` binstub. Run every other command through the binstub:
it loads the CLI from the app's bundle, so everyone on the project uses the same
version. `init` is the only command you run without `bin/`, because the binstub
does not exist until it runs.

A bundle installed with `--without development`, which is common in deploys and
some CI jobs, does not include `shadwire`, so `bin/shadwire` will not run there.
Any job that uses the CLI, such as a drift check, needs the development group.

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

`status --json` describes the whole install in a single call. The Shadwire agent
skill loads it into the agent's context for that reason:

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

`installed[].helpers` lists the `ui_*` methods defined in the app, so an agent
knows which helpers it can call.

`status` never fails. A directory that is not a Rails app, a missing
`shadwire.json` or an unreachable registry show up as fields
(`"rails": false`, `"registryError": "..."`), and the exit code is still 0.

### Flags

- `--cwd DIR`: run against another app directory instead of the current one. Works with every command.
- `--yes`, `-y`: apply file and dependency changes without asking. Agents and CI use this.
- `--overwrite`: overwrite files you changed locally without asking (`add`, `update`).
- `--no-deps`: skip the component's registry dependencies, which are installed by default (`add`, `update`).
- `--registry URL`: read from this registry instead of the configured one.
- `--json`: print JSON instead of human-readable output.
- `--force`: overwrite an existing `shadwire.json` (`init`).
- `--exit-code`: make `diff` exit non-zero when a file has drifted, so CI can fail on it.

## `shadwire.json`

`init` writes `shadwire.json` at the app root. It records the registry URL, the
directories each kind of file goes to (aliases), the Tailwind entrypoint, and
what is installed:

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

- `registry`: the base URL the CLI installs from. `init --registry` sets it.
- `tailwind.css`: the app's Tailwind entrypoint, where `init` adds the `@import`.
- `aliases`: the directory for each kind of file.
- `installed`: each component's `version` and the files it owns. `diff`, `update` and `remove` read this.

## Registry resolution

For any command, the registry base URL is resolved in this order:

1. the `--registry` flag, if given;
2. the `registry` field in the app's `shadwire.json`;
3. the built-in default, `https://shadwire.edumoraes.dev.br/r`.

Both `https://` and local `file://` URLs work. To test a registry you built with
`bin/build_registry`, point `--registry` at it (for example `file://$PWD/build/r`).
The CLI reads `index.json` (the catalog and the shared base files) and
`<name>.json` (one component, with its files inlined) from that URL.

## License

MIT.
