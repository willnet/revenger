# Revenger

Revenger is for reviewing your notes frequently.

## Set up for development

- use devcontainers

## Develop with Git Worktree

You can run multiple worktrees in parallel by assigning a different `PORT` per worktree.

```sh
# Example: create a new worktree
git worktree add ../revenger-feature-a feature-a

# In each worktree directory
PORT=3000 devcontainer up --workspace-folder .
PORT=3000 devcontainer exec --workspace-folder . bin/setup
PORT=3000 devcontainer exec --workspace-folder . bin/dev
```

For another worktree, use a different port (for example `PORT=3001`).
If `PORT` is not set, it defaults to `3000`.
