# Shadwire MVP Design

Date: 2026-05-21

## Purpose

Shadwire ports the shadcn/ui approach to Ruby on Rails. It provides open, copyable Rails component source code that can be installed into an application and customized there, while preserving the core shadcn principles:

- Open Code: the app owns the copied component files.
- Composition: components expose predictable, composable APIs.
- Distribution: a registry schema lists installable files and dependencies.
- Beautiful Defaults: Tailwind defaults match the shadcn visual system.
- AI-Ready: files are flat, readable, and consistent enough for LLMs to inspect and modify.

The MVP builds the foundation for that system. It does not implement the full CLI yet.

## Scope

The MVP includes:

- A monorepo structure.
- A registry as the source of truth for distributable Rails component files.
- A Rails sandbox application as the validation and documentation consumer.
- Six initial components: Button, Badge, Card, Alert, Separator, and Avatar.
- ViewComponent classes as the primary component API.
- `ui_*` helpers as convenience wrappers.
- Tailwind CSS v4 styling.
- Hotwire-compatible architecture, with Stimulus reserved for future interactive components.
- ViewComponent render tests and basic accessibility checks.

The MVP excludes:

- A production CLI implementation.
- Automated upstream shadcn conversion.
- Complex interactive components such as Dialog, DropdownMenu, Tabs, Accordion, Popover, and Select.
- Runtime gem/engine distribution.

## Architecture

The repository is a monorepo. The root is not the Rails app.

```text
registry/
  registry.json
  rails/
    ui/
      components/
        button_component.rb
        badge_component.rb
        alert_component.rb
        separator_component.rb
        avatar_component.rb
        card_component.rb
        card/header_component.rb
        card/title_component.rb
        card/description_component.rb
        card/content_component.rb
        card/footer_component.rb
      helpers/
        ui_helper.rb
      styles/
        shadwire.css
      javascript/
        controllers/
          .keep

sandbox/
  app/
    components/ui/...
    helpers/ui_helper.rb
  test/components/...
  test/system_or_accessibility/...
  config/...

packages/
  cli/

docs/
  superpowers/specs/...
```

`registry/` is the source of truth. Component source files are edited there first.

`sandbox/` is a Rails app that consumes the registry files by local copy or sync. It proves the registry works in a real Rails, ViewComponent, Tailwind v4, and Hotwire environment.

`packages/cli/` is reserved for the future CLI, but the MVP should shape `registry.json` so a CLI can later install the same files without redesigning the registry.

## Component Model

Components use the `Ui` namespace in consuming Rails apps:

```erb
<%= render Ui::ButtonComponent.new(variant: :outline, size: :sm) do %>
  Save
<% end %>

<%= ui_button(variant: :outline, size: :sm) { "Save" } %>
```

ViewComponent classes are the official API. Helpers are thin convenience wrappers.

The install paths in a Rails app follow this convention:

```text
app/components/ui/button_component.rb
app/components/ui/badge_component.rb
app/components/ui/alert_component.rb
app/components/ui/separator_component.rb
app/components/ui/avatar_component.rb

app/components/ui/card_component.rb
app/components/ui/card/header_component.rb
app/components/ui/card/title_component.rb
app/components/ui/card/description_component.rb
app/components/ui/card/content_component.rb
app/components/ui/card/footer_component.rb
```

Future components follow the same flat root plus nested subcomponent convention, for example `app/components/ui/input_component.rb` or `app/components/ui/dialog/content_component.rb`.

The MVP includes `Button`, `Badge`, `Card`, `Alert`, `Separator`, and `Avatar`. Helpers cover root components and the most common composed subcomponents. Helper coverage can expand as real usage requires it.

## Rendering Rules

Rendering is hybrid:

- Start with one Ruby file and a `call` method.
- Use `call` for primitives, small HTML, and components that only assemble tag names, attributes, and classes.
- Add an ERB template only when structure, conditionals, slots, or nested content would make `call` hard to read.
- Use subcomponents when the source shadcn component has named parts.

Examples of named parts include:

- `Card.Header`
- `Card.Title`
- `Card.Description`
- `Card.Content`
- `Card.Footer`
- Future `Dialog.Content`
- Future `Tabs.List`
- Future `Dropdown.Item`

## Translation Rules

The project uses these React-to-Rails translation rules:

| shadcn / React concept | Shadwire / Rails equivalent |
| --- | --- |
| Base class string | `base_classes` method |
| `cva` variants | frozen Ruby hashes |
| `cn(...)` and `className` | `class_names(..., @class_name)` |
| React props | `initialize(...)` keyword arguments |
| `children` | `content` |
| `asChild` | configurable `tag:` or conditional rendering |
| Radix/Base behavior | native HTML, Stimulus, or Hotwire, depending on need |

Components accept both `class_name:` and `class:`. Internally they normalize those values into `@class_name`.

Free HTML attributes are accepted through `**attrs` and passed to the rendered tag. Rails-style nested attributes such as `data: { turbo: false }` must be preserved.

## Styling

The MVP targets Tailwind CSS v4.

The registry provides an installable CSS file:

```text
registry/rails/ui/styles/shadwire.css
```

This file contains the theme tokens and CSS needed for shadcn-compatible defaults in Rails.

Component classes should preserve shadcn semantic Tailwind tokens such as:

- `bg-primary`
- `text-primary-foreground`
- `text-muted-foreground`
- `border-input`
- `ring-ring`
- `bg-background`
- `border-border`

Component APIs use Ruby hashes for variants and sizes. A component should combine classes in this order:

```ruby
class_names(base_classes, variant_classes, size_classes, @class_name)
```

Components should not introduce hardcoded visual colors outside the token system unless the upstream shadcn component does so intentionally.

## Hotwire Compatibility

The MVP components are mostly static, but the architecture must not block future Hotwire behavior.

The registry reserves:

```text
registry/rails/ui/javascript/controllers/
```

The sandbox loads Turbo and Stimulus so components are validated in the intended Rails runtime.

For future interactive components:

- Prefer native HTML when it provides the correct behavior and accessibility.
- Use Stimulus for local component state and event handling.
- Use Turbo for navigation, frames, streams, and server-driven updates.
- Avoid React-style client state patterns.

## Registry

`registry.json` is the public installation manifest.

It lists:

- Component name.
- Component type.
- Source files.
- Destination paths.
- Required helpers.
- Required styles.
- Required Stimulus controllers, when applicable.
- Ruby and Rails dependencies.
- JavaScript dependencies, when applicable.

Each registry item must be installable by copying files into the consuming Rails application. The copied files must be understandable and modifiable without Shadwire runtime dependencies.

## Sandbox

The sandbox Rails app validates and documents the registry.

It should include:

- ViewComponent configured for Rails.
- Tailwind CSS v4 configured to load Shadwire styles.
- Turbo and Stimulus loaded.
- Component previews or documentation pages showing class-based usage and helper usage.
- Tests that render synced registry components.

The sandbox should not become the source of truth for component code. If a component is adjusted during validation, the registry version must be updated and re-synced.

## Testing

The MVP test strategy includes:

- Render tests for every component.
- Assertions for default markup.
- Variant and size assertions.
- Custom class assertions for `class_name:` and `class:`.
- HTML attribute passthrough assertions.
- Basic accessibility checks for required semantics and ARIA where applicable.

Browser smoke tests are not required for the MVP because the selected components are static. The sandbox still loads Hotwire so future interactive components can add browser coverage without changing the architecture.

## Future Phases

Phase 2 adds a fuller registry workflow:

- More component metadata.
- Better dependency handling.
- Update/diff strategy.
- Documentation generated from registry metadata.

Phase 3 adds the CLI:

- Install components into Rails apps.
- Add styles, helpers, and Stimulus controllers.
- Preserve local app modifications.
- Support future registry sources.

Future component phases should add interactive components incrementally, starting with a small Stimulus-backed component before larger primitives such as Dialog and DropdownMenu.
