# Shadwire

Shadwire ports the shadcn/ui Open Code model to Ruby on Rails.

The source of truth is `registry/`. The Rails app in `sandbox/` consumes copied registry files so components are validated in a real Rails, ViewComponent, Tailwind CSS v4, and Hotwire environment.

## Documentation

The docs site is <https://shadwire.edumoraes.dev.br> — it *is* the sandbox app,
frozen to static HTML, so every live example on it is a real render.

| Page | What it covers |
| --- | --- |
| [Introduction](https://shadwire.edumoraes.dev.br/docs) | The Open Code model, how the registry / CLI / app fit together |
| [Installation](https://shadwire.edumoraes.dev.br/docs/installation) | Requirements, installing the CLI, what `init` does, the first component |
| [shadwire.json](https://shadwire.edumoraes.dev.br/docs/configuration) | The manifest: registry, aliases, Tailwind entrypoint, installed inventory |
| [Theming](https://shadwire.edumoraes.dev.br/docs/theming) | Tokens, brand color, adding a token, keeping local edits through updates |
| [Dark mode](https://shadwire.edumoraes.dev.br/docs/dark-mode) | Class-based dark mode, the toggle, the anti-flash script |
| [CLI](https://shadwire.edumoraes.dev.br/docs/cli) | Every command and flag, the `status` payload, errors and exit codes, CI |
| [Agent skill](https://shadwire.edumoraes.dev.br/docs/agent-skill) | What the skill carries, how it injects project context, permissions |
| [Registry](https://shadwire.edumoraes.dev.br/docs/registry) | The published JSON format and how to serve your own |
| [llms.txt](https://shadwire.edumoraes.dev.br/docs/llms-txt) | The plain-text catalog for agents without the skill |
| [Composition](https://shadwire.edumoraes.dev.br/docs/composition) · [Styling](https://shadwire.edumoraes.dev.br/docs/styling) · [Forms](https://shadwire.edumoraes.dev.br/docs/forms) · [Icons](https://shadwire.edumoraes.dev.br/docs/icons) · [Accessibility](https://shadwire.edumoraes.dev.br/docs/accessibility) | The conventions, with wrong/right pairs |

The pages are written in Portuguese; the CLI, the agent skill and this README are
in English.

## Components

58 components, listed with `shadwire list`. Search by what you need
(`shadwire search form`), then read a component API with `shadwire info button`.

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
| `chart` | Chart.js charts using the Shadwire theme tokens. |
| `data-table` | A table with sorting, filtering, pagination, and row selection. |

Helpers use the `ui_*` prefix.

```erb
<%= render Ui::ButtonComponent.new(variant: :outline, size: :sm) do %>
  Save
<% end %>

<%= ui_button(variant: :outline, size: :sm) { "Save" } %>
```

Icons are rendered with [lucide-rails](https://github.com/heyvito/lucide-rails)
(add `gem "lucide-rails"` to the consuming app). Compose them inside other
components:

```erb
<%= ui_button { (ui_icon("download") + " Download").html_safe } %>
<%= ui_button(size: :icon) { ui_icon("plus", label: "Add item") } %>
```

## CLI

Shadwire ships a `shadwire` CLI (`packages/cli/`) that installs component source
into a Rails app and keeps it in sync with the registry — the shadcn Open Code
flow. Installed files are yours; there is no runtime dependency on Shadwire.

Install it globally, or add it to the consuming app directly:

```bash
gem install shadwire                       # global — bootstrap with `shadwire init`
bundle add shadwire --group development    # in the app — bootstrap with `bundle exec shadwire init`
```

Bootstrap once. `init` adds `shadwire` to the app's `development` group (if it is
not there already) and writes the `bin/shadwire` binstub. That binstub is how you
run the CLI from then on — one entry point, pinned to the app's bundle:

```bash
shadwire init                     # writes shadwire.json + base files + bin/shadwire
bin/shadwire add button dialog    # installs components and their registry dependencies
bin/shadwire list                 # every component in the registry catalog
```

`init` is the one command you run un-prefixed, because it is what creates the
binstub. Use `bundle exec shadwire init` when the gem is in the Gemfile rather
than installed globally.

Components install from the hosted registry
(`https://shadwire.edumoraes.dev.br/r`) by default; override with `--registry`
(an `https://` URL or a local `file://` path).

**Agents / CI** — every command runs non-interactively with `--yes`, emits
machine-readable output with `--json`, and can target another app with `--cwd`.
`bin/shadwire status --json` reports the whole install in one call, and
`bin/shadwire diff --exit-code` exits non-zero when an installed file has drifted
from the registry, so CI can fail on drift. See
[`packages/cli/README.md`](packages/cli/README.md) for the full command reference.

## Agent skill

Coding agents — Claude Code, Codex, Cursor, OpenCode and ~20 others — can install
the Shadwire skill for full context on the CLI and components:

```bash
npx skills add edumoraes/shadwire
```

The skill lives in [`skills/shadwire/`](skills/shadwire/). It carries workflow and
conventions, not data: component names, variants, props and helper names are
pulled at runtime from `bin/shadwire status --json` and `bin/shadwire info --json`,
so it always reflects what is actually installed. CI verifies that everything the
skill names still exists.

The skill's `allowed-tools` grant covers only the turn that invokes it, so it
stops the permission prompts for that turn and no longer. To silence them for
good, add an allow rule to the consuming app's `.claude/settings.json`:

```json
{ "permissions": { "allow": ["Bash(bin/shadwire *)"] } }
```

Agents that cannot install the skill can read the same catalog as plain text:

- [`/r/llms.txt`](https://shadwire.edumoraes.dev.br/r/llms.txt) — every
  component with when to use it
- [`/r/llms-full.txt`](https://shadwire.edumoraes.dev.br/r/llms-full.txt) —
  every component's full API and usage

## Registry Workflow

Edit source files in `registry/rails/ui`.

Sync registry files into the sandbox:

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

Theme tokens live in `registry/rails/ui/styles/shadwire.css` under `:root` and
`.dark`. Tailwind v4 reads them through `@theme inline`, so component classes
should use semantic utilities such as `bg-primary`, `text-muted-foreground`,
`border-input`, and `ring-ring` instead of hardcoded colors.

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
| `cn(...)` and `className` | `class_names(..., @class_name)` |
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
