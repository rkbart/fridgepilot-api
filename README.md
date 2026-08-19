# FridgePilot API

JSON API backend for **FridgePilot** — a smart pantry, recipe, and grocery-list manager with an optional AI assistant.

Built with **Ruby on Rails 8** (API-only), **PostgreSQL**, **Devise + JWT** authentication, and an optional **NVIDIA NIM** AI integration.

## Repositories

- **This repo (api):** <https://github.com/rkbart/fridgepilot-api>
- **Client:** <https://github.com/rkbart/fridgepilot-client>
- **Parent:** <https://github.com/rkbart/fridgepilot>

## Tech stack

- Ruby **3.4.10** (see `.ruby-version`) · Rails **8.1.3**
- [PostgreSQL](https://www.postgresql.org/) (via `pg`)
- [Puma](https://github.com/puma/puma) web server
- [Devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) authentication (JTI revocation strategy)
- [rack-cors](https://github.com/cyu/rack-cors) for cross-origin requests
- [dotenv-rails](https://github.com/bkeepers/dotenv) for environment variables
- [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase), [brakeman](https://brakemanscanner.org/), [bundler-audit](https://github.com/rubysec/bundler-audit) for quality/security tooling

## Getting started

Prerequisites: Ruby 3.4+, PostgreSQL running locally.

```bash
bundle install
cp .env.example .env    # adjust DATABASE_URL if needed
rails db:create db:migrate
rails server -p 3001
```

API is served at <http://localhost:3001>. Health check: <http://localhost:3001/up>.

## Environment variables

See `.env.example`. The most relevant ones:

| Variable | Example | Description |
|---|---|---|
| `DATABASE_URL` | `postgres://localhost:5432/backend_development` | PostgreSQL connection |
| `RAILS_ENV` | `development` | Rails environment |
| `NIM_API_KEY` | — | Optional default NVIDIA NIM API key |
| `NIM_API_URL` | `https://integrate.api.nvidia.com/v1` | Default AI endpoint |
| `FRONTEND_URL` | `http://localhost:5173` | Allowed CORS origin for the client |
| `DEVISE_JWT_SECRET_KEY` | — | Secret for signing JWTs (fallback: Rails credentials) |

> **Never commit `.env`.** Generate a JWT secret with `bundle exec rake secret` and keep it in `.env` (gitignored).

## Authentication

The API uses **JWT bearer tokens**. On sign-in the server returns the token in the `Authorization` response header:

```
Authorization: Bearer <token>
```

Send it on every authenticated request:

```
Authorization: Bearer <token>
```

Tokens expire after **1 hour**. Logging out revokes the token server-side (JTI strategy), so it cannot be reused. The frontend stores the token in `localStorage`.

## API reference

### Authentication (Devise)

| Method | Path | Description |
|---|---|---|
| `POST` | `/users` | Sign up (JSON body: `{ "user": { email, password, password_confirmation, name? } }`) |
| `POST` | `/users/sign_in` | Sign in → returns user + `Authorization: Bearer <token>` |
| `DELETE` | `/users/sign_out` | Sign out / revoke current token |

### Current user

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/me` | Returns the authenticated user |

### Pantry items

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/pantry_items` | List current user's pantry items |
| `GET` | `/api/v1/pantry_items/:id` | Show one item |
| `POST` | `/api/v1/pantry_items` | Create item (`name` required; `quantity`, `unit`, `category`, `expires_at` optional) |
| `PATCH` | `/api/v1/pantry_items/:id` | Update item |
| `DELETE` | `/api/v1/pantry_items/:id` | Delete item |

### Recipes

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/recipes` | List current user's recipes |
| `GET` | `/api/v1/recipes/:id` | Show one recipe |
| `POST` | `/api/v1/recipes` | Create recipe (`name` required; `ingredients`, `instructions`, etc. optional) |
| `PATCH` | `/api/v1/recipes/:id` | Update recipe |
| `DELETE` | `/api/v1/recipes/:id` | Delete recipe |

### Grocery lists & items

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/grocery_lists` | List current user's lists (with items) |
| `GET` | `/api/v1/grocery_lists/:id` | Show one list |
| `POST` | `/api/v1/grocery_lists` | Create list (`name` required) |
| `PATCH` | `/api/v1/grocery_lists/:id` | Update list |
| `DELETE` | `/api/v1/grocery_lists/:id` | Delete list (cascades to items) |
| `POST` | `/api/v1/grocery_lists/:id/items` | Add item (`name` required; `quantity`, `unit`, `status`, `source`, `recipe_id` optional) |
| `PATCH` | `/api/v1/grocery_lists/:id/items/:item_id` | Update item (e.g. toggle `status` between `pending` / `checked`) |
| `DELETE` | `/api/v1/grocery_lists/:id/items/:item_id` | Delete item |

Item `status` values: `pending`, `confirmed`, `checked`. Item `source` values: `manual`, `ai_suggested`.

### AI assistant

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/ai/suggest_recipes` | Suggest recipes based on current pantry contents |
| `POST` | `/api/v1/ai/generate_grocery_list` | Generate a grocery list from a recipe (`recipe_id` in body) |

AI endpoints read the user's pantry/recipes and call the configured AI provider. Requires an API key (see Settings below).

### Settings

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/settings` | Get current user's AI settings (`ai_api_endpoint`, `has_api_key`) |
| `PUT` | `/api/v1/settings` | Update settings (`ai_api_key`, `ai_api_endpoint`) |

## Data model

- **User** — auth, profile, optional per-user AI key/endpoint. `has_many`: `pantry_items`, `recipes`, `grocery_lists`.
- **PantryItem** — `name`, `quantity`, `unit`, `category`, `expires_at`. Belongs to a user.
- **Recipe** — `name`, `ingredients` (JSONB), `instructions`, `prep_time`, `cook_time`, `servings`, `cuisine`, `source`.
- **GroceryList** — `name`, `source` (`manual` / `ai_generated`). Belongs to a user.
- **GroceryItem** — `name`, `quantity`, `unit`, `category`, `status`, `source`, optional `recipe_id`. Belongs to a grocery list.

## Quality & security

```bash
bundle exec rubocop        # lint
bundle exec brakeman       # static security scan
bundle exec bundler-audit  # dependency vulnerabilities
```

CI runs these checks on push via `.github/workflows/ci.yml` (with Dependabot configured).

## Deployment

The Docker image runs the API with Puma (see `Procfile` / `Dockerfile`). Production deploys to **Google Cloud Run** via the parent repo's `cloudbuild.yaml`.

## License

All rights reserved. No license is granted for redistribution or commercial use without prior written permission.