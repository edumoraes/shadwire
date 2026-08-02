# Theming

## Where the tokens live

`vendor/shadwire/shadwire.css`, installed by `shadwire init` and imported from
the app's Tailwind entrypoint (`app/assets/tailwind/application.css` by default —
`status.tailwind.css` reports the actual path).

The file has three layers:

```css
@custom-variant dark (&:is(.dark *));   /* class-based dark mode */

@theme inline {                          /* maps tokens to Tailwind utilities */
  --color-background: var(--background);
  --color-primary: var(--primary);
  ...
}

:root { --background: oklch(1 0 0); ... }   /* light values */
.dark { --background: oklch(0.145 0 0); ... }  /* dark values */
```

`@theme inline` is what turns `--primary` into the `bg-primary` /
`text-primary` utilities. Colors are OKLCH.

**Edit `:root` and `.dark` to retheme.** Never edit `@theme inline` — that is
plumbing.

## Dark mode is class-based

The `dark` variant triggers on an ancestor with `.dark`, so toggling the theme
means toggling that class on `<html>` or `<body>`.

Because every component uses tokens, dark mode needs no work in component code.
That is why hardcoded `dark:` color overrides are a rule violation — see
[rules/styling.md](./rules/styling.md).

## The tokens

| Token | Controls | Used by |
| --- | --- | --- |
| `background` / `foreground` | App background and default text | Page shell, sections, default text |
| `card` / `card-foreground` | Elevated surfaces | Card, dashboard and settings panels |
| `popover` / `popover-foreground` | Floating surfaces | Popover, DropdownMenu, ContextMenu, overlays |
| `primary` / `primary-foreground` | High-emphasis actions, brand | Default Button, selected states, badges |
| `secondary` / `secondary-foreground` | Lower-emphasis filled actions | Secondary buttons and badges |
| `muted` / `muted-foreground` | Subtle surfaces, secondary content | Descriptions, placeholders, empty states, helper text |
| `accent` / `accent-foreground` | Hover, focus, active surfaces | Ghost buttons, menu highlights, hovered rows |
| `destructive` / `destructive-foreground` | Destructive actions, errors | Destructive buttons, invalid states |
| `border` | Borders and separators | Cards, menus, tables, dividers |
| `input` | Form control borders | Input, Textarea, Select, outline controls |
| `ring` | Focus rings | Buttons, inputs, checkboxes, menus |
| `chart-1` … `chart-5` | Chart palette | Charts and chart-driven blocks |
| `sidebar` / `sidebar-foreground` | Sidebar surface and text | Sidebar container |
| `sidebar-primary` / `-foreground` | High-emphasis sidebar actions | Active items, icon tiles, CTAs |
| `sidebar-accent` / `-foreground` | Sidebar hover and selected | Menu hover, open items |
| `sidebar-border` | Sidebar borders | Sidebar headers, groups, dividers |
| `sidebar-ring` | Sidebar focus rings | Focused sidebar controls |
| `radius` | Base corner radius | Cards, inputs, buttons, popovers |

Every surface token has a matching `-foreground`. Use them as a pair:
`bg-muted text-muted-foreground`, never `bg-muted` with default text.

## Changing the brand color

Set `--primary` and `--primary-foreground` in both blocks:

```css
:root {
  --primary: oklch(0.55 0.22 264);
  --primary-foreground: oklch(0.98 0 0);
}

.dark {
  --primary: oklch(0.7 0.19 264);
  --primary-foreground: oklch(0.15 0 0);
}
```

Nothing else changes — every component that used `bg-primary` follows.

Pick the foreground for contrast against its surface, and check both modes.

## Adding a new token

Add the variable to both blocks, then map it in `@theme inline` so Tailwind
generates utilities:

```css
@theme inline {
  --color-success: var(--success);
  --color-success-foreground: var(--success-foreground);
}

:root {
  --success: oklch(0.72 0.19 145);
  --success-foreground: oklch(0.98 0 0);
}

.dark {
  --success: oklch(0.65 0.17 145);
  --success-foreground: oklch(0.15 0 0);
}
```

`bg-success` and `text-success-foreground` are then usable like any other token.

## Radius

`--radius` drives the derived `radius-sm` / `radius-md` / `radius-lg` scale, so
changing it reshapes cards, inputs, buttons and popovers together.

```css
:root { --radius: 0.75rem; }
```

## Adding a variant to a component

Variants are frozen Ruby hashes in the component class. Since the app owns the
file, add a key:

```ruby
# app/components/ui/button_component.rb
VARIANTS = {
  default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
  success: "bg-success text-success-foreground shadow-xs hover:bg-success/90",
  ...
}.freeze
```

```erb
<%= ui_button(variant: :success) { "Publish" } %>
```

This is a local edit, so `bin/shadwire diff` will report the file as `modified` and
`bin/shadwire update` would overwrite it. That is expected — see
[cli.md](./cli.md).

## Keeping edits through updates

1. `bin/shadwire diff <name>` — see exactly what you changed.
2. `bin/shadwire update <name>` **without** `--yes` — it prompts per modified file
   and shows the diff.
3. Re-apply your edits on top.

Prefer additive changes (a new variant key, a new token) over rewriting existing
classes: they survive updates with less conflict.
