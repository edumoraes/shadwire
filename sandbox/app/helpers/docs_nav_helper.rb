# frozen_string_literal: true

# The documentation sidebar, in the shadcn/ui model: one flat list of groups,
# each group a topic.
#
# Sandbox-only, like DocsHelper. Nothing here is part of the Shadwire registry.
#
# The Componentes group is derived from registry/registry.json instead of being
# listed by hand, so a component added to the registry shows up in the sidebar
# the moment it has a route. DocsNavCoverageTest fails when the two disagree.
module DocsNavHelper
  # Guides and reference pages, in reading order. Component pages are appended
  # by #docs_nav_groups.
  GUIDE_GROUPS = [
    {
      title: "Começar",
      items: [
        { title: "Introdução", route: :docs },
        { title: "Instalação", route: :docs_installation },
        { title: "shadwire.json", route: :docs_configuration },
        { title: "Theming", route: :docs_theming },
        { title: "Dark mode", route: :docs_dark_mode }
      ]
    },
    {
      title: "Ferramentas",
      items: [
        { title: "CLI", route: :docs_cli },
        { title: "Agent skill", route: :docs_agent_skill },
        { title: "Registry", route: :docs_registry },
        { title: "llms.txt", route: :docs_llms_txt }
      ]
    },
    {
      title: "Guias",
      items: [
        { title: "Composição", route: :docs_composition },
        { title: "Estilização", route: :docs_styling },
        { title: "Formulários", route: :docs_forms },
        { title: "Ícones", route: :docs_icons },
        { title: "Acessibilidade", route: :docs_accessibility }
      ]
    },
    {
      title: "Blocks",
      # The individual blocks are deliberately absent: a block renders standalone
      # under the "block" layout, with no header, no sidebar and no way back. The
      # index frames each one in an iframe and links to the full-screen version.
      items: [
        { title: "Visão geral", route: :blocks }
      ]
    }
  ].freeze

  # Every sidebar group, with the component catalog appended.
  def docs_nav_groups
    @docs_nav_groups ||= GUIDE_GROUPS.map { |group| resolve_group(group) } + [ docs_nav_components_group ]
  end

  # The component catalog as a sidebar group, alphabetical by title after the
  # catalog index. Names come from the registry; paths from the routes the
  # components controller defines.
  def docs_nav_components_group
    items = docs_component_items.map do |item|
      { title: item.fetch("title"), path: "/components/#{item.fetch("name")}" }
    end

    {
      title: "Componentes",
      items: [ { title: "Visão geral", path: components_path } ] + items.sort_by { |item| item[:title].downcase }
    }
  end

  # Registry items of type "component", in manifest order.
  def docs_component_items
    registry_items.values.select { |item| item.fetch("type") == "component" }
  end

  # Every sidebar entry, flattened into the order the previous/next pager walks.
  def docs_nav_items
    @docs_nav_items ||= docs_nav_groups.flat_map { |group| group[:items] }
  end

  # The sidebar entry for the page being rendered, or nil for pages that are not
  # in the sidebar (the landing page, for one).
  def docs_current_item
    return @docs_current_item if defined?(@docs_current_item)

    @docs_current_item = docs_nav_items.find { |item| docs_nav_current?(item) }
  end

  # The group holding the current page, used for the breadcrumb.
  def docs_current_group
    return @docs_current_group if defined?(@docs_current_group)

    @docs_current_group = docs_nav_groups.find { |group| group[:items].any? { |item| docs_nav_current?(item) } }
  end

  # [previous, next] around the current page. Either may be nil at the ends.
  def docs_nav_siblings
    index = docs_nav_items.index { |item| docs_nav_current?(item) }
    return [ nil, nil ] unless index

    [ (docs_nav_items[index - 1] if index.positive?), docs_nav_items[index + 1] ]
  end

  def docs_nav_current?(item)
    # current_page? raises a bare RuntimeError without a request (a view test, a
    # component preview), and there is no current page to compare against there.
    return false unless respond_to?(:request) && request

    current_page?(item[:path])
  end

  # Which top-level section the header highlights: :docs, :components, :blocks
  # or nil on the landing page.
  def site_nav_section
    case request.path
    when %r{\A/docs} then :docs
    when %r{\A/components} then :components
    when %r{\A/blocks} then :blocks
    end
  end

  private

  def resolve_group(group)
    { title: group[:title], items: group[:items].map { |item| { title: item[:title], path: send(:"#{item[:route]}_path") } } }
  end
end
