# Shadwire

Shadwire ports the shadcn/ui Open Code model to Ruby on Rails.

The source of truth is `registry/`. The Rails app in `sandbox/` consumes copied registry files so components are validated in a real Rails, ViewComponent, Tailwind CSS v4, and Hotwire environment.

## Components

The registry currently includes:

- `Ui::AccordionComponent`
- `Ui::AlertComponent`
- `Ui::AlertDialogComponent`
- `Ui::AvatarComponent`
- `Ui::BadgeComponent`
- `Ui::BreadcrumbComponent`
- `Ui::ButtonComponent`
- `Ui::CardComponent`
- `Ui::CheckboxComponent`
- `Ui::DialogComponent`
- `Ui::DropdownMenuComponent`
- `Ui::IconComponent`
- `Ui::InputComponent`
- `Ui::LabelComponent`
- `Ui::PaginationComponent`
- `Ui::PopoverComponent`
- `Ui::ProgressComponent`
- `Ui::RadioGroupComponent`
- `Ui::ScrollAreaComponent`
- `Ui::SelectComponent`
- `Ui::SeparatorComponent`
- `Ui::SheetComponent`
- `Ui::SkeletonComponent`
- `Ui::SwitchComponent`
- `Ui::TableComponent`
- `Ui::TabsComponent`
- `Ui::TextareaComponent`
- `Ui::TooltipComponent`

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
