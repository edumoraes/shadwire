# frozen_string_literal: true

# The bilingual plumbing of the docs site: naming the locales, addressing the
# page being rendered in the other language, and building the absolute URLs the
# document head advertises.
#
# Sandbox-only, like DocsHelper. Nothing here is part of the Shadwire registry.
module LocaleHelper
  # Endonyms. A language picker is read by someone who does not necessarily read
  # the language currently on screen, so each option names itself.
  LOCALE_NAMES = { en: "English", pt: "Português" }.freeze

  # What each locale claims in hreflang and in <html lang>. The prose is
  # Brazilian Portuguese; "en" stays unregionalised, since nothing in it is
  # specific to one English-speaking market.
  LOCALE_TAGS = { en: "en", pt: "pt-BR" }.freeze

  def site_locales
    I18n.available_locales
  end

  def locale_name(locale)
    LOCALE_NAMES.fetch(locale.to_sym, locale.to_s)
  end

  def locale_tag(locale)
    LOCALE_TAGS.fetch(locale.to_sym, locale.to_s)
  end

  # The page being rendered, addressed in another locale. Built through the
  # routing table rather than by string surgery on request.path, so it stays
  # right for the root — where the Portuguese counterpart is /pt, not /pt/ —
  # and for any later route whose two versions are not a bare prefix apart.
  def locale_path(locale)
    url_for(locale: locale_segment(locale), only_path: true)
  rescue ActionController::UrlGenerationError, RuntimeError
    # Rendered outside a request (a view test, a component preview) or from a
    # page that is not in the routing table. Fall back to the locale's home.
    locale.to_sym == I18n.default_locale ? "/" : "/#{locale}"
  end

  # The same address, absolute. hreflang and canonical cannot be relative, and
  # must not be derived from the request — see config.x.site_url.
  def locale_url(locale)
    "#{Rails.application.config.x.site_url}#{locale_path(locale)}"
  end

  private

  # The default locale is served from the root and contributes no segment.
  def locale_segment(locale)
    locale.to_sym == I18n.default_locale ? nil : locale.to_s
  end
end
