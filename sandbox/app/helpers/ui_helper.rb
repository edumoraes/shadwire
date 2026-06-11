# frozen_string_literal: true

module UiHelper
  def ui_button(**options, &block)
    render(Ui::ButtonComponent.new(**options), &block)
  end

  def ui_badge(**options, &block)
    render(Ui::BadgeComponent.new(**options), &block)
  end

  def ui_card(**options, &block)
    render(Ui::CardComponent.new(**options), &block)
  end

  def ui_card_header(**options, &block)
    render(Ui::Card::HeaderComponent.new(**options), &block)
  end

  def ui_card_title(**options, &block)
    render(Ui::Card::TitleComponent.new(**options), &block)
  end

  def ui_card_description(**options, &block)
    render(Ui::Card::DescriptionComponent.new(**options), &block)
  end

  def ui_card_content(**options, &block)
    render(Ui::Card::ContentComponent.new(**options), &block)
  end

  def ui_card_footer(**options, &block)
    render(Ui::Card::FooterComponent.new(**options), &block)
  end

  def ui_alert(**options, &block)
    render(Ui::AlertComponent.new(**options), &block)
  end

  def ui_separator(**options)
    render(Ui::SeparatorComponent.new(**options))
  end

  def ui_avatar(**options, &block)
    render(Ui::AvatarComponent.new(**options), &block)
  end

  def ui_accordion(**options, &block)
    render(Ui::AccordionComponent.new(**options), &block)
  end

  def ui_accordion_item(**options, &block)
    render(Ui::Accordion::ItemComponent.new(**options), &block)
  end

  def ui_accordion_header(**options, &block)
    render(Ui::Accordion::HeaderComponent.new(**options), &block)
  end

  def ui_accordion_trigger(**options, &block)
    render(Ui::Accordion::TriggerComponent.new(**options), &block)
  end

  def ui_accordion_content(**options, &block)
    render(Ui::Accordion::ContentComponent.new(**options), &block)
  end

  def ui_accordion_panel(**options, &block)
    render(Ui::Accordion::PanelComponent.new(**options), &block)
  end

  def ui_scroll_area(**options, &block)
    render(Ui::ScrollAreaComponent.new(**options), &block)
  end

  def ui_scroll_bar(**options, &block)
    render(Ui::ScrollArea::ScrollbarComponent.new(**options), &block)
  end

  def ui_icon(name, **options)
    render(Ui::IconComponent.new(name, **options))
  end

  def ui_input(**options)
    render(Ui::InputComponent.new(**options))
  end

  def ui_label(**options, &block)
    render(Ui::LabelComponent.new(**options), &block)
  end

  def ui_textarea(**options, &block)
    render(Ui::TextareaComponent.new(**options), &block)
  end

  def ui_checkbox(**options)
    render(Ui::CheckboxComponent.new(**options))
  end

  def ui_radio_group(**options, &block)
    render(Ui::RadioGroupComponent.new(**options), &block)
  end

  def ui_radio_group_item(**options)
    render(Ui::RadioGroup::ItemComponent.new(**options))
  end

  def ui_switch(**options)
    render(Ui::SwitchComponent.new(**options))
  end
end
