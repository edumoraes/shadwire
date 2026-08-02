---
name: release
description: Use when the shadwire CLI gem may need publishing to RubyGems — after merging a user-facing change under packages/cli/, when version.rb is ahead of the newest v* tag, when skills/ documents CLI behavior that is not released yet, or when someone asks whether a release is needed.
---

# Cutting a shadwire release

Publishing is **tag-driven and irreversible**. Pushing a `vX.Y.Z` tag runs
`.github/workflows/release.yml`, which verifies the tag matches
`Shadwire::VERSION`, runs the CLI suite, and publishes to RubyGems via trusted
publishing (OIDC — no API key anywhere). A version number can be yanked but
never reused.

Nothing gates that push: `main`'s ruleset does not cover tags, and the
`rubygems` environment has no protection rules. **Confirm with the user before
pushing the tag** — it is the only brake there is.

## Is a release needed?

Any "yes" wins. Ordered by which one people miss.

```bash
LAST=$(git describe --tags --abbrev=0)
git log --oneline "$LAST..main" -- skills/            # 1. skill ahead of the gem?
git log --oneline "$LAST..main" -- packages/cli/lib   # 2. CLI ahead of the tag?
grep VERSION packages/cli/lib/shadwire/version.rb; echo "$LAST"   # 3. bump merged unreleased?
```

**Check 1 is the decisive, non-obvious one.** `skills/` ships straight from this
repo via `npx skills add edumoraes/shadwire` — it goes live for consumers **at
merge**. `packages/cli/` reaches nobody until a **tag push**. So merging both in
one PR publishes documentation for a CLI that cannot be installed: the skill
tells agents to read fields and run commands the released gem does not have.
That is what forced v0.3.0.

Check 3 exists because v0.2.1 had to be cut when a registry-redirect fix sat
merged and unreleased for three days.

## Procedure

```bash
# 1. Preconditions — never tag a stale local main
git checkout main && git fetch origin --tags --prune && git pull --ff-only
grep VERSION packages/cli/lib/shadwire/version.rb        # decides X.Y.Z below
git tag --list "vX.Y.Z"                                  # must print nothing
gh run list --branch main --workflow=ci.yml --limit 1    # must be success
```

**2. Bump, only if the feature PR did not.** Default is that it rides in the
feature PR (v0.2.0, v0.3.0). A standalone release PR (v0.2.1) is only for
shipping something already merged. `main` requires a PR either way:

```bash
git switch -c chore/release-X.Y.Z
# edit ONLY packages/cli/lib/shadwire/version.rb
git commit -am "chore(cli): release X.Y.Z"
git push -u origin chore/release-X.Y.Z && gh pr create --fill
gh pr checks --watch && gh pr merge --squash --delete-branch
git checkout main && git pull --ff-only
```

**3. Ask the user before the next command.** It publishes, and nothing undoes it.

```bash
# 4. Tag and push — annotated, subject exactly `shadwire X.Y.Z`
git tag -a vX.Y.Z -m "shadwire X.Y.Z" -m "<what users get>"
git push origin vX.Y.Z

# 5. Watch the run FOR THIS TAG. Pin to the tag ref: `--limit 1` alone races the
#    tag push and returns the PREVIOUS release run, which is already green, so
#    `--exit-status` exits 0 immediately and reports a publish that never ran.
until RUN=$(gh run list --workflow=release.yml --branch vX.Y.Z --limit 1 \
              --json databaseId -q '.[0].databaseId') && [ -n "$RUN" ]; do sleep 5; done
gh run watch "$RUN" --exit-status
```

Only `packages/cli/lib/shadwire/version.rb` carries the gem version.
`registry/registry.json`'s `version` is the *registry*'s and is deliberately
independent — do not bump it to match.

## Verifying it landed

**Use `api/v1/versions/`, not `api/v1/gems/`.** The `gems` endpoint is cached and
served the previous version for minutes after v0.3.0 published — long enough to
read as a failed release and tempt a re-tag.

```bash
curl -s https://rubygems.org/api/v1/versions/shadwire.json \
  | ruby -rjson -e 'puts JSON.parse($stdin.read).first["number"]'
```

Then smoke-test the **published gem**, not the working tree — no test in this
repo touches the network, which is how the v0.2.0 registry breakage shipped
green. `init` calls `raise_unless_rails!`, so the scratch app needs
`config/application.rb`; the local `path` setting avoids the system-gemdir
permission error:

```bash
gem install shadwire -v X.Y.Z --no-document
APP=$(mktemp -d)/app && mkdir -p "$APP/config" && cd "$APP"
printf 'source "https://rubygems.org"\ngem "shadwire", group: :development\n' > Gemfile
echo '# rails' > config/application.rb
bundle config set --local path vendor/bundle && bundle install
bundle exec shadwire init --yes && ./bin/shadwire version && ./bin/shadwire status
```

If the release fixed something `skills/` relies on, follow that skill's own
bootstrap instructions verbatim against this app. Passing tests do not prove a
consumer can follow the documentation.

## Common mistakes

| Mistake | Reality |
| --- | --- |
| `gh run watch` on `--limit 1` | Races the tag push; returns the previous green run. Pin `--branch vX.Y.Z` |
| Checking `api/v1/gems/shadwire.json` | Cached; use the `versions` endpoint |
| Re-tagging when RubyGems looks stale | The workflow run is the authority, not the cache. Re-poll; never move a tag |
| Cutting X.Y.Z+1 to escape a cache | Burns a version number permanently |
| Bumping `registry/registry.json` | Different version, deliberately independent |
| Tagging without asking | Irreversible, outward-facing, and ungated |
| "Tests are green, so it works" | Nothing here touches the network. Install the gem |
| Creating a GitHub Release | This repo has never made one. Release notes live in the annotated tag body |

`shadwire.gemspec` points `changelog_uri` at `/releases`, which is empty — a real
inconsistency, but a separate PR, not a step to improvise mid-release.
