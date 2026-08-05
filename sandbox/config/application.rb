require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sandbox
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # This app stores no files, so it never builds a variant. Left on the 8.1
    # default (:vips) Active Storage requires ruby-vips at boot and refuses to
    # start without it.
    config.active_storage.variant_processor = :disabled

    # The site ships in English and Portuguese. English is the default and is
    # served from the site root; Portuguese lives under /pt. Fallbacks let a
    # page go out in English while its translation is still pending, instead of
    # rendering a raw translation-missing span.
    config.i18n.available_locales = %i[en pt]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [ :en ]

    # The public origin the site is served from. Canonical and hreflang links
    # have to be absolute and must not be derived from the request: the
    # published site is frozen by crawling http://127.0.0.1:3000, so
    # request.base_url would bake the build host into every page.
    config.x.site_url = ENV.fetch("SITE_URL", "https://shadwire.edumoraes.dev.br")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.view_component.preview_paths ||= config.view_component.previews.paths
    config.view_component.preview_paths << Rails.root.join("test/components/previews")
  end
end
