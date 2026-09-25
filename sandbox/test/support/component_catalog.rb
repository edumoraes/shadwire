# frozen_string_literal: true

# Every registry component in the sandbox, and what each needs before it can
# render at all — for the tests that hold every component to one rule rather
# than the ones someone remembered to test.
module ComponentCatalog
  FILES = Dir[Rails.root.join("app/components/ui/**/*_component.rb")].sort.freeze

  # Class names, discovered from the synced source so a new component is
  # covered the day it is added. Blocks are pages built from parts, not parts.
  NAMES = FILES.filter_map { |file|
    name = Pathname.new(file).relative_path_from(Rails.root.join("app/components")).to_s.delete_suffix(".rb").camelize
    name unless name.start_with?("Ui::Blocks::")
  }.freeze

  REQUIRED = {
    "Ui::IconComponent" => [ [ "check" ], {} ],
    "Ui::RadioGroup::ItemComponent" => [ [], { name: "plan", value: "free" } ],
    "Ui::Select::ItemComponent" => [ [], { value: "one" } ],
    "Ui::Tabs::TriggerComponent" => [ [], { value: "one" } ],
    "Ui::Tabs::ContentComponent" => [ [], { value: "one" } ],
    "Ui::DataTableComponent" => [ [], { columns: [ { key: :name, label: "Name" } ], rows: [ { name: "Ada" } ] } ]
  }.freeze

  module_function

  def build(class_name, **attrs)
    args, required = REQUIRED.fetch(class_name, [ [], {} ])
    class_name.constantize.new(*args, **required, **attrs)
  end
end
