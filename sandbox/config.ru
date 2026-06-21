# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# When PAGES_BASE_PATH is set (GitHub Pages export), mount the app under that
# sub-URI so routing matches the prefixed paths the helpers generate. Inert
# otherwise. Pairs with config.relative_url_root in config/environments/production.rb.
if ENV["PAGES_BASE_PATH"].to_s.start_with?("/") && ENV["PAGES_BASE_PATH"] != "/"
  map ENV["PAGES_BASE_PATH"] do
    run Rails.application
  end
else
  run Rails.application
end

Rails.application.load_server
