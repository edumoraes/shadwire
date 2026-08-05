# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale

  private

  # The locale comes from the URL and from nowhere else — no session, no cookie,
  # no Accept-Language. The site is published as a static snapshot, so a page's
  # language has to be a property of its address; anything negotiated at request
  # time would be frozen into whatever the crawler happened to ask for.
  #
  # The route constraint admits only the non-default locale, so params[:locale]
  # is either "pt" or absent.
  def switch_locale(&)
    I18n.with_locale(params[:locale] || I18n.default_locale, &)
  end

  # Keeps every generated link inside the language being read. The default
  # locale is served from the root, so it contributes no path segment.
  def default_url_options
    return {} if I18n.locale == I18n.default_locale

    { locale: I18n.locale }
  end
end
