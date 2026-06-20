# frozen_string_literal: true

module Ui
  module Sidebar
    # A loading placeholder shaped like a menu row. Pass `show_icon: true` to
    # include a leading icon block. The text block gets a random width so a list
    # of skeletons looks natural.
    class MenuSkeletonComponent < UiComponent
      def initialize(show_icon: false, class_name: nil, **attrs)
        @show_icon = show_icon
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**skeleton_attrs) do
          safe_join([ icon_skeleton, text_skeleton ].compact)
        end
      end

      private

      def skeleton_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex h-8 items-center gap-2 rounded-md px-2", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-menu-skeleton")
        end
      end

      def icon_skeleton
        return unless @show_icon

        render(Ui::SkeletonComponent.new(class: "size-4 rounded-md", data: { slot: "sidebar-menu-skeleton-icon" }))
      end

      def text_skeleton
        render(Ui::SkeletonComponent.new(
          class: "h-4 max-w-[var(--skeleton-width)] flex-1",
          style: "--skeleton-width: #{rand(50..90)}%",
          data: { slot: "sidebar-menu-skeleton-text" }
        ))
      end
    end
  end
end
