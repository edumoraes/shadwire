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
end
