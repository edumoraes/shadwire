# frozen_string_literal: true

namespace :docs do
  desc "Build public/search-index.<locale>.json, the corpus the ⌘K palette searches"
  task search_index: :environment do
    DocsSearchIndex.write.each do |locale, bytes|
      path = DocsSearchIndex.path_for(locale).relative_path_from(Rails.root)
      puts "Wrote #{path} (#{(bytes / 1024.0).round} KB)"
    end
  end
end
