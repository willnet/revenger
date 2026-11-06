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

Codex (`.codex/hooks.json`) and Claude Code (`.claude/settings.json`) call the same
Stop hook. Instructions are shared through `AGENTS.md`; no `CLAUDE.md` is needed
with Claude Code 2.1.277 or later and its default AGENTS.md loading enabled.
Review and trust the hooks in each client before using them. Codex exposes this
through `/hooks` or Settings > Hooks; Claude Code exposes `/hooks`.

The hook compares committed branch changes, staged/unstaged changes, and untracked
files against the merge base with `origin/main`. Fetch that ref before starting.
Relevant model/context, test support, configuration, and dependency changes require:

```sh
python3 scripts/check_test_boundaries.py --run
```

This host-side Python 3 command invokes the Dev Container automatically. Inside
the container, or in a prepared CI Ruby environment, use `--run --local`.
It scans the full models/contexts scope even for spec-only changes, validates the
JSON verdicts, and records a fingerprint of source, specs, configuration, and
dependencies. Further edits invalidate the record. Empty/unscored runs, ignored
mutants, survivors, uncovered code, and execution errors do not count as success.
Reports and records remain under `.mutineer/`.

The Stop hook asks the agent to continue once. If the check remains unresolved
on the continued turn, it emits a warning and permits stopping so the agent can
report the blocker. It is a local reminder, not a merge gate. Constants and SQL
comparisons still require separate review. Only the configured mutation operators
are checked; use focused additional operators when a boundary needs them.
CI runs the same checker in its prepared Ruby environment and retains the report
on failure. Unlike the local reminder, a failing check prevents the CI test job
from passing.

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
