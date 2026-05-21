# Shadwire

Shadwire ports the shadcn/ui Open Code model to Ruby on Rails.

The source of truth is `registry/`. The Rails app in `sandbox/` consumes copied registry files so components are validated in a real Rails, ViewComponent, Tailwind CSS v4, and Hotwire environment.

## MVP

Initial components:

- Button
- Badge
- Card
- Alert
- Separator
- Avatar

## Workflow

Sync registry files into the sandbox:

```bash
bin/sync_registry
```

Run sandbox tests:

```bash
cd sandbox
bin/rails test test/components test/integration/ui_accessibility_test.rb
```

## Commits

Use Conventional Commits, for example:

```bash
git commit -m "feat: add button component"
git commit -m "test: cover card component"
git commit -m "docs: update registry workflow"
```
