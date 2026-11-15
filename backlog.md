# Backlog

Open work items and pending design decisions, kept here (rather than only in
Claude's per-machine memory) so they survive across computers. Only open work
belongs here: delete an item once it is done. Started 2026-11-15 from a first
read of the code; none of these items is verified by running the app or the tests yet.

The sections are in the suggested working order, and so are the items within each
section.

---

## 1. Get it running

Deployment (user, 2026-11-15): nobody is using akrasia right now, so it is
fine to deploy only after sections 1 and 2 are done and leave prod not
running until then.

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
    working. Open: does the "42" bot question stay at sign-up?
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
