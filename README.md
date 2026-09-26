# Shadwire

Shadwire is shadcn/ui for Ruby on Rails. The components are ViewComponent
classes styled with Tailwind CSS v4, and like shadcn/ui they are not a
dependency: a CLI copies their source into your app, and from then on the code is
yours to change.

Component source lives in `registry/`. The Rails app in `sandbox/` runs copies of
those files, so every component is tested in a real Rails app with ViewComponent,
Tailwind CSS v4 and Hotwire.

## Documentation

The docs are at <https://shadwire.edumoraes.dev.br>. The site is the sandbox app
exported to static HTML, so the examples on it are rendered by the components
themselves.

| Page | What it covers |
| --- | --- |
| [Introduction](https://shadwire.edumoraes.dev.br/docs) | The Open Code model, and how the registry, the CLI and your app fit together |
| [Installation](https://shadwire.edumoraes.dev.br/docs/installation) | Requirements, installing the CLI, what `init` does, the first component |
| [shadwire.json](https://shadwire.edumoraes.dev.br/docs/configuration) | The manifest: registry, aliases, Tailwind entrypoint, installed inventory |
| [Theming](https://shadwire.edumoraes.dev.br/docs/theming) | Tokens, brand color, adding a token, keeping local edits through updates |
| [Dark mode](https://shadwire.edumoraes.dev.br/docs/dark-mode) | Class-based dark mode, the toggle, the anti-flash script |
| [CLI](https://shadwire.edumoraes.dev.br/docs/cli) | Every command and flag, the `status` payload, errors and exit codes, CI |
| [Agent skill](https://shadwire.edumoraes.dev.br/docs/agent-skill) | What the skill contains, how it loads project context, permissions |
| [Registry](https://shadwire.edumoraes.dev.br/docs/registry) | The published JSON format and how to serve your own |
| [llms.txt](https://shadwire.edumoraes.dev.br/docs/llms-txt) | The plain-text catalog for agents without the skill |
| [Composition](https://shadwire.edumoraes.dev.br/docs/composition) · [Styling](https://shadwire.edumoraes.dev.br/docs/styling) · [Forms](https://shadwire.edumoraes.dev.br/docs/forms) · [Icons](https://shadwire.edumoraes.dev.br/docs/icons) · [Accessibility](https://shadwire.edumoraes.dev.br/docs/accessibility) | The conventions, each with a wrong and a right example |

The site is in English, with a Portuguese translation under
[`/pt`](https://shadwire.edumoraes.dev.br/pt/docs).

## Components

57 components and one block. `shadwire list` prints the same list,
`shadwire search form` finds components by what they are for, and
`shadwire info button` shows a component's API.

| Component | Description |
| --- | --- |
| `button` | Displays a button or a link styled as a button. |
| `badge` | A small inline label for status, counts, or categories. |
| `card` | A container for grouping related content with header, body, and footer slots. |
| `alert` | A callout for important inline messages. |
| `separator` | A thin rule that visually divides content. |
| `avatar` | A user or entity image with a text fallback. |
| `accordion` | Vertically stacked sections that expand and collapse. |
| `scroll-area` | A scrollable region with styled scrollbars. |
| `icon` | A Lucide icon with shadcn-style size variants. |
| `input` | A single-line text field. |
| `label` | An accessible caption bound to a form control. |
| `textarea` | A multi-line text field. |
| `checkbox` | A binary control for opting in or selecting many items. |
| `radio-group` | A set of mutually exclusive options. |
| `switch` | A toggle for a setting that takes effect immediately. |
| `skeleton` | A placeholder block shown while content loads. |
| `progress` | A bar showing completion toward a known total. |
| `table` | A styled HTML table with header, body, and footer sections. |
| `breadcrumb` | A trail showing the current page's position in the hierarchy. |
| `pagination` | Navigation controls for moving between pages of results. |
| `tabs` | Switches between peer views in the same space. |
| `dialog` | A modal window overlaying the page. |
| `alert-dialog` | A modal that interrupts the user to confirm a consequential action. |
| `sheet` | A panel that slides in from an edge of the screen. |
| `tooltip` | A short hint shown on hover or focus. |
| `popover` | A floating panel anchored to a trigger. |
| `dropdown-menu` | A menu of actions or options triggered by a button. |
| `select` | A styled control for choosing one option from a list. |
| `sidebar` | A composable, collapsible application sidebar. |
| `sidebar-01` | A documentation-style dashboard layout with a collapsible sidebar, version switcher, and search. |
| `aspect-ratio` | Constrains its content to a fixed width-to-height ratio. |
| `spinner` | An indeterminate loading indicator. |
| `kbd` | Displays a keyboard key or shortcut. |
| `empty` | A placeholder for when there is nothing to show. |
| `item` | A compact row with media, text, and trailing actions. |
| `input-group` | An input with attached addons, text, or buttons. |
| `button-group` | Related buttons joined into a single control. |
| `field` | Form field layout with label, description, and error message. |
| `native-select` | The browser's native select element, styled to match. |
| `collapsible` | A single region that expands and collapses. |
| `toggle` | A two-state button that stays pressed. |
| `toggle-group` | A set of toggle buttons acting as one control. |
| `slider` | Selects a numeric value from a range by dragging. |
| `hover-card` | A rich preview card shown on hover. |
| `input-otp` | A segmented field for one-time passcodes. |
| `drawer` | A panel that slides up from the bottom of the screen. |
| `context-menu` | A menu opened by right-clicking a region. |
| `menubar` | A horizontal application menu bar. |
| `navigation-menu` | Site navigation with optional rich dropdown panels. |
| `command` | A searchable, keyboard-driven list of commands. |
| `calendar` | A month grid for selecting a date or a date range. |
| `resizable` | Panels the user can resize by dragging a handle. |
| `carousel` | A horizontally or vertically swipeable set of slides. |
| `combobox` | A searchable single-select built from popover, command, and button. |
| `date-picker` | A date field that opens a calendar in a popover. |
| `sonner` | Transient toast notifications. |
| `chart` | Composable charts drawn with D3: bars, lines, areas, pies, radars and radial bars, with a tooltip and a legend, in the Shadwire theme tokens. |
| `data-table` | A table with sorting, filtering, pagination, and row selection. |

Every component has a `ui_*` helper. Both forms below render the same button:

```erb
<%= render Ui::ButtonComponent.new(variant: :outline, size: :sm) do %>
  Save
<% end %>

<%= ui_button(variant: :outline, size: :sm) { "Save" } %>
```

Icons come from [lucide-rails](https://github.com/heyvito/lucide-rails), so the
app needs `gem "lucide-rails"`. Put them inside other components:

```erb
<%= ui_button { (ui_icon("download") + " Download").html_safe } %>
<%= ui_button(size: :icon) { ui_icon("plus", label: "Add item") } %>
```

## CLI

The `shadwire` CLI (`packages/cli/`) copies component source into a Rails app and
helps you keep it in sync with the registry, the same way the shadcn CLI works.
The app does not depend on Shadwire at runtime.

Install it globally, or add it to the app:

```bash
gem install shadwire                       # global — bootstrap with `shadwire init`
bundle add shadwire --group development    # in the app — bootstrap with `bundle exec shadwire init`
```

Run `init` once. It adds `shadwire` to the app's `development` group if it is not
there yet and writes a `bin/shadwire` binstub. Use the binstub from then on: it
runs the CLI version from the app's bundle, so everyone on the project gets the
same one.

```bash
shadwire init                     # writes shadwire.json + base files + bin/shadwire
bin/shadwire add button dialog    # installs components and their registry dependencies
bin/shadwire list                 # every component in the registry catalog
```

`init` is the only command you run without the `bin/` prefix, since the binstub
does not exist yet. If you added the gem to the Gemfile instead of installing it
globally, run `bundle exec shadwire init`.

By default components come from the hosted registry
(`https://shadwire.edumoraes.dev.br/r`). Pass `--registry` with an `https://` URL
or a local `file://` path to use another one.

For agents and CI, every command accepts `--yes` (no prompts), `--json`
(machine-readable output) and `--cwd` (run against another directory).
`bin/shadwire status --json` describes the whole install in one call, and
`bin/shadwire diff --exit-code` exits non-zero when an installed file no longer
matches the registry, which lets a CI job fail on it. The full command reference
is in [`packages/cli/README.md`](packages/cli/README.md).

## Agent skill

Coding agents (Claude Code, Codex, Cursor, OpenCode and about 20 others) can
install the Shadwire skill, which teaches them the CLI and the components:

```bash
npx skills add edumoraes/shadwire
```

The skill is in [`skills/shadwire/`](skills/shadwire/). It describes the workflow
and the conventions, but it does not list components: the agent reads names,
variants, props and helpers from `bin/shadwire status --json` and
`bin/shadwire info --json`, so what it sees matches what the app has installed.
CI checks that every helper and command the skill mentions still exists.

The skill's `allowed-tools` only applies to the turn that loads it, so the
permission prompts come back afterwards. To turn them off for good, add an allow
rule to the app's `.claude/settings.json`:

```json
{ "permissions": { "allow": ["Bash(bin/shadwire *)"] } }
```

Agents that cannot install the skill can read the catalog as plain text:

- [`/r/llms.txt`](https://shadwire.edumoraes.dev.br/r/llms.txt): each component
  and when to use it
- [`/r/llms-full.txt`](https://shadwire.edumoraes.dev.br/r/llms-full.txt): each
  component's full API and usage examples

## Registry Workflow

Edit component source in `registry/rails/ui`, then copy it into the sandbox:

```bash
bin/sync_registry
```

Run all tests:

```bash
rake test
```

Run sandbox tests only:

```bash
cd sandbox
bin/rails test test/components test/integration/ui_accessibility_test.rb
```

## Theme Tokens

The theme tokens are CSS variables in `registry/rails/ui/styles/shadwire.css`,
under `:root` and `.dark`. Tailwind v4 reads them through `@theme inline`, so
components use semantic classes like `bg-primary`, `text-muted-foreground`,
`border-input` and `ring-ring` instead of fixed colors.

| Token | What it controls | Used by |
| --- | --- | --- |
| `background` / `foreground` | Default app background and text color. | Page shell, page sections, and default text. |
| `card` / `card-foreground` | Elevated surfaces and the content inside them. | Card, dashboard panels, and settings panels. |
| `popover` / `popover-foreground` | Floating surfaces and the content inside them. | Popover, DropdownMenu, ContextMenu, and other overlays. |
| `primary` / `primary-foreground` | High-emphasis actions and brand surfaces. | Default Button, selected states, badges, and active accents. |
| `secondary` / `secondary-foreground` | Lower-emphasis filled actions and supporting surfaces. | Secondary buttons, secondary badges, and supporting UI. |
| `muted` / `muted-foreground` | Subtle surfaces and lower-emphasis content. | Descriptions, placeholders, empty states, helper text, and subdued surfaces. |
| `accent` / `accent-foreground` | Interactive hover, focus, and active surfaces. | Ghost buttons, menu highlight states, hovered rows, and selected items. |
| `destructive` / `destructive-foreground` | Destructive actions and error emphasis. | Destructive buttons, invalid states, and destructive menu items. |
| `border` | Default borders and separators. | Cards, menus, tables, separators, and layout dividers. |
| `input` | Form control borders and input surface treatment. | Input, Textarea, Select, and outline-style controls. |
| `ring` | Focus rings and outlines. | Buttons, inputs, checkboxes, menus, and other focusable controls. |
| `chart-1` ... `chart-5` | Default chart palette. | Charts and chart-driven dashboard blocks. |
| `sidebar` / `sidebar-foreground` | Base sidebar surface and default sidebar text. | Sidebar container and its default content. |
| `sidebar-primary` / `sidebar-primary-foreground` | High-emphasis actions inside the sidebar. | Active items, icon tiles, badges, and sidebar CTAs. |
| `sidebar-accent` / `sidebar-accent-foreground` | Hover and selected states inside the sidebar. | Sidebar menu hover states, open items, and interactive rows. |
| `sidebar-border` | Sidebar-specific borders and separators. | Sidebar headers, groups, and internal dividers. |
| `sidebar-ring` | Sidebar-specific focus rings. | Focused controls inside the sidebar. |
| `radius` | Base corner radius scale. | Cards, inputs, buttons, popovers, and derived `radius-*` tokens. |

## Translation Rules

| shadcn / React concept | Shadwire / Rails equivalent |
| --- | --- |
| Base class string | `base_classes` method |
| `cva` variants | frozen Ruby hashes |
| `cn(...)` and `className` | `class_names(..., @class_name)` — `UiComponent` merges Tailwind conflicts the same way |
| React props | `initialize(...)` keyword arguments |
| `children` | `content` |
| `asChild` | configurable `tag:` or conditional rendering |
| Radix/Base behavior | native HTML, Stimulus, or Hotwire |

## Commits

Use Conventional Commits:

```bash
git commit -m "feat: add button component"
git commit -m "test: cover card component"
git commit -m "docs: update registry workflow"
```

## License

MIT. See [LICENSE](LICENSE).

The components the CLI installs in your app are yours. You can change them and
ship them in commercial or closed-source products, without adding attribution to
the installed files.

Shadwire is a port of [shadcn/ui](https://ui.shadcn.com), which is also MIT
licensed. Its notice, and the licenses of the libraries an installed component
uses, are in [NOTICE](NOTICE).
