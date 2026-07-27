# frozen_string_literal: true

task default: :test

task :test do
  ruby "test/registry_manifest_test.rb"
  ruby "test/registry_schema_test.rb"
  ruby "test/registry_build_test.rb"
  ruby "test/api_extractor_test.rb"
  ruby "test/llms_writer_test.rb"
  ruby "test/skill_check_test.rb"
  Dir.chdir("sandbox") do
    sh "bin/rails test test/components test/integration/ui_accessibility_test.rb"
  end
end
