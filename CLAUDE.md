# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What This Is

A Rails 8 template serving two purposes: a starting point for personal projects,
and a scaffold for client SaaS work. Decisions favor removing headache over
being clever, and staying portable over committing to any host.

Stack: Rails 8.1, PostgreSQL, Solid Cache/Queue/Cable, Vite, Tailwind v4,
Turbo + Stimulus, React + TypeScript for page-apps, Devise for auth.

## Commands

```bash
bin/setup                 # install deps, start Postgres, prepare the database
bin/dev                   # web + vite + jobs
bin/rails test            # unit tests
bin/rails test:system     # system tests (headless Chrome)
npm run typecheck         # tsc --noEmit
bin/rubocop               # lint
bin/ci                    # everything CI runs
docker compose up -d      # Postgres only
```

## Style

### Universal

- **Small, composable functions.** Extract when a function spans more than one
  level of abstraction, not at an arbitrary line count. Orchestration and
  string-trimming do not belong in the same body.
- **Name things after meaning, not mechanism.** `eligible_for_renewal?`, not
  `check_date_and_status`. Small functions only pay off when the name lets a
  reader skip the body.
- **Bias toward immutability.** Mutate locally, share immutably — building an
  array inside a function is fine; handing callers a mutable reference to
  internal state is not.
- **Prefer transformations to loops.** `map`, `filter`, `reduce`, `flat_map`
  over manual iteration and accumulator variables. Loops are fine when a
  transformation would be contorted; this is a bias, not a ban.
- **Early returns over `else`.** Guard clauses at the top, happy path
  unindented at the bottom.
- **Avoid nested conditionals.** More than one level of nesting is a signal to
  extract a function or reach for polymorphism. Guards handle preconditions;
  branching logic wants a lookup table or separate objects.
- **No boolean parameters.** `render(partial, true)` is unreadable, and a flag
  is usually two functions wearing one signature.
- **Prefer duplication to the wrong abstraction.** Two similar things that may
  diverge should stay two things.
- **Comments explain why, never what.** Do not narrate code. Do document
  non-obvious constraints — see `bin/jobs` for an example worth keeping.

### Ruby / Rails

- **Fat models are not the goal; small objects are.** "Skinny controller, fat
  model" produces 800-line `User` classes. Extract POROs, query objects, form
  objects.
- **Service-style objects are good; the `Service` suffix is not.** Name them
  after the domain: `CreateSubscription`, `SubscriptionCharge`. A suffix that
  only says "this is a service" invites a dumping ground.
  - One operation, one public entry point, dependencies injected at
    construction.
  - If the private methods only make sense in a fixed order and pass state
    through ivars, it is a procedural script in a class costume. Make it a
    sequence of transformations instead.
  - Do not wrap a single ActiveRecord call in one. Queries want scopes or query
    objects.
- Rubocop follows `rubocop-rails-omakase`. Run `bin/rubocop -a` before
  finishing.

### TypeScript

TypeScript is here for explicit contracts, not type-level programming. Good TS
is JavaScript with contracts, the way good C++ is C with extra features.

- **Types describe data, not computation.** If you cannot read a type aloud as a
  sentence about the domain, it is the wrong type.
- **No type soup.** Conditional types, mapped types, deep generics, and `as
  const` pyramids are almost always the wrong tool here. An idiot admires
  complexity.
- **Prefer unions of concrete shapes to generic parameters.** `type State =
  Loaded | Loading | Failed` beats `Result<T, E>` for app code. Discriminated
  unions earn their place; they model states that actually exist.
- **Do not type what infers.** Annotate boundaries — props, exported function
  signatures, state shapes. Not `const x: string = "foo"`.
- **`unknown` plus a narrow at boundaries, never `any`.**
- **`readonly` on shared types** rather than `Readonly<T>` at every call site.

## Frontend Architecture

Two tiers, deliberately separate. Full detail in `app/frontend/README.md` —
read it before touching frontend code.

- **Tier 1, Stimulus controllers**: behavior on server-rendered markup. Plain
  JS. Auto-registered from `app/frontend/controllers/*_controller.js`.
- **Tier 2, React page-apps**: a page hands React one empty node and React owns
  everything inside. TypeScript. One Vite entrypoint per app.

The three rules that keep them from colliding:

1. A page is either a Turbo page or a React page, never both. `content_for
   :react_app` emits the entrypoint tag *and* `turbo-visit-control: reload`, so
   opting into React opts out of Drive automatically.
2. Stimulus controllers never reach inside a React container.
3. Server-pushed updates follow ownership — Turbo Streams to server-rendered
   DOM, JSON over a channel to React apps. Never push HTML into React's subtree.

### Gotcha

Vite Ruby tag helpers need the exact extension. `vite_javascript_tag
"dashboard"` and `vite_typescript_tag "dashboard"` both fail on a `.tsx` file;
the working call is `vite_javascript_tag "dashboard.tsx"`.

## Authentication

Devise with `confirmable` and `omniauthable` (Google only). Chosen over the
Rails 8 generator because auth is a commodity worth renting — the generator
still ships no registration flow, and generated auth code makes you the
security maintainer.

- **One provider per account.** `provider`/`uid` on `users`, no `identities`
  table. Extract one if a project ever needs Google *and* Apple on one login.
- **`User.from_google` refuses unverified emails.** Linking an OAuth identity to
  an existing account by email is an account-takeover vector unless the provider
  verified the address.
- **OAuth signups skip confirmation** (Google already verified); password
  signups must confirm.
- **Google credentials are optional.** Absent `GOOGLE_CLIENT_ID`/`SECRET` (or
  the matching `credentials.dig(:google, ...)`), the provider is not registered
  and the button hides. A fresh checkout boots without configuration.
- Devise's `shared/_links` partial had its OmniAuth block removed — it calls
  `omniauth_authorize_path` for providers that may have no route.

## Infrastructure Decisions

- **Solid Cache / Queue / Cable, all in the primary database.** No separate
  `cache`/`queue`/`cable` databases, no Redis. Solid Queue runs inside Puma via
  `SOLID_QUEUE_IN_PUMA`, so a deploy needs one service rather than two. Sidekiq
  is a per-project upgrade when job volume justifies it, not a default.
- **Postgres runs in Docker Compose; the app runs natively.** Fast dev loop on
  macOS.
- **Deployment is undecided.** No Kamal, no `render.yaml`. The app reads
  `POSTGRES_*` env vars and ships as a Docker image, which keeps every option
  open. Do not add deploy config without asking.

## Testing

- System tests use headless Chrome and cover the frontend tier boundary
  (`test/system/islands_test.rb`). They are the regression guard for the asset
  pipeline — if Vite, Tailwind, or the Turbo/React split breaks, they fail.
- `bin/ci` and the GitHub workflow run the same checks: rubocop, typecheck,
  bundler-audit, brakeman, tests, system tests, seeds.
