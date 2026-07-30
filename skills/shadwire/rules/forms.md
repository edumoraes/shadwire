# Forms

## Wrap every control in `ui_field`

`field` is the layout primitive for form rows. Never build one out of bare
`div`s and spacing utilities.

```erb
<%# Wrong %>
<div class="space-y-2">
  <%= ui_label(for: "email") { "Email" } %>
  <%= ui_input(type: :email, id: "email", name: "email") %>
  <p class="text-sm text-muted-foreground">We never share it.</p>
</div>
```

```erb
<%# Right %>
<%= ui_field do %>
  <%= ui_field_label(for: "email") { "Email" } %>
  <%= ui_input(type: :email, id: "email", name: "email") %>
  <%= ui_field_description { "We never share it." } %>
<% end %>
```

The family: `ui_field`, `ui_field_group`, `ui_field_set`, `ui_field_legend`,
`ui_field_label`, `ui_field_title`, `ui_field_description`, `ui_field_error`,
`ui_field_content`, `ui_field_separator`.

- `ui_field_group` — stacks several fields with consistent spacing.
- `ui_field_set` + `ui_field_legend` — groups related checkboxes or radios. Use
  these instead of a `div` with a heading.
- `orientation:` is `:vertical` (default), `:horizontal`, or `:responsive`.

## Validation state

Pass `invalid: true` to `ui_field` — it sets `data-invalid` and turns the row's
text destructive. Put the message in `ui_field_error`, which renders with
`role="alert"`.

```erb
<%= ui_field(invalid: user.errors[:email].any?) do %>
  <%= ui_field_label(for: "email") { "Email" } %>
  <%= ui_input(type: :email, id: "email", name: "email",
               "aria-invalid": user.errors[:email].any?) %>
  <%= ui_field_error(errors: user.errors[:email]) %>
<% end %>
```

`ui_field_error` takes either block content or an `errors:` array, and renders
nothing when both are empty — so it is safe to leave in place unconditionally.

## There is no form-builder integration

Shadwire components are not form builders. There is no `f.ui_input`. Controls
accept free HTML attributes and forward them to the underlying element, so wire
them to `form_with` yourself:

```erb
<%= form_with(model: @user) do |form| %>
  <%= ui_field(invalid: @user.errors[:email].any?) do %>
    <%= ui_field_label(for: form.field_id(:email)) { "Email" } %>
    <%= ui_input(type: :email,
                 id: form.field_id(:email),
                 name: form.field_name(:email),
                 value: @user.email) %>
    <%= ui_field_error(errors: @user.errors[:email]) %>
  <% end %>

  <%= ui_button(type: :submit) { "Save" } %>
<% end %>
```

`form.field_name` and `form.field_id` produce the `user[email]` / `user_email`
names Rails expects, so params arrive normally.

The same applies to `ui_checkbox`, `ui_switch`, `ui_textarea`, `ui_select`,
`ui_radio_group` and `ui_slider` — pass `name:`, `id:` and `value:` explicitly.

For checkboxes, remember Rails' unchecked-value convention if the form must
submit a value when unchecked:

```erb
<%= hidden_field_tag form.field_name(:admin), "0", id: nil %>
<%= ui_checkbox(name: form.field_name(:admin), id: form.field_id(:admin),
                value: "1", checked: @user.admin?) %>
```

## Picking a control

| Situation | Control |
| --- | --- |
| One line of text | `ui_input` |
| Several lines | `ui_textarea` |
| Text with a prefix, suffix or button | `ui_input_group` |
| One of a long list | `ui_select`, or `combobox` when it should be searchable |
| One of a few visible options | `ui_radio_group` |
| Native mobile picker, no JS | `ui_native_select` |
| Several independent choices | `ui_checkbox` |
| Compact two-to-seven choice | `ui_toggle_group` |
| Setting applied immediately | `ui_switch` |
| Imprecise number | `ui_slider` |
| Exact number | `ui_input(type: :number)` |
| Date or date range | `date-picker`, or `ui_calendar` inline |
| One-time passcode | `ui_input_otp` |

## The date picker is a recipe

There is no `Ui::DatePickerComponent`. A date field is `ui_popover` +
`ui_calendar`, with the `ui-date-picker` controller writing the picked date into
the trigger and closing the popover. The calendar owns the value: `name:`
renders the hidden input, so it posts like any other field.

```erb
<div data-controller="ui-date-picker" data-ui-date-picker-format-value="long">
  <%= ui_popover do %>
    <%= ui_popover_trigger(variant: :outline, class: "w-[212px] justify-between font-normal") do %>
      <span data-ui-date-picker-target="label" data-empty="true"
            class="data-[empty=true]:text-muted-foreground">Pick a date</span>
      <%= ui_icon("chevron-down", class: "opacity-50") %>
    <% end %>
    <%= ui_popover_content(align: :start, class: "w-auto! p-0!") do %>
      <%= ui_calendar(name: "due_on") %>
    <% end %>
  <% end %>
</div>
```

The popover needs `w-auto! p-0!` — its default `w-72` with padding is too narrow
for the grid. From there the variants are calendar arguments, not new markup:

| Variant | What changes |
| --- | --- |
| Range | `mode: :range, number_of_months: 2`, plus `end_name:` for the second input |
| Date of birth | `caption_layout: :dropdown, max: Date.current` |
| Typed input | trigger an `ui_input_group`; mark the input `data-ui-date-picker-target="input"` |
| Date and time | the picker for the day, `ui_input(type: :time, step: 1)` beside it |
| Natural language | `data-ui-date-picker-natural-language-value="true"` |
| RTL | `dir: :rtl`, with `month_names:`/`day_names:` for the locale |

`shadwire info date-picker` prints all of them.

## Input groups take their own control

Inside `ui_input_group`, use its input helpers — not a bare `ui_input`.

```erb
<%# Wrong %>
<%= ui_input_group do %>
  <%= ui_input_group_addon { ui_icon("search") } %>
  <%= ui_input(name: "q") %>
<% end %>
```

```erb
<%# Right %>
<%= ui_input_group do %>
  <%= ui_input_group_addon { ui_icon("search") } %>
  <%= ui_input_group_input(name: "q", placeholder: "Search") %>
<% end %>
```
