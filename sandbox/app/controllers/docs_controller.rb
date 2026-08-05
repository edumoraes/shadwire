# frozen_string_literal: true

# Serves the guide and reference pages of the documentation site. Components and
# blocks have their own controllers.
#
# Pages are plain views; only the ones that need repeated data (command tables,
# token tables) get it from here, so the prose stays in the view.
#
# That data is tabular and entirely prose, so it lives in the locale files and
# is read back as an array of hashes rather than being frozen into a constant:
# a constant is built once at boot, and this site renders in two languages.
class DocsController < ApplicationController
  layout "docs"

  # Code samples live in DocsSnippets because an ERB template cannot hold a
  # heredoc containing ERB tags. Every action gets its page's hash.
  before_action { @snippets = DocsSnippets.for(action_name) }

  def index; end

  def installation; end

  def configuration; end

  def theming
    # The shadcn semantic tokens, as installed in vendor/shadwire/shadwire.css.
    @tokens = t("docs.theming.tokens")
  end

  def dark_mode; end

  def cli
    # The CLI's command surface. Mirrors packages/cli/README.md, which is the
    # reference the CLI itself ships.
    @commands = t("docs.cli.commands")
    # Flags shared by more than one command, documented once.
    @flags = t("docs.cli.flags")
  end

  def agent_skill
    # The files the agent skill ships, and what each one carries.
    @skill_files = t("docs.agent_skill.files")
  end

  def registry; end

  def llms_txt; end

  def composition; end

  def styling; end

  def forms; end

  def icons; end

  def accessibility; end

  def localisation
    # Every I18n key a registry component reads, grouped by component. The
    # defaults are what an installed component says with no locale file at all,
    # so they are the same text in both languages and belong here rather than in
    # the locale files.
    @keys = DocsLocaleKeys.grouped
  end
end
