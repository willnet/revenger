# Repository Guidelines

## Execution Environment (Dev Containers)
This repository is intended to be developed and operated inside a Dev Container.

- Default environment: run all development, test, and maintenance commands inside the Dev Container.
- If an AI Agent is running outside the Dev Container, it must execute project commands via the Dev Container CLI.
- Recommended pattern (from repository root):
  - `PORT=3000 devcontainer up --workspace-folder .`
  - `PORT=3000 devcontainer exec --workspace-folder . bin/setup`
  - `PORT=3000 devcontainer exec --workspace-folder . bin/rails db:prepare`
  - `PORT=3000 devcontainer exec --workspace-folder . bin/rspec`
- Do not run project-specific Ruby/Rails/Yarn commands directly on the host when the agent is outside the container.
- For parallel Git Worktree development, assign a unique `PORT` per worktree (for example `3000`, `3001`, `3002`).
- If `PORT` is omitted, it defaults to `3000`.

## Project Structure & Module Organization
This is a Ruby on Rails 7.2 app.
- Core app code lives in `app/` (`models/`, `controllers/`, `views/`, `jobs/`, and `contexts/`).
- Tests live in `spec/` (`models/`, `controllers/`, `system/`, `mailers/`, `contexts/`, `routing/`, plus `support/`).
- DB schema, migrations, and seed data are in `db/`.
- App/runtime config is in `config/`; custom rake tasks are in `lib/tasks/`.
- Frontend assets are managed in `app/assets/` and `vendor/assets/` (Sprockets + Yarn dependencies).

## Build, Test, and Development Commands
- `bin/setup`: install gems/node packages, prepare DB, clear logs/tmp, and optionally boot server.
- `bin/dev`: run the Rails server locally.
- `bin/rails db:prepare`: create/migrate DB for local development.
- `bundle exec rspec` or `bin/rspec`: run all tests.
- `bundle exec rspec spec/system/login_spec.rb`: run one spec file.
- CI baseline (from `.github/workflows/ci.yml`): `bundle install`, `yarn install`, `bundle exec rake db:create db:schema:load RAILS_ENV=test`, `bundle exec rspec`.
- When outside Dev Container, prefix these with `devcontainer exec --workspace-folder .`.

## Coding Style & Naming Conventions
- Follow existing Rails conventions: classes/modules in `CamelCase`, files/methods in `snake_case`.
- Keep 2-space indentation in Ruby/Haml/Sass files.
- Prefer thin controllers and reusable domain logic in `app/contexts/`.
- No enforced linter is currently configured in-repo; consistency with surrounding code is expected.

## Testing Guidelines
- Use RSpec (`spec/spec_helper.rb`) with Capybara + Selenium headless for system specs.
- Name specs with `_spec.rb` and mirror the target path (`app/models/user.rb` -> `spec/models/user_spec.rb`).
- Keep examples behavior-focused and deterministic; avoid external network dependencies.
- If running from host, execute tests via `devcontainer exec --workspace-folder .`.

## Commit & Pull Request Guidelines
- Follow concise, imperative commit subjects. Existing history includes both Japanese summaries and `build(deps-dev): ...` style for dependency bumps.
- Keep commits scoped to one change.
- PRs should include: purpose, key changes, test coverage/results, and linked issue(s) when applicable.
- Add screenshots/GIFs for UI-impacting changes (especially system-view updates).

## Security & Configuration Tips
- Prefer Rails credentials (`config/credentials.yml.enc`) for managed secrets.
