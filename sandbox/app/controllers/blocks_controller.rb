# frozen_string_literal: true

# Serves the block documentation pages of the sandbox. Blocks are full-page
# compositions of components, so the preview renders standalone (block layout)
# and the index embeds each one in an iframe.
class BlocksController < ApplicationController
  BLOCKS = [
    {
      name: "sidebar-01",
      title: "Sidebar 01",
      description: "Uma sidebar de navegação com seletor de versão, busca e grupos de links.",
      path_helper: :blocks_sidebar_01_path
    }
  ].freeze

  def index
    @blocks = BLOCKS
  end

  def sidebar_01
    render layout: "block"
  end
end
