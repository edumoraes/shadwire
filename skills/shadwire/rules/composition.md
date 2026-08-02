# Composition

## Helpers exist only for installed components

Each component installs its own helper module — `button` writes
`app/helpers/ui/button_helper.rb` defining `Ui::ButtonHelper#ui_button`. Rails
auto-includes every module under `app/helpers/`, so installed helpers are
available in all views with no `include`.

A helper for a component that is not installed simply does not exist.

```erb
<%# Wrong — carousel is not installed; raises NoMethodError at request time %>
<%= ui_carousel do %>...<% end %>
```

```bash
# Right — install it first, then call it
bin/shadwire add carousel --yes
```

Check `installed[].helpers` in `bin/shadwire status --json` before calling anything.

If `helpers.legacyHelperPresent` is true, the app still has a pre-split
`app/helpers/ui_helper.rb` from an older install. It defines helpers for
components that are not installed. It is safe to delete.

## Subcomponents are nested helpers, not props

Composition happens through nested helper calls. There are no ViewComponent
slots in this codebase and no content props.

```erb
<%# Wrong — no such props exist %>
<%= ui_card(header: "Team", footer: "Save") %>
```

```erb
<%# Right %>
<%= ui_card do %>
  <%= ui_card_header do %>
    <%= ui_card_title { "Team" } %>
    <%= ui_card_description { "Manage who has access." } %>
  <% end %>
  <%= ui_card_content { "Body" } %>
  <%= ui_card_footer { ui_button { "Save" } } %>
<% end %>
```

Use `bin/shadwire info <name>` to list a component's subcomponent helpers. Don't
invent names — `ui_card_body` does not exist, `ui_card_content` does.

## Use the full composition

Don't collapse a component into one part.

```erb
<%# Wrong — everything dumped in the content slot %>
<%= ui_card do %>
  <%= ui_card_content do %>
    <h3>Team</h3>
    <p>Manage who has access.</p>
  <% end %>
<% end %>
```

```erb
<%# Right — header, title and description carry the semantics %>
<%= ui_card do %>
  <%= ui_card_header do %>
    <%= ui_card_title { "Team" } %>
    <%= ui_card_description { "Manage who has access." } %>
  <% end %>
<% end %>
```

## Items belong inside their group

```erb
<%# Wrong — item rendered directly in the root %>
<%= ui_select do %>
  <%= ui_select_item(value: "a") { "A" } %>
<% end %>
```

```erb
<%# Right %>
<%= ui_select(name: "role", placeholder: "Select a role") do %>
  <%= ui_select_trigger { ui_select_value } %>
  <%= ui_select_content do %>
    <%= ui_select_item(value: "admin") { "Admin" } %>
  <% end %>
<% end %>
```

The same applies to `ui_tabs_trigger` inside `ui_tabs_list`,
`ui_breadcrumb_item` inside `ui_breadcrumb_list`, and
`ui_pagination_item` inside `ui_pagination_content`.

## Overlays always need a title

`dialog`, `alert-dialog`, `sheet` and `drawer` need their title component for
screen readers, even when the design does not show one.

```erb
<%# Wrong — no accessible name %>
<%= ui_dialog_content do %>
  <p>Are you sure?</p>
<% end %>
```

```erb
<%# Right — visually hidden but announced %>
<%= ui_dialog_content do %>
  <%= ui_dialog_header do %>
    <%= ui_dialog_title(class: "sr-only") { "Confirm deletion" } %>
  <% end %>
  <p>Are you sure?</p>
<% end %>
```

## Interactive components need Stimulus

28 of 58 components ship a Stimulus controller. `bin/shadwire info <name>` reports
`Requires Stimulus`, and `status.stack` reports whether the app has importmap and
stimulus-rails.

Controllers install into `app/javascript/controllers/` and register through
`eagerLoadControllersFrom("controllers", application)` in the app's
`controllers/index.js`. If an app registers controllers explicitly instead, add
the new controller there too.

## Rendering the class directly

The helper is a thin wrapper. These are equivalent:

```erb
<%= ui_button(variant: :outline) { "Save" } %>
<%= render Ui::ButtonComponent.new(variant: :outline) do %>Save<% end %>
```

Prefer the helper in views. Use the class when you need the component object
itself, or inside another ViewComponent — components do not get helpers
automatically, so `include Ui::ButtonHelper` in the component class if you want
to call `ui_button` from its template.
