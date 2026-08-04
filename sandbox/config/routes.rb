Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Guides and reference pages. Grouped by topic in the sidebar (DocsNavHelper).
  get "docs", to: "docs#index"
  get "docs/installation", to: "docs#installation", as: :docs_installation
  get "docs/configuration", to: "docs#configuration", as: :docs_configuration
  get "docs/theming", to: "docs#theming", as: :docs_theming
  get "docs/dark-mode", to: "docs#dark_mode", as: :docs_dark_mode
  get "docs/cli", to: "docs#cli", as: :docs_cli
  get "docs/agent-skill", to: "docs#agent_skill", as: :docs_agent_skill
  get "docs/registry", to: "docs#registry", as: :docs_registry
  get "docs/llms-txt", to: "docs#llms_txt", as: :docs_llms_txt
  get "docs/composition", to: "docs#composition", as: :docs_composition
  get "docs/styling", to: "docs#styling", as: :docs_styling
  get "docs/forms", to: "docs#forms", as: :docs_forms
  get "docs/icons", to: "docs#icons", as: :docs_icons
  get "docs/accessibility", to: "docs#accessibility", as: :docs_accessibility

  # Component catalog index and documentation pages.
  get "components", to: "components#index"
  get "components/button", to: "components#button"
  get "components/badge", to: "components#badge"
  get "components/card", to: "components#card"
  get "components/alert", to: "components#alert"
  get "components/separator", to: "components#separator"
  get "components/avatar", to: "components#avatar"
  get "components/icon", to: "components#icon"
  get "components/accordion", to: "components#accordion"
  get "components/scroll-area", to: "components#scroll_area"
  get "components/input", to: "components#input"
  get "components/label", to: "components#label"
  get "components/textarea", to: "components#textarea"
  get "components/checkbox", to: "components#checkbox"
  get "components/radio-group", to: "components#radio_group"
  get "components/switch", to: "components#switch"
  get "components/skeleton", to: "components#skeleton"
  get "components/progress", to: "components#progress"
  get "components/table", to: "components#table"
  get "components/breadcrumb", to: "components#breadcrumb"
  get "components/pagination", to: "components#pagination"
  get "components/tabs", to: "components#tabs"
  get "components/dialog", to: "components#dialog"
  get "components/alert-dialog", to: "components#alert_dialog"
  get "components/sheet", to: "components#sheet"
  get "components/tooltip", to: "components#tooltip"
  get "components/popover", to: "components#popover"
  get "components/dropdown-menu", to: "components#dropdown_menu"
  get "components/select", to: "components#select"
  get "components/sidebar", to: "components#sidebar"
  get "components/aspect-ratio", to: "components#aspect_ratio"
  get "components/spinner", to: "components#spinner"
  get "components/kbd", to: "components#kbd"
  get "components/empty", to: "components#empty"
  get "components/item", to: "components#item"
  get "components/input-group", to: "components#input_group"
  get "components/button-group", to: "components#button_group"
  get "components/field", to: "components#field"
  get "components/native-select", to: "components#native_select"
  get "components/collapsible", to: "components#collapsible"
  get "components/toggle", to: "components#toggle"
  get "components/toggle-group", to: "components#toggle_group"
  get "components/slider", to: "components#slider"
  get "components/hover-card", to: "components#hover_card"
  get "components/input-otp", to: "components#input_otp"
  get "components/drawer", to: "components#drawer"
  get "components/context-menu", to: "components#context_menu"
  get "components/menubar", to: "components#menubar"
  get "components/navigation-menu", to: "components#navigation_menu"
  get "components/command", to: "components#command"
  get "components/combobox", to: "components#combobox"
  get "components/calendar", to: "components#calendar"
  get "components/date-picker", to: "components#date_picker"
  get "components/resizable", to: "components#resizable"
  get "components/carousel", to: "components#carousel"
  get "components/sonner", to: "components#sonner"
  get "components/chart", to: "components#chart"
  get "components/data-table", to: "components#data_table"

  # Block documentation pages (composed, full-page layouts).
  get "blocks", to: "blocks#index"
  get "blocks/sidebar-01", to: "blocks#sidebar_01", as: :blocks_sidebar_01

  # Defines the root path route ("/")
  root "showcase#index"
end
