# Icons

Icons come from [lucide-rails](https://github.com/heyvito/lucide-rails), the Rails
port of Lucide — shadcn/ui's icon set. `ui_icon` wraps its `lucide_icon` helper
with shadcn size variants.

The consuming app must have `gem "lucide-rails"`. `shadwire init` adds it;
`shadwire status --json` reports it under `gems`.

## Names are Lucide kebab-case

```erb
<%# Wrong — React component names do not exist here %>
<%= ui_icon("ChevronDown") %>
<%= ui_icon(:chevron_down) %>
```

```erb
<%# Right %>
<%= ui_icon("chevron-down") %>
```

Browse names at <https://lucide.dev/icons>.

## Sizes

`sm` (`size-3`), `default` (`size-4`), `lg` (`size-5`), `xl` (`size-6`).

```erb
<%= ui_icon("check", size: :sm) %>
```

Prefer these over `class: "w-3 h-3"`.

## Icons are decorative by default

`ui_icon` renders `aria-hidden="true"`, which is correct next to a text label —
the text already names the control.

```erb
<%# Right — the word "Download" is the label; the icon is decoration %>
<%= ui_button { safe_join([ui_icon("download"), " Download"]) } %>
```

When the icon is the *only* content, it must carry the name. Pass `label:`, which
sets `role="img"` and `aria-label`, and cancels `aria-hidden`:

```erb
<%# Wrong — an icon-only button with no accessible name %>
<%= ui_button(size: :icon) { ui_icon("trash-2") } %>
```

```erb
<%# Right %>
<%= ui_button(size: :icon) { ui_icon("trash-2", label: "Delete") } %>
```

Labelling the button instead is equally fine — do one or the other, not neither:

```erb
<%= ui_button(size: :icon, "aria-label": "Delete") { ui_icon("trash-2") } %>
```

## Compose icons; there is no `icon:` prop

No component takes an icon as a prop. Put the icon in the content, shadcn-style.

```erb
<%# Wrong — no such prop exists on any component %>
<%= ui_button(icon: "plus") { "Add" } %>
```

```erb
<%# Right %>
<%= ui_button { safe_join([ui_icon("plus"), " Add"]) } %>
```

`ButtonComponent` carries `[&_svg]` utilities, so a nested icon is sized and
spaced correctly without extra classes. Use `size: :icon` for icon-only buttons.

## Combining an icon with text

Both parts must be `html_safe`, so join them rather than concatenating strings:

```erb
<%= ui_button { safe_join([ui_icon("save"), " Save"]) } %>
```

`ui_icon("save") + " Save"` also works, since the icon is already safe — but
`safe_join` states the intent and handles interpolated user content correctly.
