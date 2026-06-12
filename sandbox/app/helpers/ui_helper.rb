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

  def ui_skeleton(**options, &block)
    render(Ui::SkeletonComponent.new(**options), &block)
  end

  def ui_progress(**options)
    render(Ui::ProgressComponent.new(**options))
  end

  def ui_table(**options, &block)
    render(Ui::TableComponent.new(**options), &block)
  end

  def ui_table_header(**options, &block)
    render(Ui::Table::HeaderComponent.new(**options), &block)
  end

  def ui_table_body(**options, &block)
    render(Ui::Table::BodyComponent.new(**options), &block)
  end

  def ui_table_footer(**options, &block)
    render(Ui::Table::FooterComponent.new(**options), &block)
  end

  def ui_table_row(**options, &block)
    render(Ui::Table::RowComponent.new(**options), &block)
  end

  def ui_table_head(**options, &block)
    render(Ui::Table::HeadComponent.new(**options), &block)
  end

  def ui_table_cell(**options, &block)
    render(Ui::Table::CellComponent.new(**options), &block)
  end

  def ui_table_caption(**options, &block)
    render(Ui::Table::CaptionComponent.new(**options), &block)
  end

  def ui_breadcrumb(**options, &block)
    render(Ui::BreadcrumbComponent.new(**options), &block)
  end

  def ui_breadcrumb_list(**options, &block)
    render(Ui::Breadcrumb::ListComponent.new(**options), &block)
  end

  def ui_breadcrumb_item(**options, &block)
    render(Ui::Breadcrumb::ItemComponent.new(**options), &block)
  end

  def ui_breadcrumb_link(**options, &block)
    render(Ui::Breadcrumb::LinkComponent.new(**options), &block)
  end

  def ui_breadcrumb_page(**options, &block)
    render(Ui::Breadcrumb::PageComponent.new(**options), &block)
  end

  def ui_breadcrumb_separator(**options, &block)
    render(Ui::Breadcrumb::SeparatorComponent.new(**options), &block)
  end

  def ui_breadcrumb_ellipsis(**options)
    render(Ui::Breadcrumb::EllipsisComponent.new(**options))
  end

  def ui_pagination(**options, &block)
    render(Ui::PaginationComponent.new(**options), &block)
  end

  def ui_pagination_content(**options, &block)
    render(Ui::Pagination::ContentComponent.new(**options), &block)
  end

  def ui_pagination_item(**options, &block)
    render(Ui::Pagination::ItemComponent.new(**options), &block)
  end

  def ui_pagination_link(**options, &block)
    render(Ui::Pagination::LinkComponent.new(**options), &block)
  end

  def ui_pagination_previous(**options, &block)
    render(Ui::Pagination::PreviousComponent.new(**options), &block)
  end

  def ui_pagination_next(**options, &block)
    render(Ui::Pagination::NextComponent.new(**options), &block)
  end

  def ui_pagination_ellipsis(**options)
    render(Ui::Pagination::EllipsisComponent.new(**options))
  end

  def ui_tabs(**options, &block)
    render(Ui::TabsComponent.new(**options), &block)
  end

  def ui_tabs_list(**options, &block)
    render(Ui::Tabs::ListComponent.new(**options), &block)
  end

  def ui_tabs_trigger(**options, &block)
    render(Ui::Tabs::TriggerComponent.new(**options), &block)
  end

  def ui_tabs_content(**options, &block)
    render(Ui::Tabs::ContentComponent.new(**options), &block)
  end

  def ui_dialog(**options, &block)
    render(Ui::DialogComponent.new(**options), &block)
  end

  def ui_dialog_trigger(**options, &block)
    render(Ui::Dialog::TriggerComponent.new(**options), &block)
  end

  def ui_dialog_content(**options, &block)
    render(Ui::Dialog::ContentComponent.new(**options), &block)
  end

  def ui_dialog_header(**options, &block)
    render(Ui::Dialog::HeaderComponent.new(**options), &block)
  end

  def ui_dialog_footer(**options, &block)
    render(Ui::Dialog::FooterComponent.new(**options), &block)
  end

  def ui_dialog_title(**options, &block)
    render(Ui::Dialog::TitleComponent.new(**options), &block)
  end

  def ui_dialog_description(**options, &block)
    render(Ui::Dialog::DescriptionComponent.new(**options), &block)
  end

  def ui_dialog_close(**options, &block)
    render(Ui::Dialog::CloseComponent.new(**options), &block)
  end
end
