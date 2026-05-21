# frozen_string_literal: true

task default: :test

task :test do
  ruby "test/registry_manifest_test.rb"
  Dir.chdir("sandbox") do
    sh "bin/rails test test/components test/integration/ui_accessibility_test.rb"
  end
end
