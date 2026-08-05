# frozen_string_literal: true

# Code samples for the guide pages.
#
# They live here rather than in the views because an ERB template cannot hold a
# heredoc containing ERB tags: the template scanner closes the tag at the first
# `%>` and the heredoc never terminates. ComponentsController keeps its snippets
# in Ruby for the same reason; this module does it for the whole docs section so
# DocsController stays about pages.
#
# Sandbox-only: nothing here ships in the Shadwire registry.
module DocsSnippets
  INSTALLATION = {
    install_cli: <<~SHELL,
      # global
      gem install shadwire

      # or straight into the app, in the development group
      bundle add shadwire --group development
    SHELL

    init: <<~SHELL,
      shadwire init                     # gem installed globally
      bundle exec shadwire init         # gem in the Gemfile
    SHELL

    usage: <<~'ERB',
      <%= ui_button(variant: :outline, size: :sm) { "Save" } %>

      <%= render Ui::ButtonComponent.new(variant: :outline, size: :sm) do %>
        Save
      <% end %>
    ERB

    add: "bin/shadwire add button",
    status: "bin/shadwire status"
  }.freeze

  CONFIGURATION = {
    full: <<~JSON,
      {
        "$schema": "https://shadwire.edumoraes.dev.br/schema.json",
        "registry": "https://shadwire.edumoraes.dev.br/r",
        "tailwind": { "css": "app/assets/tailwind/application.css" },
        "aliases": {
          "components":  "app/components",
          "ui":          "app/components/ui",
          "helpers":     "app/helpers",
          "controllers": "app/javascript/controllers",
          "vendorCss":   "vendor/shadwire"
        },
        "installed": {
          "button": {
            "version": "0.2.0",
            "files": [
              "app/components/ui/button_component.rb",
              "app/helpers/ui/button_helper.rb"
            ]
          }
        }
      }
    JSON

    engine_aliases: <<~JSON,
      {
        "aliases": {
          "components":  "app/components",
          "ui":          "app/components/ui",
          "helpers":     "app/helpers",
          "controllers": "app/javascript/controllers",
          "vendorCss":   "app/assets/stylesheets/shadwire"
        },
        "tailwind": { "css": "app/assets/stylesheets/application.tailwind.css" }
      }
    JSON

    import: <<~CSS,
      @import "tailwindcss";
      @import "../../../vendor/shadwire/shadwire.css";
    CSS

    registry_override: <<~SHELL
      bin/shadwire add button --registry file://$PWD/build/r
      shadwire init --registry https://ui.example.com/r
    SHELL
  }.freeze

  THEMING = {
    layers: <<~CSS,
      @custom-variant dark (&:is(.dark *));   /* dark mode por classe */

      @theme inline {                         /* maps tokens to utilities */
        --color-background: var(--background);
        --color-primary: var(--primary);
        /* ... */
      }

      :root { --background: oklch(1 0 0); }      /* valores do tema claro */
      .dark { --background: oklch(0.145 0 0); }  /* valores do tema escuro */
    CSS

    brand: <<~CSS,
      :root {
        --primary: oklch(0.55 0.22 264);
        --primary-foreground: oklch(0.98 0 0);
      }

      .dark {
        --primary: oklch(0.7 0.19 264);
        --primary-foreground: oklch(0.15 0 0);
      }
    CSS

    new_token: <<~CSS,
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
    CSS

    radius: ":root { --radius: 0.75rem; }",

    variant: <<~RUBY,
      # app/components/ui/button_component.rb
      VARIANTS = {
        default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
        success: "bg-success text-success-foreground shadow-xs hover:bg-success/90",
        # ...
      }.freeze
    RUBY

    variant_usage: <<~'ERB',
      <%= ui_button(variant: :success) { "Publicar" } %>
    ERB

    keep_edits: <<~SHELL
      bin/shadwire diff button      # see what you changed
      bin/shadwire update button    # without --yes: asks per file and shows the diff
    SHELL
  }.freeze

  DARK_MODE = {
    variant: "@custom-variant dark (&:is(.dark *));",

    head_script: <<~HTML,
      <script>
        (() => {
          const stored = localStorage.getItem("theme")
          const dark = stored
            ? stored === "dark"
            : window.matchMedia("(prefers-color-scheme: dark)").matches
          document.documentElement.classList.toggle("dark", dark)
        })()
      </script>
    HTML

    controller: <<~JS,
      // app/javascript/controllers/theme_controller.js
      import { Controller } from "@hotwired/stimulus"

      export default class extends Controller {
        toggle() {
          const isDark = document.documentElement.classList.toggle("dark")
          localStorage.setItem("theme", isDark ? "dark" : "light")
        }
      }
    JS

    toggle_markup: <<~'ERB',
      <%= ui_button(size: :icon, variant: :ghost,
                    data: { controller: "theme", action: "theme#toggle" },
                    aria: { label: "Alternar tema" }) do %>
        <%= ui_icon("moon", class: "dark:hidden") %>
        <%= ui_icon("sun", class: "hidden dark:block") %>
      <% end %>
    ERB

    wrong: <<~'ERB',
      <%# Wrong: light and dark colours written by hand %>
      <%= ui_card(class: "bg-white text-gray-900 dark:bg-gray-900 dark:text-white") do %>
    ERB

    right: <<~'ERB'
      <%# Right: the tokens already handle both modes %>
      <%= ui_card do %>
    ERB
  }.freeze

  CLI = {
    quick_reference: <<~SHELL,
      bin/shadwire status --json        # the project's context
      bin/shadwire search <term>       # find a component
      bin/shadwire info <name> --json   # its full API
      bin/shadwire add <name> --yes     # install it, dependencies included
      bin/shadwire list                 # the whole catalog
      bin/shadwire diff [name]          # local drift
      bin/shadwire diff --exit-code     # non-zero if there is drift (CI)
      bin/shadwire update [name] --yes  # reapply the registry (overwrites!)
      bin/shadwire remove <name> --yes  # uninstall
    SHELL

    status_json: <<~JSON,
      {
        "rails": true,
        "configPresent": true,
        "registryVersion": "0.2.0",
        "stack": { "importmap": true, "stimulus": true, "tailwindcssRails": true },
        "gems": { "view_component": true, "lucide-rails": true },
        "cli": { "gem": true, "binstub": true },
        "tailwind": { "css": "app/assets/tailwind/application.css", "importPresent": true },
        "helpers": { "includeAllHelpers": true, "legacyHelperPresent": false },
        "installed": [
          {
            "name": "card",
            "version": "0.2.0",
            "drift": "unchanged",
            "helpers": ["ui_card", "ui_card_header", "ui_card_title"],
            "classes": ["Ui::CardComponent", "Ui::Card::HeaderComponent"]
          }
        ],
        "availableCount": 58
      }
    JSON

    search: <<~SHELL,
      bin/shadwire search form
      bin/shadwire search modal --json
    SHELL

    info: "bin/shadwire info dialog --json",

    add: "bin/shadwire add button dialog --yes",

    diff: <<~SHELL,
      bin/shadwire diff
      bin/shadwire diff --json
      bin/shadwire diff --exit-code    # non-zero when there is drift (fails CI)
    SHELL

    update: <<~SHELL,
      bin/shadwire diff button          # look first
      bin/shadwire update button --yes  # then overwrite
    SHELL

    remove: "bin/shadwire remove chart --yes",

    errors: <<~CONSOLE,
      $ shadwire init --yes
      Initialized shadwire (2 base files).
        create  app/components/ui_component.rb
        FAILED  view_component (bundle add failed)
      Failed to install: view_component. Run `bundle add view_component` in the app
      and re-run this command.
      $ echo $?
      1
    CONSOLE

    error_messages: <<~TEXT,
      shadwire.json is not valid JSON: expected object key, got 'not' at line 1 column 3
      Could not reach the registry at https://…/index.json: getaddrinfo(3): Name or service not known
      add requires at least one component name
    TEXT

    ci: <<~YAML
      - name: Install dependencies (with the development group)
        run: bundle install

      # Fails when an installed file has diverged from the registry.
      - name: Checar drift do Shadwire
        run: bin/shadwire diff --exit-code
    YAML
  }.freeze

  AGENT_SKILL = {
    install: "npx skills add edumoraes/shadwire",

    permissions: <<~JSON,
      {
        "permissions": {
          "allow": ["Bash(bin/shadwire *)"]
        }
      }
    JSON

    frontmatter: <<~YAML,
      ---
      name: shadwire
      description: Manages shadcn/ui components in Ruby on Rails apps via the shadwire CLI…
      user-invocable: false
      allowed-tools: Bash(bin/shadwire *), Bash(./bin/shadwire *), Bash(bundle exec shadwire *), Bash(shadwire *)
      ---
    YAML

    context: <<~MARKDOWN,
      ## Current Project Context

      ```!
      bin/shadwire status --json 2>/dev/null || bundle exec shadwire status --json 2>/dev/null || …
      ```
    MARKDOWN

    workflow: <<~SHELL
      bin/shadwire status --json      # 1. what already exists in this app
      bin/shadwire search modal       # 2. find the component
      bin/shadwire info dialog --json # 3. read the API before writing ERB
      bin/shadwire add dialog --yes   # 4. instalar
      bin/shadwire status --json      # 5. confirm the new helpers
    SHELL
  }.freeze

  REGISTRY = {
    index: <<~JSON,
      {
        "name": "shadwire",
        "version": "0.2.0",
        "items": [
          {
            "name": "button",
            "type": "component",
            "title": "Button",
            "description": "Displays a button or a link styled as a button.",
            "whenToUse": "Any clickable action. Use tag: :a for a link that looks like a button…"
          }
        ],
        "base": {
          "files": [{ "target": "app/components/ui_component.rb", "type": "component", "content": "…" }],
          "gems": ["view_component", "lucide-rails"],
          "tailwind": { "version": "4", "css": "shadwire.css" }
        }
      }
    JSON

    item: <<~JSON,
      {
        "name": "button",
        "type": "component",
        "title": "Button",
        "description": "Displays a button or a link styled as a button.",
        "whenToUse": "Any clickable action…",
        "usage": ["<%= ui_button(variant: :outline, size: :sm) { \\"Save\\" } %>"],
        "gems": [],
        "importmap": [],
        "registryDependencies": ["icon"],
        "requiresStimulus": false,
        "api": {
          "components": [
            {
              "class": "Ui::ButtonComponent",
              "helper": "ui_button",
              "root": true,
              "variants": ["default", "destructive", "outline", "secondary", "ghost", "link"],
              "sizes": ["default", "sm", "lg", "icon"],
              "props": [{ "name": "tag", "default": ":button" }]
            }
          ]
        },
        "files": [
          {
            "target": "app/components/ui/button_component.rb",
            "type": "component",
            "content": "# frozen_string_literal: true\\n\\nmodule Ui\\n  class ButtonComponent…"
          }
        ]
      }
    JSON

    build: <<~SHELL,
      bin/build_registry            # registry/registry.json → build/r/{name}.json + index.json
      ls build/r | head
    SHELL

    local: <<~SHELL,
      bin/build_registry
      bin/shadwire add button --registry "file://$PWD/build/r"
    SHELL

    fetch: <<~SHELL
      curl -s https://shadwire.edumoraes.dev.br/r/index.json | jq '.items | length'
      curl -s https://shadwire.edumoraes.dev.br/r/button.json | jq '.api.components[0].variants'
    SHELL
  }.freeze

  LLMS_TXT = {
    fetch: <<~SHELL,
      curl -s https://shadwire.edumoraes.dev.br/r/llms.txt
      curl -s https://shadwire.edumoraes.dev.br/r/llms-full.txt
    SHELL

    sample: <<~TEXT
      # shadwire 0.2.0

      shadcn/ui components for Ruby on Rails, delivered as source your app owns.
      Components are copied into the app by the CLI; there is no runtime
      dependency on Shadwire.

      ## Install

      gem install shadwire      # or: bundle add shadwire --group development
      shadwire init             # writes shadwire.json and the shared base files
      shadwire add <name>       # installs a component and its dependencies

      ## Licence

      MIT — https://github.com/edumoraes/shadwire/blob/main/LICENSE
      Ported from shadcn/ui (https://ui.shadcn.com), MIT.

      ## Components

      - button — Any clickable action. Use tag: :a for a link that looks like a
        button, size: :icon for icon-only…
    TEXT
  }.freeze

  COMPOSITION = {
    wrong_props: <<~'ERB',
      <%# Wrong: these props do not exist %>
      <%= ui_card(header: "Time", footer: "Save") %>
    ERB

    right_props: <<~'ERB',
      <%# Right %>
      <%= ui_card do %>
        <%= ui_card_header do %>
          <%= ui_card_title { "Time" } %>
          <%= ui_card_description { "Gerencie quem tem acesso." } %>
        <% end %>
        <%= ui_card_content { "Corpo" } %>
        <%= ui_card_footer { ui_button { "Save" } } %>
      <% end %>
    ERB

    wrong_collapse: <<~'ERB',
      <%# Wrong: everything dumped into the content %>
      <%= ui_card do %>
        <%= ui_card_content do %>
          <h3>Time</h3>
          <p>Gerencie quem tem acesso.</p>
        <% end %>
      <% end %>
    ERB

    wrong_group: <<~'ERB',
      <%# Wrong: item rendered straight at the root %>
      <%= ui_select do %>
        <%= ui_select_item(value: "a") { "A" } %>
      <% end %>
    ERB

    right_group: <<~'ERB',
      <%# Right %>
      <%= ui_select(name: "role", placeholder: "Escolha um papel") do %>
        <%= ui_select_trigger { ui_select_value } %>
        <%= ui_select_content do %>
          <%= ui_select_item(value: "admin") { "Admin" } %>
        <% end %>
      <% end %>
    ERB

    wrong_title: <<~'ERB',
      <%# Wrong: the dialog has no accessible name %>
      <%= ui_dialog_content do %>
        <p>Tem certeza?</p>
      <% end %>
    ERB

    right_title: <<~'ERB',
      <%# Right: visually hidden, but announced %>
      <%= ui_dialog_content do %>
        <%= ui_dialog_header do %>
          <%= ui_dialog_title(class: "sr-only") { "Confirm deletion" } %>
        <% end %>
        <p>Tem certeza?</p>
      <% end %>
    ERB

    helper_vs_class: <<~'ERB',
      <%= ui_button(variant: :outline) { "Save" } %>
      <%= render Ui::ButtonComponent.new(variant: :outline) do %>Save<% end %>
    ERB

    inside_component: <<~RUBY
      class DashboardCardComponent < ViewComponent::Base
        # Components do not get helpers automatically.
        include Ui::ButtonHelper
      end
    RUBY
  }.freeze

  STYLING = {
    wrong_colors: <<~'ERB',
      <%# Wrong: hardcoded colours and a hand-written dark override %>
      <%= ui_card(class: "bg-white text-gray-900 dark:bg-gray-900 dark:text-white") do %>
    ERB

    right_colors: <<~'ERB',
      <%# Right: the tokens already cover both modes %>
      <%= ui_card do %>
    ERB

    class_alias: <<~'ERB',
      <%= ui_button(class: "w-full") { "Save" } %>
      <%= ui_button(class_name: "w-full") { "Save" } %>
    ERB

    order: "base_classes → variant_classes → size_classes → a sua class",

    wrong_restyle: <<~'ERB',
      <%# Wrong: fighting the design system %>
      <%= ui_button(class: "bg-red-600 hover:bg-red-700") { "Delete" } %>
    ERB

    right_restyle: <<~'ERB',
      <%# Right: the variant already exists %>
      <%= ui_button(variant: :destructive) { "Delete" } %>
    ERB

    layout: <<~'ERB',
      <%= ui_button(variant: :outline, class: "w-full sm:w-auto") { "Save" } %>
    ERB

    attrs: <<~'ERB',
      <%= ui_button(id: "save", data: { turbo: false, controller: "form" },
                    "aria-describedby": "hint") { "Save" } %>

      <%= ui_button(tag: :a, href: post_path(post), data: { turbo_method: :delete }) { "Delete" } %>
    ERB

    info: <<~CONSOLE,
      $ bin/shadwire info button
        variants: default | destructive | outline | secondary | ghost | link
        sizes:    default | sm | lg | icon
    CONSOLE

    wrong_utilities: <<~'ERB',
      <%# Wrong %>
      <%= ui_button(class: "h-8 px-3 text-xs border") { "Pequeno" } %>
    ERB

    right_utilities: <<~'ERB'
      <%# Right %>
      <%= ui_button(variant: :outline, size: :sm) { "Pequeno" } %>
    ERB
  }.freeze

  FORMS = {
    wrong_field: <<~'ERB',
      <%# Wrong %>
      <div class="space-y-2">
        <%= ui_label(for: "email") { "Email" } %>
        <%= ui_input(type: :email, id: "email", name: "email") %>
        <p class="text-sm text-muted-foreground">Nunca compartilhamos.</p>
      </div>
    ERB

    right_field: <<~'ERB',
      <%# Right %>
      <%= ui_field do %>
        <%= ui_field_label(for: "email") { "Email" } %>
        <%= ui_input(type: :email, id: "email", name: "email") %>
        <%= ui_field_description { "Nunca compartilhamos." } %>
      <% end %>
    ERB

    invalid: <<~'ERB',
      <%= ui_field(invalid: user.errors[:email].any?) do %>
        <%= ui_field_label(for: "email") { "Email" } %>
        <%= ui_input(type: :email, id: "email", name: "email",
                     "aria-invalid": user.errors[:email].any?) %>
        <%= ui_field_error(errors: user.errors[:email]) %>
      <% end %>
    ERB

    form_with: <<~'ERB',
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
    ERB

    checkbox_hidden: <<~'ERB',
      <%= hidden_field_tag form.field_name(:admin), "0", id: nil %>
      <%= ui_checkbox(name: form.field_name(:admin), id: form.field_id(:admin),
                      value: "1", checked: @user.admin?) %>
    ERB

    wrong_input_group: <<~'ERB',
      <%# Wrong %>
      <%= ui_input_group do %>
        <%= ui_input_group_addon { ui_icon("search") } %>
        <%= ui_input(name: "q") %>
      <% end %>
    ERB

    right_input_group: <<~'ERB',
      <%# Right %>
      <%= ui_input_group do %>
        <%= ui_input_group_addon { ui_icon("search") } %>
        <%= ui_input_group_input(name: "q", placeholder: "Buscar") %>
      <% end %>
    ERB

    date_picker: <<~'ERB'
      <div data-controller="ui-date-picker" data-ui-date-picker-format-value="long">
        <%= ui_popover do %>
          <%= ui_popover_trigger(variant: :outline, class: "w-[212px] justify-between font-normal") do %>
            <span data-ui-date-picker-target="label" data-empty="true"
                  class="data-[empty=true]:text-muted-foreground">Escolha uma data</span>
            <%= ui_icon("chevron-down", class: "opacity-50") %>
          <% end %>
          <%= ui_popover_content(align: :start, class: "w-auto! p-0!") do %>
            <%= ui_calendar(name: "due_on") %>
          <% end %>
        <% end %>
      </div>
    ERB
  }.freeze

  ICONS = {
    wrong_names: <<~'ERB',
      <%# Wrong: React component names do not exist here %>
      <%= ui_icon("ChevronDown") %>
      <%= ui_icon(:chevron_down) %>
    ERB

    right_names: <<~'ERB',
      <%# Right %>
      <%= ui_icon("chevron-down") %>
    ERB

    sizes: <<~'ERB',
      <%= ui_icon("check", size: :sm) %>
    ERB

    decorative: <<~'ERB',
      <%# Right: "Download" is already the label; the icon is decoration %>
      <%= ui_button { safe_join([ ui_icon("download"), " Baixar" ]) } %>
    ERB

    wrong_label: <<~'ERB',
      <%# Wrong: icon-only button with no accessible name %>
      <%= ui_button(size: :icon) { ui_icon("trash-2") } %>
    ERB

    right_label: <<~'ERB',
      <%# Right: either of these works %>
      <%= ui_button(size: :icon) { ui_icon("trash-2", label: "Delete") } %>
      <%= ui_button(size: :icon, "aria-label": "Delete") { ui_icon("trash-2") } %>
    ERB

    wrong_prop: <<~'ERB',
      <%# Wrong: no component has that prop %>
      <%= ui_button(icon: "plus") { "Adicionar" } %>
    ERB

    right_prop: <<~'ERB'
      <%# Right %>
      <%= ui_button { safe_join([ ui_icon("plus"), " Adicionar" ]) } %>
    ERB
  }.freeze

  ACCESSIBILITY = {
    overlay: <<~'ERB',
      <%= ui_dialog_content do %>
        <%= ui_dialog_header do %>
          <%= ui_dialog_title(class: "sr-only") { "Confirm deletion" } %>
        <% end %>
        <p>This action cannot be undone.</p>
      <% end %>
    ERB

    icon_label: <<~'ERB',
      <%= ui_icon("bell", label: "Notifications") %>
    ERB

    test: <<~RUBY
      test "dialog renders a native <dialog> with an accessible name" do
        render_inline(Ui::Dialog::ContentComponent.new) do
          render_inline(Ui::Dialog::TitleComponent.new) { "Edit profile" }
        end

        assert_selector "dialog[aria-labelledby]"
        assert_text "Edit profile"
      end
    RUBY
  }.freeze

  PAGES = {
    "index" => {},
    "installation" => INSTALLATION,
    "configuration" => CONFIGURATION,
    "theming" => THEMING,
    "dark_mode" => DARK_MODE,
    "cli" => CLI,
    "agent_skill" => AGENT_SKILL,
    "registry" => REGISTRY,
    "llms_txt" => LLMS_TXT,
    "composition" => COMPOSITION,
    "styling" => STYLING,
    "forms" => FORMS,
    "icons" => ICONS,
    "accessibility" => ACCESSIBILITY
  }.freeze

  # Snippets for a docs action, or an empty hash for a page that has none.
  #
  # Missing keys raise rather than returning nil: a view asking for a renamed
  # snippet would otherwise publish an empty code block, complete with a copy
  # button, and nothing would report it.
  def self.for(page)
    PAGES.fetch(page.to_s, {}).dup.tap do |snippets|
      snippets.default_proc = ->(_hash, key) { raise KeyError, "#{page} has no snippet #{key.inspect}" }
    end
  end
end
