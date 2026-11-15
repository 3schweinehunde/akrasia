# Backlog

Open work items and pending design decisions, kept here (rather than only in
Claude's per-machine memory) so they survive across computers. Only open work
belongs here: delete an item once it is done; reference knowledge goes into
CLAUDE.md.

The sections are in the suggested working order, and so are the items within each
section. All decisions below were made by the user on 2026-11-15 unless marked
otherwise.

---

## 1. Get it running

Deployment: it is fine to deploy only after sections 1 and 2 are done and
leave prod not running until then. akrasia is in light use (13 weighings
since June 2026); the user has informed the users, and the plan stays (#53).

- **#17 Finish the stack upgrade.** Steps 1, 2, 3a (app shell), 3b (auth)
  and 3c (weighings, diagram) are done; each step is committed separately
  when the user says "commit". Still open:
  - **3d: #46 Backpex for `/admin`** (users, weighings): list, search,
    sorting, CRUD. Fit its layout into ours. Put every admin route behind
    the admin checks (#5). Admin pages stay English (like pan).
  - **3e: migrations and dev tools:**
    - #39 Deleting a user deletes their weighings (`on_delete:
      :delete_all` on `weighings.user_id`); fixes #6, admin deletes fail
      with `Ecto.ConstraintError` today.
    - #40 Re-add the index on `weighings.user_id` (#7).
    - #41 Drop the unused column `invitation_limit` (#15); every prod user
      has a value (9, 10, 96, 100), losing them is accepted (#56).
    - #52 Set up the dev tools like pan: tidewave, claude + usage_rules +
      igniter (installer), sobelow (`.sobelow-conf`). `.credo.exs` exists.
  - At the end: update CLAUDE.md where it still describes the old code, and
    check that `mix precommit` passes.
- **#16 Tests for the Backpex admin** (3d), including that non-admins can't
  reach it (#5). Writing tests is encouraged (user). The chart hook
  (`assets/js/bmi_chart.js`) has no automated test.
- **#50 Switch from `master` to `main`**, like pan. Done last, after
  everything else in this section.
  State on 2026-11-15: no `main` exists anywhere yet. The remotes are `code`,
  `gitea` and `github`, all with `master` at the same commit as local.
  Steps: rename the branch, push `main` to all three remotes, set it as the
  default branch in each remote's settings (the user), delete `master` on
  the remotes, and point the prod deployment at `main`.

## 2. Security problems

- **#5 Admin pages must check `admin` themselves.** The checks exist since
  3b (`on_mount {UserAuth, :require_admin}`, plug `require_admin_user`,
  tested). In 3d, put every admin route behind both, and test that a
  non-admin can't reach them, including by live navigation.
- **#58 Does nginx pass the client IP?** The rate limit (#33) reads
  `X-Real-IP` or the last `X-Forwarded-For` entry. If akrasia's nginx sets
  neither, all visitors share one limit (5 mails per 10 minutes). Check the
  nginx config on the server (user) and add `proxy_set_header X-Real-IP
  $remote_addr;` if missing.
- **#59 Password login has no rate limit.** #33 covers only requests that
  send mails. Password guessing on `/users/log-in` is not limited
  (finding 2026-11-15, user decides).
- **#60 Privacy page is not up to date** (finding 2026-11-15, user decides):
  it does not mention the client IP kept in memory for 10 minutes for the
  rate limit (#33), the theme choice in the browser's localStorage, or the
  login mails; it links to Twitter and uses `mailto://` (should be
  `mailto:`). The imprint has the same two links.

## 3. Languages

- **#28 German translations.** All UI texts are English gettext msgids since
  #17 (user: English first). Add the German translations and language
  switching like pan. Reference: `../pan/docs/claude/multilingual.md`.

## 4. Elsewhere

- **#31 The same bot filter for pan:** honeypot field + minimum fill-in time
  instead of the "42" question, as built in akrasia's
  `AkrasiaWeb.UserLive.Registration` (user: "later the same for pan").
