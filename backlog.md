# Backlog

Open work items and pending design decisions, kept here (rather than only in
Claude's per-machine memory) so they survive across computers. Only open work
belongs here: delete an item once it is done. Started 2026-11-15 from a first
read of the code; none of these items is verified by running the app or the tests yet.

The sections are in the suggested working order, and so are the items within each
section.

---

## Open questions (2026-11-15)

These are decisions to make before or during the upgrade (#17), because the
templates are rewritten there anyway (#21) and migrations come with the auth
generator (#25). Wherever an option says "suggestion", it is Claude's
suggestion, not a decision. Once a question is answered, move the decision
into the item it belongs to and delete the question here.

### Bot filter at sign-up (#29)

With magic-link sign-up, a bot account can't do anything until someone
clicks the link in the email. The remaining risk is that bots make akrasia
send emails to strangers' addresses, which hurts the mail server's
reputation. Pan uses the same "42" question as akrasia.

- **#30** Keep "42". It has worked and needs no dependency. A bot written
  for this site gets past it once.
- **#31** Hidden honeypot field plus a minimum fill-in time of about
  3 seconds. Users see nothing. It catches generic bots, but not ones
  written for the site.
- **#32** A third-party captcha (Turnstile, hCaptcha). Not suggested:
  external scripts and a privacy-page entry, overkill here.
- **#33** Rate limiting per IP for sign-up and magic-link requests (`hammer`).
  Works alongside any of the above, and is the only option that actually
  limits the mail abuse.
- Suggestion: #31 + #33 (and later the same for pan). To keep akrasia and
  pan identical: #30 + #33.

### Admin and grids

- **#46 Backpex for `/admin`** (suggestion). A LiveView admin panel built on
  Tailwind and DaisyUI, so it fits #34. Resources are described as modules
  listing their fields; it provides list, search, filters, sorting,
  pagination, show/edit/new/delete and permissions per action. It would
  replace `UserGrid`, `WeighingGrid`, `UserController`, `WeighingController`
  and their templates, which settles #37 and most of #36. Downsides: a
  dependency with its own release pace, and its own layout component that
  needs fitting into ours. Check whether the current version still needs
  Alpine.js (affects #44).
- **#47 Flop + Flop Phoenix** for the user-facing "My Weighings" list: a
  table with sorting, filtering and pagination, where only allowed fields
  are possible. Suggestion: only if users should get search and filters too;
  otherwise a plain 1.8 table with sorting by a fixed list of columns.
- **#48 Torch** generates the admin pages as code (no runtime dependency).
  More code to own, less polished.
- **#49 Kaffy / LiveAdmin.** Not suggested: Kaffy is Bootstrap-based and not
  very active, and LiveAdmin is less mature.
- **#36 If no admin library is used, rewrite the grid** as a 1.8 component in
  which each column names its field, and only those fields can be sorted or
  searched (fixes #4). Choose one: a) own small component (suggestion),
  b) `flop`.
- **#37 If no admin library is used, admin CRUD:** a) convert
  `UserController` and `WeighingController` to LiveViews (`phx.gen.live`
  style), b) keep them as controllers with 1.8 HTML modules.

### Scope of the upgrade

- **#34 Move DaisyUI (#18) into #17.** Phoenix 1.8's generator already ships
  DaisyUI with a light and a dark theme. Since every template gets rewritten
  for #21, use Latte and Mocha right away instead of a second pass later.
- **#35 Multilingual UI (#28):** wrap the texts in `gettext` while
  rewriting the templates; the German translations come later. Choose one:
  a) during #21 (each template is touched only once), b) later as its own
  step (a smaller diff now).
- **#38 A weighings context:** move the weighings out of `Accounts` into
  `Akrasia.Weighings`, using the 1.8 scopes (`current_scope`), so the context
  itself enforces "my weighings".
- **#43 Fix the diagram bugs (#1, #2, #3) during the rewrite:** one BMI
  function, an empty state for users with no weighings or no height, and
  resetting the form after saving.
- **#44 Remove Alpine.js.** Akrasia uses it for a single `x-show` in the
  comparator list, and the server already knows `comparator_id`. Removing
  it also removes the `Alpine.clone` workaround. Pan keeps Alpine; say so
  if it should stay as a shared tool. Depends on #46 (Backpex and Alpine).
- **#45 Static pages (#11):** own routes for imprint and privacy instead of
  `/page/:template`, which removes the 500 on unknown names.

### Data and migrations

- **#39 Deleting users (#6):** a) the user's weighings are deleted with the
  user (`on_delete: :delete_all`), b) deleting a user who has weighings is
  refused with a message.
- **#40 Migrations (#7):** in the same migration step, re-add the index on
  `weighings.user_id` and rename the migration module. The rename is safe,
  because Ecto tracks migrations by version number, not by module name.
- **#41 `invitation_limit` (#15):** a) remove the column, b) keep it for a
  future invitation feature.
- **#42 Seeds (#10):** a) a small `seeds.exs` with an admin user, a public
  test user and a few weighings, so a fresh setup works without the prod
  backup; b) remove `run priv/repo/seeds.exs` from the setup alias.

---

## 1. Get it running

Deployment (user, 2026-11-15): nobody is using akrasia right now, so it is
fine to deploy only after sections 1 and 2 are done and leave prod not
running until then.

- **#50 Switch from `master` to `main`** (user, 2026-11-15), like pan.
  State on 2026-11-15: no `main` exists anywhere yet. The remotes are `code`,
  `gitea` and `github`, all with `master` at the same commit as local.
  Steps: rename the branch, push `main` to all three remotes, set it as the
  default branch in each remote's settings (the user), delete `master` on
  the remotes, and point the prod deployment at `main`.
- **#17 Outdated stack:** Phoenix 1.6, LiveView 0.17,
  esbuild 0.14, `config :logger, level: :warn` in test.exs (deprecated).
  `.tool-versions` now pins Erlang 29.1.1 / Elixir 1.20.4 like the sibling
  projects (2026-11-15), but the 2022 `mix.lock` does not build there.
  It already fails on Erlang 26 (`ssl_verify_fun`), so the deps must be
  upgraded before anything compiles.
  Decisions (user, 2026-11-15):
  - #20 Go straight to pan's versions: Phoenix 1.8, LiveView 1.2,
    Ecto SQL 3.14, phoenix_html 4.
  - #21 Move to the Phoenix 1.8 structure (`*_html.ex` + function
    components); no `phoenix_view`.
  - #22 Bamboo → Swoosh (with gen_smtp, like pan).
  - #23 Cowboy → Bandit.
  - #24 (Claude's choice, user had no preference): Tailwind 3 → 4 now,
    with the `tailwind` hex package like pan, instead of the `npx` watcher.
  - #25 Regenerate auth with the Phoenix 1.8 `phx.gen.auth`, then carry
    over `bot_check`, `admin`, `name`, `height`, `public`, `target`. This
    probably also settles #5 (on_mount) and #13.
  - #29 Adopt the Phoenix 1.8 login flow: sign up with email only, magic
    link login, optional password. Existing prod passwords (bcrypt) keep
    working. The bot filter is open, see "Open questions" (#30–#33).
  - Steps, each committed separately when the user says "commit":
    (1) remove Surface (#12) and the leftovers (#14) (done 2026-11-15),
    (2) upgrade the deps, (3) fix until it compiles, (4) fix until the
    tests pass.
- **#10 `mix ecto.setup` runs `priv/repo/seeds.exs`, which does not exist.**
- **#19 Restore the prod backup into `akrasia_dev`.** A prod backup exists
  and can be brought in (user, 2026-11-15). Real data is then available to
  check the bugs against, as in pan. The user restores it; Claude says
  when it is needed. That is once #17 compiles and the server should
  start; the tests use the test DB and don't need it.
- **#16 Test suite state unknown.** It is mostly generated auth and scaffold
  tests and has not been run yet. There are no tests for the diagram, the
  grids or `MyWeighingController`.
- **#1 Diagram page crashes for new users.** `WeighingDiagram.mount`
  calls `List.last(weighings).weight` and divides by `user.height`, so a
  user with no weighings or no height set gets a crash on `/diagram`.

## 2. Security problems

- **#4 `String.to_atom` on user input.** The grid LiveViews turn the URL
  params `sort_by` and `sort_order` into atoms. `AkrasiaWeb.Grid` does the
  same in its search and sort events.
  `MyWeighingGrid` is open to every logged-in user, so atoms can be
  exhausted, and unknown fields crash the query.
- **#5 Admin LiveViews have no admin check of their own (to verify).**
  There is no `live_session` or `on_mount`. Only the HTTP pipeline checks
  `admin`. Verify whether live navigation from a user LiveView to
  `/admin/users` or `/admin/weighings` skips that check (LiveView 0.17).
- **#9 Secrets in config.** `config/config.exs` has a hard-coded
  `secret_key_base` (dev value) in a public repo.
  `config/prod.secret.exs` still uses the deprecated `use Mix.Config`.
  This fits into #17 (newer Phoenix reads secrets in `config/runtime.exs`).
  Prod runs the same way as pan (#26), so take pan's prod and runtime
  config as the model.

## 3. Bugs

- **#6 Deleting a user who has weighings fails.** `weighings.user_id`
  references users with `on_delete: :nothing`, and `Accounts.delete_user/1`
  has no `foreign_key_constraint`, so the admin delete raises
  `Ecto.ConstraintError`.
- **#2 Inline weighing form is not reset after saving.** In
  `WeighingDiagram.handle_event("create_weighing")` the result of
  `assign(socket, weighing_changeset: ...)` is thrown away.
  "Last Weighing" is also not updated.
- **#11 `/page/:template` renders any template name from the URL.**
  An unknown name gives a 500 (undefined template) instead of a 404.

## 4. Look and feel, languages

- **#18 DaisyUI with Catppuccin Latte (light) and Mocha (dark) themes.**
  Bring DaisyUI in on top of Tailwind for a consistent look and feel, with
  a light and a dark theme. Decided by the user: Catppuccin Latte and Mocha.
  Note: DaisyUI 5 (the version pan uses) needs Tailwind 4, and akrasia is
  on Tailwind 3.0, so this goes with or after #17. Reference, not decided
  for akrasia: pan's setup in `../pan/docs/claude/catppuccin-themes.md` and
  `../pan/DESIGN.md`. Pan uses Latte by default and Mocha as `prefersdark`,
  follows the OS when no theme is set, and has a toggle in the UI. The ApexCharts
  diagram colors (`weighing_diagram.html.heex`) would need to follow the
  theme too. With #24, Tailwind 4 is already in place by then.
- **#28 Dual-language UI (German and English) like pan.** The UI mixes
  German ("Gewicht", "Speichern", "Wägung gespeichert") and English today.
  Reference: pan's `../pan/docs/claude/multilingual.md`.

## 5. Cleanups

- **#7 Migration `20210412180000_remove_index.exs` reuses the module name**
  `Akrasia.Repo.Migrations.CreateWeighings`. It drops the
  `weighings.user_id` index, which every per-user weighing query filters on.
- **#3 BMI calculation is duplicated three times** in `weighing_diagram.ex`.
- **#13 `MyWeighingController` looks up the current user itself** from the
  session or remember-me cookie instead of using `conn.assigns.current_user`.
- **#8 `config :akrasia, :children` (dev.exs, prod.exs) is never read.**
  `Akrasia.Application` hard-codes the children. The prod entry names
  `pan.pid`, while the application writes `akrasia.pid`. Prod runs like
  pan (#26), so keep the pid file and use pan's setup as the model.
- **#15 `invitation_limit` is unused.** The `invitation` relation on User is
  commented out.
