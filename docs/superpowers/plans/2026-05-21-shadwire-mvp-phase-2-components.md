# Shadwire MVP Phase 2: Components Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the six MVP ViewComponent ports from the registry source of truth and sync them into the Rails sandbox with render coverage.

**Architecture:** Continue from Phase 1. Component source files are edited in `registry/rails/ui/components`, then copied into `sandbox/app/components` with `bin/sync_registry`. Tests live in `sandbox/test/components/ui` and prove the synced consumer code works.

**Tech Stack:** Ruby 3.4, Rails, ViewComponent, Tailwind CSS v4, Minitest, Capybara assertions.

---

**Prerequisite:** Complete `2026-05-21-shadwire-mvp-phase-1-foundation.md` through Task 4.

**Next Phase:** Continue with `2026-05-21-shadwire-mvp-phase-3-validation-docs.md` after Task 7 passes and is committed.

---

### Task 5: Add Button and Badge Components Test-First

**Files:**
- Create: `registry/rails/ui/components/button_component.rb`
- Create: `registry/rails/ui/components/badge_component.rb`
- Create: `sandbox/test/components/ui/button_component_test.rb`
- Create: `sandbox/test/components/ui/badge_component_test.rb`

- [ ] **Step 1: Write failing Button tests**

Create `sandbox/test/components/ui/button_component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  def test_renders_default_button
    render_inline(Ui::ButtonComponent.new) { "Save" }

    assert_selector "button[type='button']", text: "Save"
    assert_selector "button.bg-primary.text-primary-foreground"
  end

  def test_renders_variant_size_and_custom_class
    render_inline(Ui::ButtonComponent.new(variant: :outline, size: :sm, class_name: "w-full")) { "Save" }

    assert_selector "button.border.bg-background.h-8.w-full", text: "Save"
  end

  def test_accepts_class_alias_and_html_attrs
    render_inline(Ui::ButtonComponent.new(class: "justify-start", data: { turbo: false })) { "Save" }

    assert_selector "button.justify-start[data-turbo='false']", text: "Save"
  end

  def test_renders_configurable_tag
    render_inline(Ui::ButtonComponent.new(tag: :a, href: "/demo")) { "Open" }

    assert_selector "a[href='/demo']", text: "Open"
  end
end
```

- [ ] **Step 2: Write failing Badge tests**

Create `sandbox/test/components/ui/badge_component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class BadgeComponentTest < ViewComponent::TestCase
  def test_renders_default_badge
    render_inline(Ui::BadgeComponent.new) { "Active" }

    assert_selector "span.bg-primary.text-primary-foreground", text: "Active"
  end

  def test_renders_outline_variant_and_attrs
    render_inline(Ui::BadgeComponent.new(variant: :outline, class: "uppercase", data: { state: "open" })) { "Beta" }

    assert_selector "span.border.uppercase[data-state='open']", text: "Beta"
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
cd sandbox
bin/rails test test/components/ui/button_component_test.rb test/components/ui/badge_component_test.rb
```

Expected:

```text
NameError: uninitialized constant Ui
```

- [ ] **Step 4: Implement Button**

Create `registry/rails/ui/components/button_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  class ButtonComponent < UiComponent
    VARIANTS = {
      default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
      destructive: "bg-destructive text-destructive-foreground shadow-xs hover:bg-destructive/90",
      outline: "border border-input bg-background shadow-xs hover:bg-accent hover:text-accent-foreground",
      secondary: "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      default: "h-9 px-4 py-2",
      sm: "h-8 rounded-md px-3 text-xs",
      lg: "h-10 rounded-md px-6",
      icon: "size-9"
    }.freeze

    def initialize(variant: :default, size: :default, tag: :button, class_name: nil, **attrs)
      @variant = variant
      @size = size
      @tag = tag
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.public_send(@tag, content, **button_attrs)
    end

    private

    def button_attrs
      html_attrs.merge(class: button_classes).tap do |attrs|
        attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
      end
    end

    def button_classes
      class_names(
        base_classes,
        fetch_variant(VARIANTS, @variant, fallback: :default),
        fetch_variant(SIZES, @size, fallback: :default),
        @class_name
      )
    end

    def base_classes
      "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors disabled:pointer-events-none disabled:opacity-50 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
    end
  end
end
```

- [ ] **Step 5: Implement Badge**

Create `registry/rails/ui/components/badge_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  class BadgeComponent < UiComponent
    VARIANTS = {
      default: "bg-primary text-primary-foreground shadow hover:bg-primary/80",
      secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      destructive: "bg-destructive text-destructive-foreground shadow hover:bg-destructive/80",
      outline: "border border-input text-foreground"
    }.freeze

    def initialize(variant: :default, class_name: nil, **attrs)
      @variant = variant
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.span(content, **html_attrs, class: badge_classes)
    end

    private

    def badge_classes
      class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), @class_name)
    end

    def base_classes
      "inline-flex items-center rounded-md px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
    end
  end
end
```

- [ ] **Step 6: Sync registry into sandbox**

Run:

```bash
bin/sync_registry
```

Expected output includes:

```text
synced registry/rails/ui/components/button_component.rb -> sandbox/app/components/ui/button_component.rb
synced registry/rails/ui/components/badge_component.rb -> sandbox/app/components/ui/badge_component.rb
```

- [ ] **Step 7: Run tests to verify they pass**

Run:

```bash
cd sandbox
bin/rails test test/components/ui/button_component_test.rb test/components/ui/badge_component_test.rb
```

Expected:

Output contains `6 runs` and `0 failures, 0 errors, 0 skips`.

- [ ] **Step 8: Commit**

Run:

```bash
git add registry/rails/ui/components/button_component.rb registry/rails/ui/components/badge_component.rb sandbox/app/components sandbox/app/helpers sandbox/vendor sandbox/test/components/ui/button_component_test.rb sandbox/test/components/ui/badge_component_test.rb
git commit -m "feat: add button and badge components"
```

Expected:

Commit succeeds with subject `feat: add button and badge components`.

---

### Task 6: Add Card Component Family Test-First

**Files:**
- Create: `registry/rails/ui/components/card_component.rb`
- Create: `registry/rails/ui/components/card/header_component.rb`
- Create: `registry/rails/ui/components/card/title_component.rb`
- Create: `registry/rails/ui/components/card/description_component.rb`
- Create: `registry/rails/ui/components/card/content_component.rb`
- Create: `registry/rails/ui/components/card/footer_component.rb`
- Create: `sandbox/test/components/ui/card_component_test.rb`

- [ ] **Step 1: Write failing Card tests**

Create `sandbox/test/components/ui/card_component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class CardComponentTest < ViewComponent::TestCase
  def test_renders_card_root
    render_inline(Ui::CardComponent.new(class_name: "max-w-sm")) { "Body" }

    assert_selector "div.rounded-xl.border.bg-card.text-card-foreground.shadow.max-w-sm", text: "Body"
  end

  def test_renders_card_subcomponents
    rendered = render_inline(Ui::CardComponent.new) do
      safe_join([
        render(Ui::Card::HeaderComponent.new) do
          safe_join([
            render(Ui::Card::TitleComponent.new) { "Project" },
            render(Ui::Card::DescriptionComponent.new) { "Status" }
          ])
        end,
        render(Ui::Card::ContentComponent.new) { "Content" },
        render(Ui::Card::FooterComponent.new(class: "justify-end")) { "Footer" }
      ])
    end

    assert_selector ".flex.flex-col.p-6", text: "Project"
    assert_selector ".text-2xl", text: "Project"
    assert_selector ".text-muted-foreground", text: "Status"
    assert_selector ".p-6", text: "Content"
    assert_selector ".flex.items-center.justify-end", text: "Footer"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd sandbox
bin/rails test test/components/ui/card_component_test.rb
```

Expected:

```text
NameError: uninitialized constant Ui::CardComponent
```

- [ ] **Step 3: Implement Card root**

Create `registry/rails/ui/components/card_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  class CardComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **html_attrs, class: card_classes)
    end

    private

    def card_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "rounded-xl border bg-card text-card-foreground shadow"
    end
  end
end
```

- [ ] **Step 4: Implement Card subcomponents**

Create `registry/rails/ui/components/card/header_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  module Card
    class HeaderComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs, class: class_names("flex flex-col gap-1.5 p-6", @class_name))
      end
    end
  end
end
```

Create `registry/rails/ui/components/card/title_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  module Card
    class TitleComponent < UiComponent
      def initialize(tag_name: :h3, class_name: nil, **attrs)
        @tag_name = tag_name
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag_name, content, **html_attrs, class: class_names("text-2xl font-semibold leading-none tracking-normal", @class_name))
      end
    end
  end
end
```

Create `registry/rails/ui/components/card/description_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  module Card
    class DescriptionComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.p(content, **html_attrs, class: class_names("text-sm text-muted-foreground", @class_name))
      end
    end
  end
end
```

Create `registry/rails/ui/components/card/content_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  module Card
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs, class: class_names("p-6 pt-0", @class_name))
      end
    end
  end
end
```

Create `registry/rails/ui/components/card/footer_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  module Card
    class FooterComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs, class: class_names("flex items-center p-6 pt-0", @class_name))
      end
    end
  end
end
```

- [ ] **Step 5: Sync registry and run tests**

Run:

```bash
bin/sync_registry
cd sandbox
bin/rails test test/components/ui/card_component_test.rb
```

Expected:

Output contains `2 runs` and `0 failures, 0 errors, 0 skips`.

- [ ] **Step 6: Commit**

Run:

```bash
git add registry/rails/ui/components/card_component.rb registry/rails/ui/components/card sandbox/app/components/ui/card_component.rb sandbox/app/components/ui/card sandbox/test/components/ui/card_component_test.rb
git commit -m "feat: add card component family"
```

Expected:

Commit succeeds with subject `feat: add card component family`.

---

### Task 7: Add Alert, Separator, and Avatar Test-First

**Files:**
- Create: `registry/rails/ui/components/alert_component.rb`
- Create: `registry/rails/ui/components/separator_component.rb`
- Create: `registry/rails/ui/components/avatar_component.rb`
- Create: `sandbox/test/components/ui/alert_component_test.rb`
- Create: `sandbox/test/components/ui/separator_component_test.rb`
- Create: `sandbox/test/components/ui/avatar_component_test.rb`

- [ ] **Step 1: Write failing tests**

Create `sandbox/test/components/ui/alert_component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  def test_renders_default_alert
    render_inline(Ui::AlertComponent.new) { "Heads up" }

    assert_selector "div[role='alert'].border.bg-background", text: "Heads up"
  end

  def test_renders_destructive_alert
    render_inline(Ui::AlertComponent.new(variant: :destructive, class: "mb-4")) { "Error" }

    assert_selector "div.text-destructive.mb-4[class*='border-destructive']", text: "Error"
  end
end
```

Create `sandbox/test/components/ui/separator_component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class SeparatorComponentTest < ViewComponent::TestCase
  def test_renders_horizontal_separator
    render_inline(Ui::SeparatorComponent.new)

    assert_selector "div[role='separator'][aria-orientation='horizontal'].h-px.w-full"
  end

  def test_renders_vertical_separator
    render_inline(Ui::SeparatorComponent.new(orientation: :vertical, class_name: "mx-2"))

    assert_selector "div[role='separator'][aria-orientation='vertical'].h-full.w-px.mx-2"
  end
end
```

Create `sandbox/test/components/ui/avatar_component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ViewComponent::TestCase
  def test_renders_avatar_with_image_and_fallback
    render_inline(Ui::AvatarComponent.new(src: "/avatar.png", alt: "Ada Lovelace", fallback: "AL"))

    assert_selector "span.relative.flex.size-10"
    assert_selector "img[src='/avatar.png'][alt='Ada Lovelace']"
    assert_selector "span.bg-muted", text: "AL"
  end

  def test_renders_content_block
    render_inline(Ui::AvatarComponent.new(class: "size-12")) { "Custom" }

    assert_selector "span.size-12", text: "Custom"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
cd sandbox
bin/rails test test/components/ui/alert_component_test.rb test/components/ui/separator_component_test.rb test/components/ui/avatar_component_test.rb
```

Expected:

```text
NameError: uninitialized constant Ui::AlertComponent
```

- [ ] **Step 3: Implement Alert**

Create `registry/rails/ui/components/alert_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  class AlertComponent < UiComponent
    VARIANTS = {
      default: "bg-background text-foreground",
      destructive: "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive"
    }.freeze

    def initialize(variant: :default, class_name: nil, **attrs)
      @variant = variant
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **alert_attrs)
    end

    private

    def alert_attrs
      html_attrs.merge(role: html_attrs.fetch(:role, "alert"), class: alert_classes)
    end

    def alert_classes
      class_names(
        "relative w-full rounded-lg border p-4",
        fetch_variant(VARIANTS, @variant, fallback: :default),
        @class_name
      )
    end
  end
end
```

- [ ] **Step 4: Implement Separator**

Create `registry/rails/ui/components/separator_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  class SeparatorComponent < UiComponent
    ORIENTATION_CLASSES = {
      horizontal: "h-px w-full",
      vertical: "h-full w-px"
    }.freeze

    def initialize(orientation: :horizontal, decorative: true, class_name: nil, **attrs)
      @orientation = orientation
      @decorative = decorative
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**separator_attrs)
    end

    private

    def separator_attrs
      html_attrs.merge(
        role: "separator",
        "aria-orientation": @orientation.to_s,
        "aria-hidden": @decorative,
        class: separator_classes
      )
    end

    def separator_classes
      class_names(
        "shrink-0 bg-border",
        fetch_variant(ORIENTATION_CLASSES, @orientation, fallback: :horizontal),
        @class_name
      )
    end
  end
end
```

- [ ] **Step 5: Implement Avatar**

Create `registry/rails/ui/components/avatar_component.rb`:

```ruby
# frozen_string_literal: true

module Ui
  class AvatarComponent < UiComponent
    def initialize(src: nil, alt: "", fallback: nil, class_name: nil, **attrs)
      @src = src
      @alt = alt
      @fallback = fallback
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.span(**html_attrs, class: avatar_classes) do
        content.presence || safe_join([image_tag_html, fallback_html].compact)
      end
    end

    private

    def avatar_classes
      class_names("relative flex size-10 shrink-0 overflow-hidden rounded-full", @class_name)
    end

    def image_tag_html
      return if @src.blank?

      tag.img(src: @src, alt: @alt, class: "aspect-square size-full")
    end

    def fallback_html
      return if @fallback.blank?

      tag.span(@fallback, class: "flex size-full items-center justify-center rounded-full bg-muted")
    end
  end
end
```

- [ ] **Step 6: Sync registry and run tests**

Run:

```bash
bin/sync_registry
cd sandbox
bin/rails test test/components/ui/alert_component_test.rb test/components/ui/separator_component_test.rb test/components/ui/avatar_component_test.rb
```

Expected:

Output contains `6 runs` and `0 failures, 0 errors, 0 skips`.

- [ ] **Step 7: Commit**

Run:

```bash
git add registry/rails/ui/components/alert_component.rb registry/rails/ui/components/separator_component.rb registry/rails/ui/components/avatar_component.rb sandbox/app/components/ui/alert_component.rb sandbox/app/components/ui/separator_component.rb sandbox/app/components/ui/avatar_component.rb sandbox/test/components/ui/alert_component_test.rb sandbox/test/components/ui/separator_component_test.rb sandbox/test/components/ui/avatar_component_test.rb
git commit -m "feat: add alert separator and avatar components"
```

Expected:

Commit succeeds with subject `feat: add alert separator and avatar components`.

---
