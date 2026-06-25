Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

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

  # Block documentation pages (composed, full-page layouts).
  get "blocks", to: "blocks#index"
  get "blocks/sidebar-01", to: "blocks#sidebar_01", as: :blocks_sidebar_01

  # Defines the root path route ("/")
  root "showcase#index"
end
