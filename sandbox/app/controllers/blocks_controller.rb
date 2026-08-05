# frozen_string_literal: true

# Serves the block documentation pages of the sandbox. Blocks are full-page
# compositions of components, so the preview renders standalone (block layout)
# and the index embeds each one in an iframe.
class BlocksController < ApplicationController
  # Names and route only — the description is prose, so it is looked up per
  # request from the locale files rather than frozen into the constant at boot.
  BLOCKS = [
    { name: "sidebar-01", title: "Sidebar 01", path_helper: :blocks_sidebar_01_path }
  ].freeze

  def index
    @blocks = BLOCKS.map { |block| block.merge(description: t("blocks.#{block[:name].tr("-", "_")}.description")) }
    render layout: "docs"
  end

  def sidebar_01
    render layout: "block"
  end
end
