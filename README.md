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
