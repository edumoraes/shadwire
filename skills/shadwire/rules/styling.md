# Styling

## Semantic tokens only

Every color comes from a shadcn semantic token so light and dark mode, and any
retheme, work without touching component code.

```erb
<%# Wrong — hardcoded colors, and a manual dark override %>
<%= ui_card(class: "bg-white text-gray-900 dark:bg-gray-900 dark:text-white") do %>
```

```erb
<%# Right — the tokens already handle both modes %>
<%= ui_card do %>
```

Pairs are `<surface>` / `<surface>-foreground`: `bg-primary text-primary-foreground`,
`bg-muted text-muted-foreground`, `bg-destructive text-destructive-foreground`.
Full table in [../theming.md](../theming.md).

Never write `dark:` variants for color. Write them only for genuinely
mode-specific non-color choices (a different image, say).

## `class:` and `class_name:` are equivalent

Both normalize to the same value. Use whichever reads better; `class:` is more
Rails-idiomatic.

```erb
<%= ui_button(class: "w-full") { "Save" } %>
<%= ui_button(class_name: "w-full") { "Save" } %>
```

## Your classes always win

Classes compose in this order, with yours last:

```text
base_classes → variant_classes → size_classes → your class
```

So `class:` reliably overrides the component's own utilities. That is also why
you should not use it to restyle:

```erb
<%# Wrong — fighting the design system %>
<%= ui_button(class: "bg-red-600 hover:bg-red-700") { "Delete" } %>
```

```erb
<%# Right — the variant exists %>
<%= ui_button(variant: :destructive) { "Delete" } %>
```

Use `class:` for **layout** — width, margin, grid placement:

```erb
<%= ui_button(variant: :outline, class: "w-full sm:w-auto") { "Save" } %>
```

## Free HTML attributes pass through

Anything that is not a known prop forwards to the rendered element, including
Rails' nested hashes.

```erb
<%= ui_button(id: "save", data: { turbo: false, controller: "form" },
              "aria-describedby": "hint") { "Save" } %>
```

```erb
<%# Works with Turbo, Stimulus and standard Rails helpers %>
<%= ui_button(tag: :a, href: post_path(post), data: { turbo_method: :delete }) { "Delete" } %>
```

Use `tag:` to change the rendered element where a component supports it — `button`
renders a `<button>` by default and an `<a>` with `tag: :a`.

## Prefer variants and sizes over utilities

Check what exists before writing classes:

```bash
bin/shadwire info button
#   variants: default | destructive | outline | secondary | ghost | link
#   sizes:    default | sm | lg | icon
```

```erb
<%# Wrong %>
<%= ui_button(class: "h-8 px-3 text-xs border") { "Small" } %>
```

```erb
<%# Right %>
<%= ui_button(variant: :outline, size: :sm) { "Small" } %>
```

## Tailwind utility conventions

Match what the components themselves do:

- `size-9` rather than `h-9 w-9` when width and height match.
- `gap-*` with flex or grid rather than `space-x-*` / `space-y-*`.
- `truncate` rather than `overflow-hidden text-ellipsis whitespace-nowrap`.
- No manual `z-index` on overlays — dialog, sheet, popover and dropdown-menu
  manage their own stacking.
