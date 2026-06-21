# CI/CD

This repo uses GitHub Actions. The repo root is not a Rails app, so the pipeline
validates two layers: the registry manifest (root) and the `sandbox/` Rails app.

## Workflows

| Workflow | Trigger | What it does |
| --- | --- | --- |
| `CI` (`ci.yml`) | PRs + push to `main` | `lint`, `security`, `test`, `registry_sync`, `docs_lint` jobs, then `deploy_pages` on `main`. |
| `Dependency Review` (`dependency-review.yml`) | PRs | Blocks PRs that introduce dependencies with known high-severity vulnerabilities. |
| `Labeler` (`labeler.yml`) | PRs | Adds `area:*` labels based on changed paths (`.github/labeler.yml`). |

### CI jobs

- **lint** — `bin/rubocop` (rails-omakase) in `sandbox/`.
- **security** — `bin/bundler-audit`, `bin/importmap audit`, and Brakeman. Mirrors
  `sandbox/config/ci.rb`, except Brakeman runs via `bundle exec` (without `bin/brakeman`'s
  `--ensure-latest`, which would fail CI whenever a newer Brakeman ships before Dependabot bumps it).
- **test** — `bin/rails test test/components test/integration/ui_accessibility_test.rb` + seeds,
  run with `PARALLEL_WORKERS=1` (the sandbox's parallel runner can deadlock with zombie workers),
  plus the root `registry_manifest_test.rb` and `registry_schema_test.rb`.
- **registry_sync** — runs `bin/sync_registry` and fails if it produces a diff. This is the
  **drift guard**: `registry/` is the source of truth, `sandbox/app/...` is generated. Edit in
  `registry/`, run `bin/sync_registry`, and commit the result.
- **docs_lint** — markdownlint (blocking) + lychee link check (lenient).
- **deploy_pages** — only on `main`, after every other job is green.

`Dependabot` (`.github/dependabot.yml`) opens weekly grouped update PRs for the
`sandbox/` gems and for the GitHub Actions used here.

## GitHub Pages deploy

The sandbox is a dynamic Rails docs site. `deploy_pages` freezes it to static HTML
and publishes to **project Pages** (`https://<owner>.github.io/shadwire/`):

1. Sets `PAGES_BASE_PATH=/shadwire`. `config.ru` mounts the app under that sub-URI
   and `config/environments/production.rb` sets `relative_url_root`, so links, asset
   paths, and the importmap all emit `/shadwire/...`. Both are inert when the env var
   is unset, so normal dev/prod is unchanged.
2. `assets:precompile` + `db:prepare`, boots the app, waits for `/shadwire/up`.
3. `wget --mirror` crawls every reachable page; `--cut-dirs=1` strips the prefix so the
   artifact root maps onto the Pages base path.
4. Copies `public/assets` wholesale (wget does not follow importmap/ES modules).
5. Uploads and deploys with `actions/deploy-pages`.

> Known minor limitation: the default favicons are referenced at the domain root
> (`/icon.png`), so they 404 under project Pages. Cosmetic only.

## One-time repository setup

Branch protection, labels, and enabling Pages are repo settings, not files. Apply
them with the `gh` CLI (needs admin + `jq`):

```bash
bin/setup_repo
```

This creates the `area:*` labels, enables Pages with the **GitHub Actions** source,
and applies a `main` ruleset: require a PR with 1 approval and resolved conversations,
required status checks (`lint`, `security`, `test`, `registry_sync`, `docs_lint`),
linear history, and no force-pushes or deletions.

The required-check names must match the CI job ids. If you rename a job in `ci.yml`,
update `REQUIRED_CHECKS` in `bin/setup_repo` and re-run it.

### Dependency Review

The `dependency-review` workflow needs the repository **Dependency graph** enabled. If
the check reports "Dependency review is not supported on this repository", turn it on at
`Settings → Code security and analysis → Dependency graph` (it goes green on the next PR).
This check is intentionally **not** a required status check, so it never blocks a merge.

## Running it locally

```bash
cd sandbox && bin/ci                       # full sandbox pipeline (lint, security, tests)
ruby test/registry_manifest_test.rb        # root manifest test
ruby test/registry_schema_test.rb          # root schema test
bin/sync_registry && git status --porcelain # should print nothing (no drift)
```
