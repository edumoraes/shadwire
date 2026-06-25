# frozen_string_literal: true

module Ui
  module Menubar
    class ItemComponent < UiComponent
      def initialize(inset: false, variant: :default, disabled: false, tag: :button, class_name: nil, **attrs)
        @inset = inset
        @variant = variant
        @disabled = disabled
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **item_attrs)
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
          attrs[:role] = attrs.fetch(:role, "menuitem")
          attrs[:tabindex] = attrs.fetch(:tabindex, "-1")
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = item_data(attrs[:data])

          next unless @disabled

          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(disabled: "true")
        end
      end

      def item_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "menubar-item"
          data[:variant] = @variant.to_s unless @variant.to_sym == :default
          data[:inset] = "" if @inset
          data[:disabled] = "" if @disabled
        end
      end

      def base_classes
        "relative flex w-full cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 data-[inset]:pl-8 data-[variant=destructive]:text-destructive [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0"
      end
    end
  end
end
