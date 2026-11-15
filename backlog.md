# Backlog

Open work items and pending design decisions, kept here (rather than only in
Claude's per-machine memory) so they survive across computers. Only open work
belongs here: delete an item once it is done. Started 2026-11-15 from a first
read of the code; none of these items is verified by running the app or the tests yet.

The sections are in the suggested working order, and so are the items within each
section. All decisions below were made by the user on 2026-11-15 unless marked
otherwise.

---

## 1. Get it running

Deployment: it is fine to deploy only after sections 1 and 2 are done and
leave prod not running until then. The prod data shows 13 weighings since
June 2026 (latest 2026-11-09), so akrasia is in light use; the user has
informed the users, and the plan stays (#53, 2026-11-15).

- **#17 Upgrade the stack.** Today: Phoenix 1.6, LiveView 0.17, esbuild 0.14,
  Tailwind 3, Bamboo, Cowboy; `config :logger, level: :warn` in test.exs is
  deprecated. `.tool-versions` pins Erlang 29.1.1 / Elixir 1.20.4 like the
  sibling projects, but the 2022 `mix.lock` does not build there (it
  already fails on Erlang 26, `ssl_verify_fun`), so nothing compiles before
  the deps are upgraded.

  Steps, each committed separately when the user says "commit":
  (1) remove Surface and the generator leftovers (done 2026-11-15),
  (2) upgrade the deps (done 2026-11-15: `mix.exs` modelled on a fresh
  `phx.new` 1.8.16 project, new `mix.lock`, npm only for ApexCharts,
  topbar and heroicons vendored in `assets/vendor/` like the generator),
  (3) fix until it compiles, (4) fix until the tests pass. The rewrite
  parts below happen within (3) and (4). Step (3) is split into commits
  (user, 2026-11-15): (3a) config and app shell (layouts, DaisyUI
  Latte/Mocha, gettext), (3b) auth, (3c) weighings context, "My Weighings"
  and the diagram, (3d) Backpex admin, (3e) migrations and dev tools.

  Stack:
  - #20 Go straight to pan's versions: Phoenix 1.8, LiveView 1.2,
    Ecto SQL 3.14, phoenix_html 4.
  - #21 Phoenix 1.8 structure (`*_html.ex` + function components); no
    `phoenix_view`.
  - #22 Bamboo → Swoosh (with gen_smtp, like pan).
  - #23 Cowboy → Bandit.
  - #24 (Claude's choice, user had no preference): Tailwind 3 → 4 with the
    `tailwind` hex package like pan, instead of the `npx` watcher.
  - #34 DaisyUI with Catppuccin Latte (light) and Mocha (dark), the former
    #18, is done here. Each template is written once. Reference, not decided
    for akrasia: pan's `../pan/docs/claude/catppuccin-themes.md` and
    `../pan/DESIGN.md` (Latte default, Mocha as `prefersdark`, follow the
    OS when no theme is set, toggle in the UI). The ApexCharts colors on
    the diagram must follow the theme too.
  - #35 Wrap all UI texts in `gettext` while rewriting the templates;
    the German translations follow later (#28).
  - #44 Remove Alpine.js (one `x-show` in the comparator list, replace it
    server-side, plus the `Alpine.clone` workaround in app.js). Backpex
    0.24 does not need Alpine (checked 2026-11-15); already gone from
    package.json.
  - #51 ApexCharts 3.24 → 8 (user). Check the changelog for breaking
    changes in line and brush charts and theming.
  - #52 Dev tools like pan: tidewave, claude + usage_rules + igniter, credo,
    sobelow (user). Set them up (claude installer, `.sobelow-conf`, credo
    config) in step (3).
  - DaisyUI comes as the generator's git dependency (not npm as in pan).

  Auth:
  - #25 Regenerate auth with the Phoenix 1.8 `phx.gen.auth`, then carry over
    `admin`, `name`, `height`, `public`, `target`. This should also settle
    #5 (admin check via `on_mount`) and #13.
  - #29 Phoenix 1.8 login flow: sign up with email only, magic link login,
    optional password. Existing prod passwords (bcrypt) keep working.
  - #31 Replace the "42" question with a hidden honeypot field plus a
    minimum fill-in time (about 3 seconds). Later the same for pan.
  - #33 Rate limiting per IP for sign-up and magic-link requests (`hammer`),
    against making akrasia send mails to strangers' addresses.

  Admin and lists:
  - #46 Backpex for `/admin` (users, weighings). It replaces `UserGrid`,
    `WeighingGrid`, `AkrasiaWeb.Grid`, `UserController`,
    `WeighingController` and their templates. Fit its layout into ours.
  - #47 "My Weighings" becomes a plain 1.8 table with sorting by a fixed
    list of columns and simple paging; no search, no Flop.
  - #38 Weighings move out of `Accounts` into their own context
    `Akrasia.Weighings`, using the 1.8 scopes (`current_scope`), so the
    context enforces "my weighings".
  - #45 Imprint and privacy get their own routes; `/page/:template` goes away.

  Data and migrations:
  - #39 Deleting a user deletes their weighings
    (`on_delete: :delete_all` on `weighings.user_id`).
  - #40 Re-add the index on `weighings.user_id` and give migration
    `20210412180000_remove_index.exs` its own module name.
  - #41 Drop the unused column `invitation_limit` (and the commented-out
    `invitation` relation). Every prod user has a value (9, 10, 96, 100);
    losing them is accepted (#56).
  - #42 Remove `run priv/repo/seeds.exs` from the `ecto.setup` alias; dev
    uses the prod backup (#19).

  Diagram:
  - #43 Fix #1, #2 and #3 during the rewrite: one BMI function, an empty
    state for users with no weighings or no height, and after saving a
    reset form and an updated "Last Weighing". One prod user has no
    weighings, which is useful to test the empty state (#55).

  Items covered by these decisions. Delete each one when it is done:
  - **#1 Diagram page crashes for new users** (→ #43). `WeighingDiagram.mount`
    calls `List.last(weighings).weight` and divides by `user.height`.
  - **#2 Inline weighing form is not reset after saving** (→ #43). The
    result of `assign(socket, weighing_changeset: ...)` is thrown away in
    `handle_event("create_weighing")`; "Last Weighing" is not updated.
  - **#3 BMI calculation is duplicated three times** (→ #43).
  - **#6 Deleting a user who has weighings fails** with
    `Ecto.ConstraintError` (→ #39).
  - **#7 Migration module name `CreateWeighings` used twice, and the
    `weighings.user_id` index is dropped** (→ #40).
  - **#10 `mix ecto.setup` runs the non-existent `priv/repo/seeds.exs`** (→ #42).
  - **#11 `/page/:template` renders any template name from the URL**,
    unknown names give a 500 (→ #45).
  - **#13 `MyWeighingController` looks up the current user itself** from
    the session or cookie (→ #25, #38).
  - **#15 `invitation_limit` is unused** (→ #41).

- **#8 `config :akrasia, :children` (dev.exs, prod.exs) is never read.**
  `Akrasia.Application` hard-codes the children. The prod entry names
  `pan.pid`, while the application writes `akrasia.pid`. Prod runs like
  pan (#26), so keep the pid file and use pan's setup as the model.
  Fits into step (3) of #17.
- **#16 Tests.** The current suite is mostly generated auth and scaffold
  tests and has never been run. The regenerated auth (#25) brings its own
  tests. Add tests for the diagram, "My Weighings" and the
  `Akrasia.Weighings` context.
- **#50 Switch from `master` to `main`**, like pan. Done last, after
  everything else in this section (user, 2026-11-15).
  State on 2026-11-15: no `main` exists anywhere yet. The remotes are `code`,
  `gitea` and `github`, all with `master` at the same commit as local.
  Steps: rename the branch, push `main` to all three remotes, set it as the
  default branch in each remote's settings (the user), delete `master` on
  the remotes, and point the prod deployment at `main`.

## 2. Security problems

- **#4 `String.to_atom` on user input.** The grid LiveViews and
  `AkrasiaWeb.Grid` turn URL params and event values into atoms; atoms can
  be exhausted, and unknown fields crash the query. Goes away with #46 and
  #47 (fixed column lists). Verify that no `String.to_atom` on user input is
  left afterwards.
- **#5 Admin LiveViews have no admin check of their own.** There is no
  `live_session` or `on_mount`; only the HTTP pipeline checks `admin`.
  After #25 and #46, verify that every admin LiveView checks `admin` on
  mount, including after live navigation.
- **#9 Secrets in config.** `config/config.exs` has a hard-coded
  `secret_key_base` (dev value) in a public repo.
  `config/prod.secret.exs` still uses the deprecated `use Mix.Config`.
  Move the secrets to `config/runtime.exs` during #17, with pan's prod and
  runtime config as the model (#26).

## 3. Languages

- **#28 German translations.** The texts are wrapped in `gettext` during #17
  (#35). Then add the German translations and language switching like pan.
  Reference: `../pan/docs/claude/multilingual.md`.
