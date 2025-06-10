# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Revenger is a Rails 7.0 application for reviewing notes frequently using spaced repetition. Users create posts/notes that are scheduled for review at configurable intervals. The application uses a context pattern for business logic, Devise for authentication, and includes both web and API interfaces.

## Development Commands

### Setup
```bash
# Copy environment files
cp .env.sample .env

# Copy database configuration
# make your config/database.yml

# Start development environment
docker-compose up
```

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/path/to/test_spec.rb

# Run system tests with headless Chrome
bundle exec rspec spec/system/
```

### Database
```bash
# Run migrations
bundle exec rails db:migrate

# Create development data
bundle exec rake dev:prime
```

### Rails Commands
```bash
# Start Rails server
bundle exec rails server

# Rails console
bundle exec rails console

# Generate new migrations, models, etc.
bundle exec rails generate
```

## Architecture

### Context Pattern
The application uses a context pattern for business logic in `app/contexts/`:
- `CreatePostContext` - Handles post creation with user defaults
- `UpdatePostContext` - Manages post updates and review scheduling  
- `ReadReviewContext` - Processes review completion
- `SendAssignmentMailContext` - Email notifications

### Models
- `User` - Devise-based authentication with post relationships and default settings
- `Post` - Core content model with review scheduling (`review_at`, `duration`, `modified_at`)

### Controllers
- Standard Rails REST controllers with API endpoints (`.json` responses)
- `ReviewsController` - Central review interface
- `PostsController` - CRUD operations for posts
- `DashboardApiController` - API for dashboard data

### Frontend Architecture
- Backbone.js application in `app/assets/javascripts/backbone/`
- HAML templates compiled to JavaScript in `app/assets/javascripts/templates/`
- Sass stylesheets with custom Bootstrap theme

### Key Features
- **Spaced Repetition**: Posts are scheduled for review based on configurable durations
- **Markdown Support**: Posts support Markdown with syntax highlighting via Pygments
- **Email Reminders**: Configurable email notifications for reviews
- **Multi-language**: Japanese (default) and English support

### Database Schema
- Posts belong to users with review scheduling (`review_at`, `duration`)
- Users have authentication fields and preferences (`default_duration`, `receive_reminder`)

### Testing
- RSpec with system tests using headless Chrome via Selenium
- Fabrication for test data generation
- Capybara for integration testing
- Tests organized by type: models, controllers, contexts, system

### Configuration
- Environment-specific configs in `config/environments/`
- Internationalization in `config/locales/`
- Time zone set to Tokyo, default locale Japanese
- Uses SQLite for development/test, configurable for production