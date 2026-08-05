---
name: shadwire
description: Manages shadcn/ui components in Ruby on Rails apps via the shadwire CLI — adding, searching, composing, theming and updating ViewComponent-based UI. Applies to any Rails project with a shadwire.json, or when asked to add, build, style or fix UI components in a Rails app.
user-invocable: false
allowed-tools: Bash(bin/shadwire *), Bash(./bin/shadwire *), Bash(bundle exec shadwire *), Bash(shadwire *)
---

# Shadwire

shadcn/ui for Ruby on Rails, delivered the shadcn **Open Code** way: the CLI
copies component *source* into the app and the app owns it. Installed files have
no runtime dependency on Shadwire — edit them freely.

Components are ViewComponent classes in the `Ui` namespace. Each has a `ui_*`
helper wrapper. Both are equivalent; prefer the helper in views.

<!-- canonical-exempt:start -->
> Run the CLI as `bin/shadwire`. If `cli.binstub` is false in the context below,
> create it once with `bundle exec shadwire init` when `cli.gem` is true, or with
> `shadwire init` when the gem is only installed globally. After that there is
> one entry point and everything below applies as written.
<!-- canonical-exempt:end -->

## Current Project Context

<!-- canonical-exempt:start -->
```!
bin/shadwire status --json 2>/dev/null || bundle exec shadwire status --json 2>/dev/null || shadwire status --json 2>/dev/null || echo '{"rails":false,"cliMissing":true}'
```
<!-- canonical-exempt:end -->

Read this before anything else. The three fields that decide what you can write:

- **`installed[].helpers`** — the `ui_*` methods that actually exist in this app.
  A helper for a component that is not installed **does not exist**; calling it
  raises `NoMethodError`. Install the component first.
- **`stack.importmap`** / **`stack.stimulus`** — whether interactive components
  will work. 29 of 57 components ship a Stimulus controller.
- **`cli.binstub`** — whether `bin/shadwire` exists yet. False means run `init`
  once before anything else, so the rest of this file applies as written.

The block always returns parseable JSON. `cliMissing` means no form of the CLI
resolved here, and `rails: false` means this is not a Rails app — say so rather
than guessing. `configError` means `shadwire.json` is unreadable and the rest of
the payload fell back to defaults: `installed` will be empty even if components
are on disk, so fix the file before trusting it.

## Principles

1. **Use an existing component before writing markup.** Run `bin/shadwire search`
   first; the catalog covers most UI needs.
2. **Compose, don't reinvent.** A settings page is `card` + `field` + form
   controls. A dashboard is `sidebar` + `card` + `chart` + `table`.
3. **Use built-in variants before custom classes.** `variant: :outline`,
   `size: :sm` exist — reach for `class:` only for layout.
4. **Use semantic tokens.** `bg-primary`, `text-muted-foreground` — never
   `bg-blue-500`.

## Critical Rules

Always enforced. Each links to a file with Wrong/Right pairs.

### Helpers exist only for installed components → [rules/composition.md](./rules/composition.md)

- **Check `installed[].helpers` before calling any `ui_*` method.** Each component
  installs its own helper module (`app/helpers/ui/button_helper.rb`). Not
  installed means the method does not exist.
- **Never hand-fetch component files from GitHub.** Use `bin/shadwire add`, so
  `shadwire.json` bookkeeping stays correct.

### Composition → [rules/composition.md](./rules/composition.md)

- **Subcomponents are nested helpers, not props.** `ui_card_header` as a block —
  there is no `header:` prop. This codebase uses no ViewComponent slots.
- **Dialog, Sheet, Drawer and AlertDialog always need a title.** Use
  `class: "sr-only"` if it should be visually hidden.
- **Items belong inside their group.** `ui_select_item` inside `ui_select_content`,
  `ui_tabs_trigger` inside `ui_tabs_list`.

### Styling → [rules/styling.md](./rules/styling.md)

- **Semantic tokens only.** Never hardcode colors or `dark:` color overrides.
- **`class:` and `class_name:` are equivalent** and always win — they are composed
  last, after base/variant/size.
- **Use `class:` for layout, not for restyling.** Change the variant instead.

### Forms → [rules/forms.md](./rules/forms.md)

- **Wrap every control in `ui_field`.** Never lay out form rows with bare `div`s.
- **There is no form-builder integration.** Pass `name:`, `id:`, `value:` through
  yourself; they forward to the underlying HTML element.

### Icons → [rules/icons.md](./rules/icons.md)

- **Lucide kebab-case names** — `ui_icon("chevron-down")`.
- **Compose icons inside components.** There is no `icon:` prop anywhere.
- **Icons are decorative by default.** Pass `label:` when the icon is the only
  meaning; use `size: :icon` for icon-only buttons.

## Component Selection

| Need | Use |
| --- | --- |
| Action or link-as-button | `button` |
| Related actions joined | `button-group` |
| Menu of actions | `dropdown-menu`, `context-menu` (right-click), `menubar` (app menu) |
| Text entry | `input`, `textarea`, `input-group` (with addon), `input-otp` (codes) |
| Form layout, labels, errors | `field`, `label` |
| Pick one of many | `select`, `combobox` (searchable), `native-select`, `radio-group` |
| Pick several | `checkbox`, `toggle-group` |
| On/off setting | `switch`, `toggle` |
| Numeric range | `slider` |
| Dates | `calendar` (inline month, single or range), `date-picker` (field + popover) |
| Modal / overlay | `dialog`, `alert-dialog` (confirm), `sheet` (side), `drawer` (bottom) |
| Anchored floating content | `popover`, `tooltip` (hint), `hover-card` (preview) |
| Data display | `table`, `data-table` (sort/filter/paginate), `card`, `item`, `badge`, `avatar` |
| Navigation | `sidebar`, `navigation-menu`, `breadcrumb`, `tabs`, `pagination` |
| Loading and empty states | `skeleton`, `spinner`, `progress`, `empty` |
| Feedback | `alert` (inline), `sonner` (toast) |
| Layout | `separator`, `aspect-ratio`, `scroll-area`, `resizable`, `accordion`, `collapsible` |
| Command palette | `command` inside `dialog` |
| Charts | `chart` |
| Keyboard shortcut | `kbd` |
| Full dashboard scaffold | `sidebar-01` |

Unsure between neighbours? `bin/shadwire info <name>` prints a `When to use` line
that names the alternatives.

## Workflow

1. **Read the project context above.** Know what is installed before planning.
2. **Find the component** — `bin/shadwire search <term>`. Search matches the
   when-to-use text, so terms like `form`, `modal`, `loading` work.
3. **Read its API before writing ERB** — `bin/shadwire info <name> --json`. This gives
   the exact helper names, variants, sizes and props. Do not guess a prop.
4. **Install** — `bin/shadwire add <name> --yes`. Registry dependencies come along
   automatically.
5. **Trust the exit code.** A non-zero exit means something did not land — most
   often `bundle add` — and the message says how to recover. Do not carry on
   as if it had succeeded.
6. **Re-read context** — `bin/shadwire status --json` to confirm the new helpers.
7. **Write the view**, following the Critical Rules.
8. **Check your work** — render the page or run the app's component tests.

## Editing installed components

The files are the app's. Edit them directly — that is the Open Code model.

`bin/shadwire diff` reports how they have drifted from the registry. Run it **before**
`bin/shadwire update`: update overwrites. It does tell you what it replaced —
`overwritten` and `diffs` in the JSON payload — but that is after the fact. See
[cli.md](./cli.md).

## Quick Reference

```bash
bin/shadwire status --json           # project context: stack, installed, helpers, drift
bin/shadwire search <term>           # find a component by name, description or use
bin/shadwire info <name> --json      # full API: helpers, variants, sizes, props, usage
bin/shadwire add <name> --yes        # install, with registry dependencies
bin/shadwire list                    # whole catalog
bin/shadwire diff [name]             # local drift vs the registry
bin/shadwire diff --exit-code        # non-zero when drift exists (CI)
bin/shadwire update [name] --yes     # re-apply the registry version (overwrites!)
bin/shadwire remove <name> --yes     # uninstall, keeping shared and still-used files
```

Every command takes `--cwd DIR` to target another app and `--registry URL` to
read from a different registry.

## Detailed References

- [cli.md](./cli.md) — every command, flag, and the known CLI gaps to work around
- [theming.md](./theming.md) — tokens, dark mode, custom colors
- [rules/composition.md](./rules/composition.md) — subcomponents, groups, titles
- [rules/styling.md](./rules/styling.md) — tokens, class precedence, attributes
- [rules/forms.md](./rules/forms.md) — the field family, Rails form integration
- [rules/icons.md](./rules/icons.md) — lucide-rails usage
