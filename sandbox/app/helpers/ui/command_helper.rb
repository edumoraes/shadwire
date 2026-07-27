# frozen_string_literal: true

module Ui
  module CommandHelper
    def ui_command(**options, &block)
      render(Ui::CommandComponent.new(**options), &block)
    end

    def ui_command_input(**options)
      render(Ui::Command::InputComponent.new(**options))
    end

    def ui_command_list(**options, &block)
      render(Ui::Command::ListComponent.new(**options), &block)
    end

    def ui_command_empty(**options, &block)
      render(Ui::Command::EmptyComponent.new(**options), &block)
    end

    def ui_command_group(**options, &block)
      render(Ui::Command::GroupComponent.new(**options), &block)
    end

    def ui_command_item(**options, &block)
      render(Ui::Command::ItemComponent.new(**options), &block)
    end

    def ui_command_separator(**options)
      render(Ui::Command::SeparatorComponent.new(**options))
    end

    def ui_command_shortcut(**options, &block)
      render(Ui::Command::ShortcutComponent.new(**options), &block)
    end
  end
end
