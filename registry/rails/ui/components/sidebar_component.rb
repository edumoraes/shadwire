# frozen_string_literal: true

module Ui
  # The sidebar panel. Lives next to a `Ui::Sidebar::InsetComponent` inside a
  # `Ui::Sidebar::ProviderComponent`. It is the `peer`/`group` element whose
  # `data-state`/`data-collapsible`/`data-side`/`data-variant`/`data-mobile`
  # attributes drive the collapse, inset and mobile-drawer styling.
  #
  # On desktop it collapses per `collapsible:` (`:offcanvas` slides off, `:icon`
  # shrinks to icons, `:none` stays fixed). On mobile the same container becomes
  # an off-canvas drawer toggled through `data-mobile` (no Sheet/`<dialog>` —
  # single DOM), with a backdrop that closes it.
  class SidebarComponent < UiComponent
    def initialize(side: :left, variant: :sidebar, collapsible: :offcanvas, class_name: nil, **attrs)
      @side = side.to_sym
      @variant = variant.to_sym
      @collapsible = collapsible.to_sym
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      return non_collapsible if @collapsible == :none

      tag.div(**root_attrs) do
        safe_join([ gap, container, backdrop ])
      end
    end

    private

    def non_collapsible
      tag.div(content, **non_collapsible_attrs)
    end

    def non_collapsible_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(
          "bg-sidebar text-sidebar-foreground flex h-full w-[var(--sidebar-width)] flex-col",
          @class_name
        )
        attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar", ui_sidebar_target: "sidebar")
      end
    end

    def root_attrs
      {
        class: "group peer text-sidebar-foreground",
        data: {
          slot: "sidebar",
          ui_sidebar_target: "sidebar",
          state: "expanded",
          collapsible: "",
          collapsible_mode: @collapsible.to_s,
          variant: @variant.to_s,
          side: @side.to_s,
          mobile: "closed"
        }
      }
    end

    # Desktop-only spacer that reserves the panel width in the layout flow.
    def gap
      tag.div(
        class: class_names(
          "relative hidden h-svh w-[var(--sidebar-width)] bg-transparent transition-all duration-200 ease-linear md:block",
          "group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180",
          icon_width
        ),
        data: { slot: "sidebar-gap" }
      )
    end

    # Fixed panel: desktop collapse transforms + mobile off-canvas drawer.
    def container
      tag.div(**html_attrs.dup.merge(class: container_classes, data: container_data)) do
        tag.div(
          content,
          class: "bg-sidebar group-data-[variant=floating]:border-sidebar-border flex h-full w-full flex-col group-data-[variant=floating]:rounded-lg group-data-[variant=floating]:border group-data-[variant=floating]:shadow-sm",
          data: { slot: "sidebar-inner" }
        )
      end
    end

    def container_data
      (html_attrs[:data] || {}).to_h.dup.merge(slot: "sidebar-container")
    end

    def container_classes
      class_names(
        "fixed inset-y-0 z-10 flex h-svh w-[var(--sidebar-width-mobile)] transition-all duration-200 ease-linear md:w-[var(--sidebar-width)]",
        side_classes,
        floating_or_inset? ? "md:p-2" : nil,
        @class_name
      )
    end

    def side_classes
      if @side == :right
        class_names(
          "right-0 translate-x-full group-data-[mobile=open]:translate-x-0 md:translate-x-0",
          "md:group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)]",
          floating_or_inset? ? nil : "md:group-data-[side=right]:border-l",
          icon_width
        )
      else
        class_names(
          "left-0 -translate-x-full group-data-[mobile=open]:translate-x-0 md:translate-x-0",
          "md:group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)]",
          floating_or_inset? ? nil : "md:group-data-[side=left]:border-r",
          icon_width
        )
      end
    end

    # Collapsed (icon) width differs for floating/inset (adds gutter) variants.
    def icon_width
      if floating_or_inset?
        "group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+1rem)]"
      else
        "group-data-[collapsible=icon]:w-[var(--sidebar-width-icon)]"
      end
    end

    # Mobile-only scrim that closes the drawer when tapped.
    def backdrop
      tag.div(
        class: "fixed inset-0 z-[9] hidden bg-black/50 group-data-[mobile=open]:block md:hidden",
        data: { slot: "sidebar-backdrop", action: "click->ui-sidebar#closeMobile" },
        aria: { hidden: "true" }
      )
    end

    def floating_or_inset?
      [ :floating, :inset ].include?(@variant)
    end
  end
end
