# frozen_string_literal: true

require "nokogiri"

# Builds the full-text index the ⌘K palette searches.
#
# The published site is a static crawl — CI freezes the app with `wget --mirror`
# and GitHub Pages serves the result — so there is no server left to query at
# request time. Any search beyond "does the title contain this" has to ship an
# index to the browser. Measured against the deployed site it is about 54 KB
# gzipped, which is affordable when it is fetched on the first ⌘K rather than on
# page load.
#
# Pages are rendered through the app rather than scraped out of _site, so the
# index does not depend on the wget step having run, or on how it named files.
#
# Only <main> is indexed. The sidebar, the header and the palette itself are
# chrome repeated on all 70-odd pages: indexing them would make every page match
# every navigational word.
#
# Sandbox-only: nothing here ships in the Shadwire registry.
module DocsSearchIndex
  PUBLIC_DIR = Rails.root.join("public")

  # One file per language, not one file for the site. A reader downloads only
  # the tree they are reading — half the bytes, and no results in a language
  # they are not looking at.
  def self.path_for(locale, dir: PUBLIC_DIR) = dir.join("search-index.#{locale}.json")

  module_function

  # { locale => bytes written }
  def write(dir: PUBLIC_DIR)
    I18n.available_locales.to_h do |locale|
      payload = JSON.generate(entries_for(locale))
      DocsSearchIndex.path_for(locale, dir:).write(payload)
      [ locale, payload.bytesize ]
    end
  end

  # [{ locale:, path:, title:, group:, headings: [], text: }]
  def build
    I18n.available_locales.flat_map { |locale| entries_for(locale) }
  end

  def entries_for(locale)
    session = ActionDispatch::Integration::Session.new(Rails.application)
    # The default integration host is www.example.com, which Rails' host
    # authorization rejects in development before any route is reached.
    session.host! "localhost"
    root = locale == I18n.default_locale ? "/docs" : "/#{locale}/docs"

    pages_for(session, root).filter_map do |page|
      session.get(page[:path])
      next unless session.response.status == 200

      entry(page, locale, Nokogiri::HTML(session.response.body))
    end
  end

  # The pages to index are read off the palette itself, on any page that renders
  # it. That is a stronger guarantee than rebuilding the list from DocsNavHelper:
  # the index then describes exactly the pages the palette can reach — no entry
  # for a page it does not offer, no page offered without an entry — and it comes
  # out already carrying each page's title and group, in the right language.
  def pages_for(session, root)
    session.get(root)
    unless session.response.status == 200
      raise "cannot reach #{root} to enumerate the documentation (#{session.response.status})"
    end

    Nokogiri::HTML(session.response.body).css("[data-slot='command-group']").flat_map do |group|
      heading = squish(group.at_css("[data-slot='command-group-heading']")&.text.to_s)

      group.css("[data-slot='command-item'][data-href]").map do |item|
        { path: item["data-href"], title: squish(item.text), group: heading }
      end
    end.uniq { |page| page[:path] }
  end

  def entry(page, locale, document)
    main = document.at_css("main")
    return if main.nil?

    {
      locale: locale.to_s,
      path: page[:path],
      title: page[:title],
      group: page[:group],
      headings: main.css("h2, h3").map { |heading| squish(heading.text) }.reject(&:empty?),
      text: squish(main.text)
    }
  end

  def squish(text)
    text.gsub(/\s+/, " ").strip
  end
end
