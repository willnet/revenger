# Revenger

Revenger is for reviewing your notes frequently.

## Set up for development

- use devcontainers

JavaScript is loaded with importmap-rails. Turbo and Stimulus are provided by the
turbo-rails and stimulus-rails gems. Asset precompilation runs entirely in Ruby,
without Node.js or npm packages.

## Develop with Git Worktree

Use `bin/dc` to run Dev Container commands. It automatically derives `COMPOSE_PROJECT_NAME`
and `PORT` from the current worktree path, so containers/volumes/ports do not conflict
across worktrees.

When `bin/dc up` is run from a non-interactive CLI (for example, by an AI agent), it
automatically adds `--skip-post-attach` so `postAttachCommand` does not block the caller.

```sh
# Example: create a new worktree
git worktree add ../revenger-feature-a feature-a

# In each worktree directory
bin/dc up --workspace-folder .
bin/dc exec --workspace-folder . bin/setup
bin/dc exec --workspace-folder . bin/dev
```

The default port range is `3000-3199` and is selected automatically per worktree.

If you need to clean up existing resources for the current worktree:

```sh
eval "$(bin/devcontainer-env --export)"
docker compose -f .devcontainer/compose.yaml down -v
```

## Mutation testing

[Mutineer](https://davidteren.github.io/mutineer/) checks whether the unit tests
detect changed comparisons, literals, and conditions. Run it inside the Dev Container:

```sh
bin/dc exec --workspace-folder . bin/mutineer run app/models app/contexts
```

Source files are paired with their corresponding specs. To focus on one model:

```sh
bin/dc exec --workspace-folder . bin/mutineer run app/models/post.rb
```

`bin/mutineer` selects the test environment and disables Bootsnap because its
compile cache conflicts with coverage collection. Rails is booted once, and
mutations run serially because the RSpec tests share the test database.
Run mutation testing separately from other test runs.
Reports and caches are ignored under `.mutineer/`; save a report with
`--format json --output .mutineer/report.json`.

Review survivors for missing behaviour before adding tests. Mutineer generates
mutations inside methods; class-level validation limits and comparisons inside
SQL strings need separate verification.

### AI completion hooks

Codex (`.codex/hooks.json`) and Claude Code (`.claude/settings.json`) share
Ruby checks and the instructions in `AGENTS.md`; no `CLAUDE.md` is needed with
Claude Code 2.1.277 or later and AGENTS.md loading enabled. Review the hook
definitions in each client before trusting them.

`UserPromptSubmit` records file hashes for that session. `Stop` compares the
current files with that snapshot, so read-only questions and documentation-only
edits do not trigger mutation testing. Local hooks do not need Git, `origin/main`,
or a working worktree Git pointer. If the start hook did not run, Stop reports
that it cannot determine changes; the next user input establishes a baseline.

```sh
bin/check-test-boundaries --run
```

The shell entry point dispatches all Ruby processing to the Dev Container on the
host. Docker and Podman markers and Dev Container/Codespaces environment markers
are recognized. Use `--local --run` in another prepared Ruby environment. Start
the container with `bin/dc up --workspace-folder .` before using the hooks.
Transport failures are reported separately from invalid mutation reports.

The run scans all models and contexts, with explicit model/context specs, even
for spec-only changes. Change detection and cache validation use the same file
selection: application Ruby, library Ruby/rake, database Ruby/SQL, unit specs and
their support files, runtime configuration including encrypted credentials, and
dependencies/checker settings. System specs and deployment configuration are
excluded. Mutineer temporary source files are ignored in snapshots and Git.

The lock is acquired inside the execution environment and inherited by the
Mutineer process and its forked workers. An interrupted host launcher cannot
release the lock while those processes still run. Reports, logs, and success
records live under `.mutineer/`. Run other RSpec commands separately because
they also share the test database.

Survivors, uncovered code, unscored runs, execution failures, and malformed
reports remain unresolved. Reviewed equivalent mutants may be listed in
`.mutineer.yml` as mappings with an `id` and a nonblank `reason`. Only exclusions
with such an approval are accepted; do not add suppressions merely for a score.
A run containing only approved equivalents is recorded as reviewed, while an
empty run remains unresolved. Constants and SQL comparisons need separate review.

The Stop hook requests continuation once, then warns if unresolved. CI is the
merge gate: it runs mutation analysis only on pull requests with relevant changes,
using the PR base SHA and rename-aware path selection (`--no-renames`). It skips
unrelated pull requests and main-branch pushes. CI retains both JSON and execution
logs on failure.

## SQLite backup with Litestream (S3)

Production continuously replicates both SQLite databases to S3 using Litestream:

- `/rails/storage/production.sqlite3`
- `/rails/storage/production_queue.sqlite3`

Required production secret:

- `RAILS_MASTER_KEY`

Configure Litestream settings in Rails credentials:

```yaml
litestream:
  replica_bucket: your-s3-bucket-name
  replica_path_prefix: revenger-production
  replica_region: ap-northeast-1
  replica_key_id: <AWS_ACCESS_KEY_ID>
  replica_access_key: <AWS_SECRET_ACCESS_KEY>
```

### Restore runbook (latest snapshot)

1. Stop the app container so SQLite files are not being written.
2. Move or delete existing DB files:
   - `/rails/storage/production.sqlite3`
   - `/rails/storage/production_queue.sqlite3`
3. Restore primary DB:
   - `bin/rails litestream:restore -- --database=/rails/storage/production.sqlite3 --if-db-not-exists`
4. Restore queue DB:
   - `bin/rails litestream:restore -- --database=/rails/storage/production_queue.sqlite3 --if-db-not-exists`
5. Start the app container.

Notes:

- `--if-db-not-exists` skips restore when the DB file already exists.
- If restore fails because a DB file exists, remove/rename the file and retry.
