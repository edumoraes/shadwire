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

  def ui_alert_dialog(**options, &block)
    render(Ui::AlertDialogComponent.new(**options), &block)
  end

  def ui_alert_dialog_trigger(**options, &block)
    render(Ui::AlertDialog::TriggerComponent.new(**options), &block)
  end

  def ui_alert_dialog_content(**options, &block)
    render(Ui::AlertDialog::ContentComponent.new(**options), &block)
  end

  def ui_alert_dialog_header(**options, &block)
    render(Ui::AlertDialog::HeaderComponent.new(**options), &block)
  end

  def ui_alert_dialog_footer(**options, &block)
    render(Ui::AlertDialog::FooterComponent.new(**options), &block)
  end

  def ui_alert_dialog_title(**options, &block)
    render(Ui::AlertDialog::TitleComponent.new(**options), &block)
  end

  def ui_alert_dialog_description(**options, &block)
    render(Ui::AlertDialog::DescriptionComponent.new(**options), &block)
  end

  def ui_alert_dialog_action(**options, &block)
    render(Ui::AlertDialog::ActionComponent.new(**options), &block)
  end

  def ui_alert_dialog_cancel(**options, &block)
    render(Ui::AlertDialog::CancelComponent.new(**options), &block)
  end

  def ui_sheet(**options, &block)
    render(Ui::SheetComponent.new(**options), &block)
  end

  def ui_sheet_trigger(**options, &block)
    render(Ui::Sheet::TriggerComponent.new(**options), &block)
  end

  def ui_sheet_content(**options, &block)
    render(Ui::Sheet::ContentComponent.new(**options), &block)
  end

  def ui_sheet_header(**options, &block)
    render(Ui::Sheet::HeaderComponent.new(**options), &block)
  end

  def ui_sheet_footer(**options, &block)
    render(Ui::Sheet::FooterComponent.new(**options), &block)
  end

  def ui_sheet_title(**options, &block)
    render(Ui::Sheet::TitleComponent.new(**options), &block)
  end

  def ui_sheet_description(**options, &block)
    render(Ui::Sheet::DescriptionComponent.new(**options), &block)
  end

  def ui_sheet_close(**options, &block)
    render(Ui::Sheet::CloseComponent.new(**options), &block)
  end

  def ui_tooltip(**options, &block)
    render(Ui::TooltipComponent.new(**options), &block)
  end

  def ui_tooltip_trigger(**options, &block)
    render(Ui::Tooltip::TriggerComponent.new(**options), &block)
  end

  def ui_tooltip_content(**options, &block)
    render(Ui::Tooltip::ContentComponent.new(**options), &block)
  end

  def ui_popover(**options, &block)
    render(Ui::PopoverComponent.new(**options), &block)
  end

  def ui_popover_trigger(**options, &block)
    render(Ui::Popover::TriggerComponent.new(**options), &block)
  end

  def ui_popover_content(**options, &block)
    render(Ui::Popover::ContentComponent.new(**options), &block)
  end

  def ui_dropdown_menu(**options, &block)
    render(Ui::DropdownMenuComponent.new(**options), &block)
  end

  def ui_dropdown_menu_trigger(**options, &block)
    render(Ui::DropdownMenu::TriggerComponent.new(**options), &block)
  end

  def ui_dropdown_menu_content(**options, &block)
    render(Ui::DropdownMenu::ContentComponent.new(**options), &block)
  end

  def ui_dropdown_menu_item(**options, &block)
    render(Ui::DropdownMenu::ItemComponent.new(**options), &block)
  end

  def ui_dropdown_menu_label(**options, &block)
    render(Ui::DropdownMenu::LabelComponent.new(**options), &block)
  end

  def ui_dropdown_menu_separator(**options)
    render(Ui::DropdownMenu::SeparatorComponent.new(**options))
  end

  def ui_dropdown_menu_group(**options, &block)
    render(Ui::DropdownMenu::GroupComponent.new(**options), &block)
  end

  def ui_dropdown_menu_shortcut(**options, &block)
    render(Ui::DropdownMenu::ShortcutComponent.new(**options), &block)
  end

  def ui_select(**options, &block)
    render(Ui::SelectComponent.new(**options), &block)
  end

  def ui_select_trigger(**options, &block)
    render(Ui::Select::TriggerComponent.new(**options), &block)
  end

  def ui_select_value(**options, &block)
    render(Ui::Select::ValueComponent.new(**options), &block)
  end

  def ui_select_content(**options, &block)
    render(Ui::Select::ContentComponent.new(**options), &block)
  end

  def ui_select_item(**options, &block)
    render(Ui::Select::ItemComponent.new(**options), &block)
  end

  def ui_select_group(**options, &block)
    render(Ui::Select::GroupComponent.new(**options), &block)
  end

  def ui_select_label(**options, &block)
    render(Ui::Select::LabelComponent.new(**options), &block)
  end

  def ui_select_separator(**options)
    render(Ui::Select::SeparatorComponent.new(**options))
  end

  def ui_sidebar_provider(**options, &block)
    render(Ui::Sidebar::ProviderComponent.new(**options), &block)
  end

  def ui_sidebar(**options, &block)
    render(Ui::SidebarComponent.new(**options), &block)
  end

  def ui_sidebar_trigger(**options, &block)
    render(Ui::Sidebar::TriggerComponent.new(**options), &block)
  end

  def ui_sidebar_rail(**options, &block)
    render(Ui::Sidebar::RailComponent.new(**options), &block)
  end

  def ui_sidebar_inset(**options, &block)
    render(Ui::Sidebar::InsetComponent.new(**options), &block)
  end

  def ui_sidebar_input(**options)
    render(Ui::Sidebar::InputComponent.new(**options))
  end

  def ui_sidebar_header(**options, &block)
    render(Ui::Sidebar::HeaderComponent.new(**options), &block)
  end

  def ui_sidebar_footer(**options, &block)
    render(Ui::Sidebar::FooterComponent.new(**options), &block)
  end

  def ui_sidebar_separator(**options)
    render(Ui::Sidebar::SeparatorComponent.new(**options))
  end

  def ui_sidebar_content(**options, &block)
    render(Ui::Sidebar::ContentComponent.new(**options), &block)
  end

  def ui_sidebar_group(**options, &block)
    render(Ui::Sidebar::GroupComponent.new(**options), &block)
  end

  def ui_sidebar_group_label(**options, &block)
    render(Ui::Sidebar::GroupLabelComponent.new(**options), &block)
  end

  def ui_sidebar_group_action(**options, &block)
    render(Ui::Sidebar::GroupActionComponent.new(**options), &block)
  end

  def ui_sidebar_group_content(**options, &block)
    render(Ui::Sidebar::GroupContentComponent.new(**options), &block)
  end

  def ui_sidebar_menu(**options, &block)
    render(Ui::Sidebar::MenuComponent.new(**options), &block)
  end

  def ui_sidebar_menu_item(**options, &block)
    render(Ui::Sidebar::MenuItemComponent.new(**options), &block)
  end

  def ui_sidebar_menu_button(**options, &block)
    render(Ui::Sidebar::MenuButtonComponent.new(**options), &block)
  end

  def ui_sidebar_menu_action(**options, &block)
    render(Ui::Sidebar::MenuActionComponent.new(**options), &block)
  end

  def ui_sidebar_menu_badge(**options, &block)
    render(Ui::Sidebar::MenuBadgeComponent.new(**options), &block)
  end

  def ui_sidebar_menu_skeleton(**options)
    render(Ui::Sidebar::MenuSkeletonComponent.new(**options))
  end

  def ui_sidebar_menu_sub(**options, &block)
    render(Ui::Sidebar::MenuSubComponent.new(**options), &block)
  end

  def ui_sidebar_menu_sub_item(**options, &block)
    render(Ui::Sidebar::MenuSubItemComponent.new(**options), &block)
  end

  def ui_sidebar_menu_sub_button(**options, &block)
    render(Ui::Sidebar::MenuSubButtonComponent.new(**options), &block)
  end

  def ui_aspect_ratio(**options, &block)
    render(Ui::AspectRatioComponent.new(**options), &block)
  end

  def ui_spinner(**options)
    render(Ui::SpinnerComponent.new(**options))
  end

  def ui_kbd(**options, &block)
    render(Ui::KbdComponent.new(**options), &block)
  end

  def ui_kbd_group(**options, &block)
    render(Ui::Kbd::GroupComponent.new(**options), &block)
  end

  def ui_empty(**options, &block)
    render(Ui::EmptyComponent.new(**options), &block)
  end

  def ui_empty_header(**options, &block)
    render(Ui::Empty::HeaderComponent.new(**options), &block)
  end

  def ui_empty_media(**options, &block)
    render(Ui::Empty::MediaComponent.new(**options), &block)
  end

  def ui_empty_title(**options, &block)
    render(Ui::Empty::TitleComponent.new(**options), &block)
  end

  def ui_empty_description(**options, &block)
    render(Ui::Empty::DescriptionComponent.new(**options), &block)
  end

  def ui_empty_content(**options, &block)
    render(Ui::Empty::ContentComponent.new(**options), &block)
  end

  def ui_item(**options, &block)
    render(Ui::ItemComponent.new(**options), &block)
  end

  def ui_item_group(**options, &block)
    render(Ui::Item::GroupComponent.new(**options), &block)
  end

  def ui_item_media(**options, &block)
    render(Ui::Item::MediaComponent.new(**options), &block)
  end

  def ui_item_content(**options, &block)
    render(Ui::Item::ContentComponent.new(**options), &block)
  end

  def ui_item_title(**options, &block)
    render(Ui::Item::TitleComponent.new(**options), &block)
  end

  def ui_item_description(**options, &block)
    render(Ui::Item::DescriptionComponent.new(**options), &block)
  end

  def ui_item_actions(**options, &block)
    render(Ui::Item::ActionsComponent.new(**options), &block)
  end

  def ui_item_header(**options, &block)
    render(Ui::Item::HeaderComponent.new(**options), &block)
  end

  def ui_item_footer(**options, &block)
    render(Ui::Item::FooterComponent.new(**options), &block)
  end

  def ui_item_separator(**options)
    render(Ui::Item::SeparatorComponent.new(**options))
  end

  def ui_input_group(**options, &block)
    render(Ui::InputGroupComponent.new(**options), &block)
  end

  def ui_input_group_addon(**options, &block)
    render(Ui::InputGroup::AddonComponent.new(**options), &block)
  end

  def ui_input_group_text(**options, &block)
    render(Ui::InputGroup::TextComponent.new(**options), &block)
  end

  def ui_input_group_input(**options)
    render(Ui::InputGroup::InputComponent.new(**options))
  end

  def ui_input_group_textarea(**options, &block)
    render(Ui::InputGroup::TextareaComponent.new(**options), &block)
  end

  def ui_input_group_button(**options, &block)
    render(Ui::InputGroup::ButtonComponent.new(**options), &block)
  end

  def ui_button_group(**options, &block)
    render(Ui::ButtonGroupComponent.new(**options), &block)
  end

  def ui_button_group_text(**options, &block)
    render(Ui::ButtonGroup::TextComponent.new(**options), &block)
  end

  def ui_button_group_separator(**options)
    render(Ui::ButtonGroup::SeparatorComponent.new(**options))
  end

  def ui_field(**options, &block)
    render(Ui::FieldComponent.new(**options), &block)
  end

  def ui_field_set(**options, &block)
    render(Ui::Field::SetComponent.new(**options), &block)
  end

  def ui_field_legend(**options, &block)
    render(Ui::Field::LegendComponent.new(**options), &block)
  end

  def ui_field_group(**options, &block)
    render(Ui::Field::GroupComponent.new(**options), &block)
  end

  def ui_field_content(**options, &block)
    render(Ui::Field::ContentComponent.new(**options), &block)
  end

  def ui_field_label(**options, &block)
    render(Ui::Field::LabelComponent.new(**options), &block)
  end

  def ui_field_title(**options, &block)
    render(Ui::Field::TitleComponent.new(**options), &block)
  end

  def ui_field_description(**options, &block)
    render(Ui::Field::DescriptionComponent.new(**options), &block)
  end

  def ui_field_separator(**options, &block)
    render(Ui::Field::SeparatorComponent.new(**options), &block)
  end

  def ui_field_error(**options, &block)
    render(Ui::Field::ErrorComponent.new(**options), &block)
  end

  def ui_native_select(**options, &block)
    render(Ui::NativeSelectComponent.new(**options), &block)
  end

  def ui_collapsible(**options, &block)
    render(Ui::CollapsibleComponent.new(**options), &block)
  end

  def ui_collapsible_trigger(**options, &block)
    render(Ui::Collapsible::TriggerComponent.new(**options), &block)
  end

  def ui_collapsible_content(**options, &block)
    render(Ui::Collapsible::ContentComponent.new(**options), &block)
  end

  def ui_toggle(**options, &block)
    render(Ui::ToggleComponent.new(**options), &block)
  end

  def ui_toggle_group(**options, &block)
    render(Ui::ToggleGroupComponent.new(**options), &block)
  end

  def ui_toggle_group_item(**options, &block)
    render(Ui::ToggleGroup::ItemComponent.new(**options), &block)
  end

  def ui_slider(**options)
    render(Ui::SliderComponent.new(**options))
  end

  def ui_hover_card(**options, &block)
    render(Ui::HoverCardComponent.new(**options), &block)
  end

  def ui_hover_card_trigger(**options, &block)
    render(Ui::HoverCard::TriggerComponent.new(**options), &block)
  end

  def ui_hover_card_content(**options, &block)
    render(Ui::HoverCard::ContentComponent.new(**options), &block)
  end

  def ui_input_otp(**options, &block)
    render(Ui::InputOtpComponent.new(**options), &block)
  end

  def ui_input_otp_group(**options, &block)
    render(Ui::InputOtp::GroupComponent.new(**options), &block)
  end

  def ui_input_otp_slot(**options)
    render(Ui::InputOtp::SlotComponent.new(**options))
  end

  def ui_input_otp_separator(**options)
    render(Ui::InputOtp::SeparatorComponent.new(**options))
  end
end
