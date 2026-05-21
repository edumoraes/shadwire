# Shadwire

Shadwire ports the shadcn/ui Open Code model to Ruby on Rails.

The source of truth is `registry/`. The Rails app in `sandbox/` consumes copied registry files so components are validated in a real Rails, ViewComponent, Tailwind CSS v4, and Hotwire environment.

## Components

The MVP includes:

- `Ui::ButtonComponent`
- `Ui::BadgeComponent`
- `Ui::CardComponent`
- `Ui::Card::HeaderComponent`
- `Ui::Card::TitleComponent`
- `Ui::Card::DescriptionComponent`
- `Ui::Card::ContentComponent`
- `Ui::Card::FooterComponent`
- `Ui::AlertComponent`
- `Ui::SeparatorComponent`
- `Ui::AvatarComponent`
- `Ui::IconComponent`

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
