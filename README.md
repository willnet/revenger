# Revenger

Revenger is for reviewing your notes frequently.

## Set up for development

- use devcontainers

## Develop with Git Worktree

Use `bin/dc` to run Dev Container commands. It automatically derives `COMPOSE_PROJECT_NAME`
and `PORT` from the current worktree path, so containers/volumes/ports do not conflict
across worktrees.

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

