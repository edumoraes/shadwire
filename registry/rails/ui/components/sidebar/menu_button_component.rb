# frozen_string_literal: true

module Ui
  module Sidebar
    # The primary clickable row of a menu item. Renders a `<button>` by default
    # or an `<a>` with `tag: :a` (pass `href`). `is_active:` marks the current
    # page (`data-active="true"`). A `tooltip:` label is wired to the
    # `ui-tooltip` controller and surfaces only when the sidebar is collapsed to
    # icons (gated in shadwire.css).
    class MenuButtonComponent < UiComponent
      VARIANTS = {
        default: "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
        outline: "bg-background shadow-[0_0_0_1px_var(--sidebar-border)] hover:bg-sidebar-accent hover:text-sidebar-accent-foreground hover:shadow-[0_0_0_1px_var(--sidebar-accent)]"
      }.freeze

      SIZES = {
        default: "h-8 text-sm",
        sm: "h-7 text-xs",
        lg: "h-12 text-sm group-data-[collapsible=icon]:p-0!"
      }.freeze

      def initialize(is_active: false, variant: :default, size: :default, tag: :button, tooltip: nil, class_name: nil, **attrs)
        @is_active = is_active
        @variant = variant
        @size = size
        @tag = tag
        @tooltip = tooltip
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        return button_element if @tooltip.blank?

        tag.div(class: "relative block w-full", data: { controller: "ui-tooltip", action: tooltip_actions }) do
          safe_join([ button_element, tooltip_content ])
        end
      end

      private

      def button_element
        tag.public_send(@tag, content, **button_attrs)
      end

      def button_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
          attrs[:class] = button_classes
          attrs[:data] = button_data(attrs[:data])
        end
      end

      def button_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "sidebar-menu-button"
          data[:size] = @size.to_s
          data[:active] = "true" if @is_active
          data[:ui_tooltip_target] = "trigger" if @tooltip.present?
        end
      end

      def tooltip_content
        tag.div(
          @tooltip,
          role: "tooltip",
          hidden: true,
          class: "absolute top-1/2 left-full z-50 ml-1.5 w-max max-w-xs -translate-y-1/2 text-balance rounded-md bg-primary px-3 py-1.5 text-xs text-primary-foreground shadow-md data-[state=open]:animate-tooltip-in",
          data: { slot: "sidebar-menu-button-tooltip-content", ui_tooltip_target: "content" }
        )
      end

      def tooltip_actions
        "mouseenter->ui-tooltip#scheduleShow mouseleave->ui-tooltip#hide " \
        "focusin->ui-tooltip#show focusout->ui-tooltip#hide keydown.esc->ui-tooltip#hide"
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
        "peer/menu-button ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground active:bg-sidebar-accent active:text-sidebar-accent-foreground data-[active=true]:bg-sidebar-accent data-[active=true]:text-sidebar-accent-foreground data-[state=open]:hover:bg-sidebar-accent data-[state=open]:hover:text-sidebar-accent-foreground group-has-data-[sidebar=menu-action]/menu-item:pr-8 group-data-[collapsible=icon]:size-8! group-data-[collapsible=icon]:p-2! flex w-full items-center gap-2 overflow-hidden rounded-md p-2 text-left text-sm font-normal outline-hidden transition-[width,height,padding] focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 data-[active=true]:font-medium [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0"
      end
    end
  end
end
