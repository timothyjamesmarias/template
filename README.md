# Template

A Rails 8 starting point: PostgreSQL, Solid Cache/Queue/Cable, Vite, Tailwind v4,
Turbo + Stimulus, React + TypeScript for page-apps, and Devise for auth.

## Requirements

| | Version | Notes |
|---|---|---|
| Ruby | 3.4.9 | see `.ruby-version` |
| Node | 22.20.0 | see `.node-version` |
| Docker | any recent | runs PostgreSQL |
| Chrome | any recent | system tests only |

Ruby and Node versions are pinned in `.tool-versions` for asdf/mise.

## Getting started

```bash
bin/setup
```

That installs gems and npm packages, starts PostgreSQL in Docker, prepares the
database, and boots the app at http://localhost:3000.

To set up without starting the server:

```bash
bin/setup --skip-server
```

## Running the app

```bash
bin/dev
```

Runs three processes from `Procfile.dev`:

- `web` — Rails on port 3000
- `vite` — asset dev server with hot reload
- `jobs` — Solid Queue worker

PostgreSQL runs separately in Docker:

```bash
docker compose up -d      # start
docker compose down       # stop
```

## Creating an admin

There is no seeded user. Make one from the console:

```ruby
bin/rails console
user = User.create!(email: "you@example.com", password: "a-good-password", admin: true)
user.confirm
```

Then sign in and visit `/admin`.

## Mail in development

Mail is not delivered — `letter_opener` opens it in a browser tab instead. That
is how you get confirmation and password-reset links locally.

## Tests and checks

```bash
bin/rails test           # unit and integration tests
bin/rails test:system    # system tests (headless Chrome)
bin/rubocop              # Ruby lint
npm run typecheck        # TypeScript
bin/ci                   # everything above, in one pass
```

## Configuration

Development reads `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, and
`POSTGRES_PASSWORD`, all defaulted to match `docker-compose.yml`. Nothing needs
setting for a local checkout.

Optional:

| Variable | Effect |
|---|---|
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | Enables "Continue with Google". The button stays hidden without both. |
| `POSTMARK_API_TOKEN` | Enables mail delivery in production. |
| `MAILER_SENDER` | From address. Must be a verified Postmark sender. |
| `APP_HOST` | Canonical host for links in production. |

## Deploying

`render.yaml` describes a web service and a PostgreSQL instance. Point Render at
the repo and it reads the blueprint; you supply the values marked `sync: false`.

Solid Queue runs inside Puma via `SOLID_QUEUE_IN_PUMA`, so this is one paid
service rather than two. The blueprint has a commented worker for when jobs
outgrow that.

## Further reading

- `CLAUDE.md` — style guide and the reasoning behind the stack choices
- `app/frontend/README.md` — the Stimulus/React split and the rules that keep
  the two from colliding
