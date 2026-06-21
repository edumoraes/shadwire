## What & why

<!-- What does this change and why? Link any related issue. -->

## Checklist

- [ ] Component source was edited in `registry/` (never directly in `sandbox/app/...`).
- [ ] Ran `bin/sync_registry` and committed the resulting `sandbox/` changes.
- [ ] Tests pass locally (`cd sandbox && bin/ci`, plus `ruby test/registry_manifest_test.rb` and `ruby test/registry_schema_test.rb`).
- [ ] Rubocop is clean (`cd sandbox && bin/rubocop`).
- [ ] Commit messages follow Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).
- [ ] For a new component: added the `items[]` entry, the `ui_*` helper, and render tests.
