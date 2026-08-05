# frozen_string_literal: true

# Serves the block documentation pages of the sandbox. Blocks are full-page
# compositions of components, so the preview renders standalone (block layout)
# and the index embeds each one in an iframe.
class BlocksController < ApplicationController
  # Names and route only. The description comes from the registry item, through
  # the same per-locale override the component catalog uses — a block is a
  # registry item like any other, and describing it in a second place is how the
  # two came to disagree.
  BLOCKS = [
    { name: "sidebar-01", title: "Sidebar 01", path_helper: :blocks_sidebar_01_path }
  ].freeze

  def index
    @blocks = BLOCKS.map do |block|
      item = helpers.registry_item(block[:name])
      block.merge(description: item && helpers.registry_description(item))
    end
    render layout: "docs"
  end

  def sidebar_01
    render layout: "block"
  end
end
