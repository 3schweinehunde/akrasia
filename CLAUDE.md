# Akrasia: project knowledge for Claude

This file, and later `docs/claude/<topic>.md` files linked from here, hold everything Claude
has learned about this project. The setup is the same as in the sibling project pan
(`../pan`). **Save new learnings here, not in local memory:** a short rule in this file,
details in a `docs/claude/<topic>.md` file. Commit these changes like any other change.
The repo is public on GitHub: never write IP addresses, private hostnames, secrets or names
of private people into these files.

## Working with the user

- **Number** findings, options and open items, and keep the numbering going across sessions.
  **Next new number: #62.** Update it here when you use new numbers. The user steers by
  number ("go with 3", "close #5").
- While the user is "still exploring", only investigate and answer. Edit the backlog or the
  code only on an explicit request. Go step by step; the user prefers manual over automatic.
- Stay within what was asked. Things the user does themselves (e.g. restoring the prod
  backup, #19) are theirs: answer, and don't start searching their file system for
  files they mentioned. Ask for a path instead (2026-11-15).
- Never hesitate to ask questions (user, 2026-11-15). Ask before starting a step
  rather than guessing at scope or preferences.
- Don't put your own ideas into backlog items or summaries as if they were decided. Mark them
  as suggestions or ask when the wording is vague.
- [backlog.md](backlog.md) holds only open work. Delete finished items (no "done" section)
  and put reference knowledge that is worth keeping into this file or docs/claude. Cleanups
  noticed during other work become a numbered backlog item, and the user decides later.
  Don't fold them into the current diff.
- Commit in steps, and only when the user says "commit": finish a step, report it,
  and wait. Never amend a commit after handing it over for pushing; add a new
  commit instead. The user pushes and deploys on their own: never claim commits are
  undeployed, say what a deploy of them needs (migrations, assets, console steps).
- Writing tests is encouraged (user, 2026-11-15): add tests for what you build. The
  old suite was generator scaffolding and was removed in #17 step 3a.
- Unrelated `mix format` changes are welcome: commit them separately as "mix format".
- Before proposing a root cause, look at the real data and code instead of theorizing.
  Before stating how the old app behaved, check all code paths and the git history
  (2026-11-15: I wrongly claimed height/public/target were admin-only).
- Work directly in the repo, not in scratch copies (user, 2026-11-15). If a step leaves
  the repo non-compiling, remove or replace the old code so it compiles, rather than
  checking in a copy.
- The user tries every step in the browser (dev server, prod backup data) before
  "commit". Say clearly when a step leaves pages that can't render yet, and what a
  running dev server needs (migrations, restart for new supervised processes).
- To show a scratchpad file, Read it: the Read call is clickable in the user's VSCode.

## Overview

Weight tracking and comparison app. Users record weighings (date, weight, optionally
abdominal girth and body fat). They see their BMI over time in a chart and can compare
it with other users who have made their profile public. Production runs at
https://akrasia.informatom.com. The UI texts are English gettext msgids; German
translations come later (#28).

## Stack

Upgraded in #17 (2026-11-15) from Phoenix 1.6; modelled on a fresh `phx.new` 1.8.16
project (generate one in the scratchpad as reference when needed) and on pan.

- `.tool-versions` (asdf): Erlang 29.1.1, Elixir 1.20.4-otp-29, Node 24.22.2, the same as
  the sibling projects.
- Phoenix 1.8, LiveView 1.2, Ecto SQL 3.14 / PostgreSQL, Bandit, Swoosh (gen_smtp),
  gettext 1.0 (`use Gettext, backend: AkrasiaWeb.Gettext`; `import` does nothing).
- Phoenix 1.8 structure: `*_html.ex` + function components, no `phoenix_view`.
- Tailwind 4 and esbuild via their hex packages; DaisyUI 5 and heroicons as git deps
  (like the generator, not npm as in pan); topbar vendored in `assets/vendor/`.
  npm only for ECharts.
- Themes: Catppuccin Latte (default) and Mocha (`prefersdark`) in `assets/css/app.css`,
  copied from pan. No `data-theme` = follow the OS; the Latte/System/Mocha toggle in the
  navbar (`Layouts.theme_toggle`, `assets/js/theme_toggle.js`, localStorage key
  `akrasia_theme`) sets it, applied before paint by a script in `root.html.heex`.
  It dispatches `akrasia:theme-changed`.
- Chart: ECharts 6 (Apache 2.0, #51). Not ApexCharts: it left MIT after 4.7.0, and its
  license from 5.0 on needs a paid OEM license for products used by others.
- Dev tools like pan: tidewave, claude + usage_rules + igniter, credo (`.credo.exs` from
  pan), sobelow (setup still open, #52).
- Surface and Alpine.js were removed on 2026-11-15 (user's decision); don't bring them back.

## Commands

```bash
mix setup                 # deps.get, ecto.setup, npm install, assets.setup/build
mix phx.server            # dev on :4000 (esbuild + tailwind watchers)
mix test                  # creates and migrates the test DB first
mix precommit             # compile --warnings-as-errors, deps.unlock --unused, format, test
mix credo --strict
mix gettext.extract --merge   # before every commit touching texts; then clear "fuzzy"
                              # flags in priv/gettext/en (they are wrong guesses, as in pan)
mix assets.deploy         # tailwind + esbuild --minify, phx.digest
```

Dev and test databases: `akrasia_dev` / `akrasia_test`, user `postgres` / `postgres` on localhost
(Postgres 18). `akrasia_dev` is a prod backup, restored by the user on 2026-11-15
(8 users, 1217 weighings 2010-06 to 2026-11). The user restores backups; Claude doesn't.
Query the real data before proposing a cause for a bug. `schema_migrations` on prod
contains `20210119104900` (convert_datetime_to_date_in_weighings), whose file was deleted
in 2021. It shows as "NO FILE" in `mix ecto.migrations` and is left as it is (#54).
`users_id_seq` was behind `max(users.id)` on prod (4 vs. 9, probably since the 2021 import),
so sign-ups failed with a `users_pkey` error; fixed by migration `20261115220000` (#61).
Prod is deployed and run the same way as pan, with Erlang and Elixir installed via asdf
(`.tool-versions`); use pan's setup as the model. Prod reads `DATABASE_URL` and `SECRET_KEY_BASE` from the environment
(`config/runtime.exs`, the same variables as before #17) and listens on port 9999 (IPv6).

## Layout

- `lib/akrasia/accounts.ex` is the single context. It holds the users, tokens **and**
  weighings logic. There is no separate Weighings context.
  - `list_users/1` and `list_weighings/1` take a criteria keyword list
    (`paginate:`, `sort:`, `search:`, `like_search:`, `additional_params:`), which the grid
    components build. `additional_params: %{user_id: id}` restricts weighings to one user.
    `like_search` switches search to a case-insensitive substring match on `cast(col as text)`.
  - `get_personal_weighings/1` returns one user's weighings ordered by date.
    `get_comparators/1` returns the other users where `public == true`.
  - `get_my_weighing!/2` scopes the lookup to the current user. Use it for user-facing routes.
- `lib/akrasia/accounts/user.ex` defines the user fields `name`, `admin`, `height`
  (in **cm**, decimal), `public`, `target`, `invitation_limit`, and the virtual `bot_check`.
  - Registration needs `bot_check == 42` (an anti-bot question).
  - The password rules are 8–80 characters with a lowercase letter, an uppercase letter and
    a digit or punctuation character.
  - `changeset/3` (the admin one) also validates the password and takes `opts`
    (for example `hash_password:`).
- `lib/akrasia/accounts/weighing.ex` has the fields `date`, `weight` (decimal kg),
  `abdominal_girth` (integer), `adipose` (decimal) and `user_id`. Only date, weight and
  user_id are required.

### Web

- Router scopes:
  - Public: `/` (landing page with a registration form) and `/page/:template` (`imprint`,
    `privacy`). `PageController.show` renders any template name given in the URL.
  - Logged in (`require_authenticated_user`):
    - `/weighings` is the `MyWeighingGrid` LiveView.
    - `/weighings/*` (except index) is `MyWeighingController`.
    - `/diagram` is the `WeighingDiagram` LiveView, the main feature.
    - `/users/settings`.
  - Admin (`require_authenticated_admin_user`, checks `user.admin`): `/admin/users` is the
    `UserGrid` LiveView, `/admin/weighings` is `WeighingGrid`, plus the CRUD
    controllers `UserController` and `WeighingController`.
  - `/dashboard` (LiveDashboard) exists only in dev and test.
- Grids: `AkrasiaWeb.Grid` (`live/components/grid.ex`) is a plain LiveComponent used by
  `UserGrid`, `WeighingGrid` and `MyWeighingGrid`.
  - It is configured with a `config` map (`heading`, `records_getter`,
    `records_getter_params`, `path_helper`) and a `columns` list. A column has `field`
    and `name`, plus optionally `searchable: true` and `presenter:` (a function of the
    record).
  - The grid LiveViews read `page`, `per_page`, `sort_by` and `sort_order` in
    `handle_params` and call `String.to_atom` on the URL params.
- `WeighingDiagram`:
  - Computes BMI on the server as `weight / (height_cm/100)^2`, rounded to 2 decimals.
  - Embeds the initial series as JSON in an inline `<script>` that defines the globals
    `userSeries`, `chartOptions` and `overviewChartOptions`.
  - The `Charts` hook in `assets/js/app.js` builds a main ApexCharts chart and a brush
    overview chart from those globals.
  - Server-to-client updates use `push_event`, with `"comparatorSeries"` (when a comparator
    is clicked) and `"userSeries"` (after a new weighing is saved inline).
  - Alpine `x-data` is kept across LiveView patches by `onBeforeElUpdated` → `Alpine.clone`.
- LiveViews get the current user from `session["user_token"]` through
  `Accounts.get_user_by_session_token`. There is no `on_mount` hook.
- `MyWeighingController` gets the current user itself from the session or the remember-me
  cookie (`get_current_user/1`) and does not use `conn.assigns.current_user`.
- Shared SVG icons come from `use AkrasiaWeb.Icons`, which defines the module attributes
  `@icon_asc`, `@icon_desc`, `@icon_show`, `@icon_edit` and `@icon_delete`.
- Templates are `.heex`.
- Fonts (Ubuntu) and the Line Awesome SVGs in `priv/static/svg/line_awesome_icons` are
  checked in.

## Layout

- `Akrasia.Accounts` (phx.gen.auth 1.8, `--live`): users, tokens, magic links, scopes
  (`Akrasia.Accounts.Scope`, `@current_scope`).
  - `User` fields beyond the generator: `name` (required, shown to others), `height`
    (cm, decimal, needed for the BMI), `public` (others can compare with them), `target`
    (kg), `admin` (never castable from user input; admins only, via the admin pages).
  - `registration_changeset` (email + name), `profile_changeset` (name, height, public,
    target). Password rules are Phoenix's: 12–72 characters, no character classes.
- `Akrasia.Weighings`: every function takes the scope, so users only see and change
  their own weighings. `bmi/2` is the only BMI calculation. Comparators
  (`list_comparators/1`, `get_comparator/2`) are only public users with a height, never
  oneself; other ids are ignored.
- `Akrasia.RateLimit` (Hammer, ETS, in the children): mail-sending requests (sign-up,
  magic link) per client IP, 5 per 10 minutes. `AkrasiaWeb.ClientIP` reads `X-Real-IP` or
  the last `X-Forwarded-For` entry (endpoint `connect_info: [:peer_data, :x_headers]`).
- `Akrasia.Application` reads its children from `config :akrasia, :children` per
  environment, like pan; prod adds `{PidFile.Worker, file: "akrasia.pid"}`.

### Web

- Public: `/` (home), `/imprint`, `/privacy` (legal texts, not in gettext), `/users/register`,
  `/users/log-in`.
- Logged in (`live_session :require_authenticated_user`): `/diagram`
  (`WeighingDiagramLive`, the main page; login redirects here), `/weighings`
  (`MyWeighingLive.Index`, sorting by a fixed column list, paging), `/weighings/new` and
  `/weighings/:id/edit` (`MyWeighingLive.Form`), `/users/profile` (`UserLive.Profile`, no
  sudo mode), `/users/settings` (email and password, needs sudo mode).
- Admin: `UserAuth` has `on_mount :require_admin` and the plug `require_admin_user` (#5);
  the Backpex admin pages are still to be built (#46).
- `/dev/dashboard` and `/dev/mailbox` exist only in dev.
- Sign-up bot filter (#31): hidden honeypot field `website` plus a minimum fill-in time;
  a suspected bot gets the same answer as a person but no account and no mail.
  `config :akrasia, :signup_min_seconds` (default 3) and
  `config :akrasia, Akrasia.RateLimit, mail_limit:` (default 5) are set to 0 and 1000 in
  `config/test.exs`; the bot filter tests set them explicitly.
- Diagram: the `BmiChart` hook (`assets/js/bmi_chart.js`) gets the initial data from data
  attributes (`data-series` as `[[iso_date, bmi], ...]`, `data-target-bmi`) and updates
  through `push_event` ("user-series", "comparator-series"). It opens with the full
  history (user's wish), a zoom slider below; colors come from the DaisyUI theme
  variables and follow theme changes.
- Mails come from `noreply@akrasia.informatom.com`; in prod through the local MTA
  (localhost:25), in dev into `/dev/mailbox`.
- Fonts (Ubuntu) are checked in under `priv/static/fonts`.

## Conventions

- Run `mix format` before committing.
- Git remotes: `code`, `gitea` and `github` (public). Work happens on `master` until
  the switch to `main` (#50).
- Known bugs and cleanups are tracked in [backlog.md](backlog.md), not here.
