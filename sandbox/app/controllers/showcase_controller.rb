# frozen_string_literal: true

# Serves the documentation landing page (the root "/").
class ShowcaseController < ApplicationController
  layout "home"

  # Components featured on the home page: each one reuses an example partial
  # from app/views/components/examples/, showing a live preview + its code.
  # Names only — each caption is translated, so it resolves per request instead
  # of being frozen into the constant at boot.
  SHOWCASE_EXAMPLES = %w[with_icon card_default input_with_label alert_default].freeze

  def index
    @showcase = SHOWCASE_EXAMPLES.map do |name|
      { name:, title: t("home.showcase.#{name}.title"), description: t("home.showcase.#{name}.description") }
    end
  end
end
