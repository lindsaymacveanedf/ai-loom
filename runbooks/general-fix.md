# Runbook: General fix (work directory and repo clone)

This runbook describes the standard way to set up a **work directory** and clone the **repos you need** for any fix or feature. Use it when you need to work across one or more repos.

**Repo list and clone URLs:** See **[REPOS.md](../REPOS.md)** for all repos, branch conventions, and clone examples.

---

## Work dir vs human-read-only/ — do not touch human-read-only/

- **Work only in `work/`.** Create a run directory under `work/<purpose>-<date>/`, clone repos there, and do all edits and task work in that run dir. All agent work happens under `work/`.
- **Never touch `human-read-only/`.** The `human-read-only/` directory is for the user to inspect the baseline codebase. Agents must **not** create, edit, or modify anything in `human-read-only/`. The only exception is when the user says **"end"**: then the agent updates `human-read-only/` by running `git pull` in each `human-read-only/<repo>` that was worked on, so the user has an up-to-date baseline. No other changes in `human-read-only/` are allowed.

---

## Overview

1. Create a **run directory** under `work/` named by purpose and date (e.g. `work/fix-auth-2026-02-03`).
2. Look up **REPOS.md** to see which repos exist and their clone URLs.
3. Clone **only the repos needed** for this fix into the run directory.
4. Do the task-specific work (see task runbooks or your plan) **in the run dir** — never in `human-read-only/`.
5. When done, **back out**: delete the run directory and optionally remote feature branches.

The `work/` tree is in `.gitignore`, so clones are never committed.

---

## Step 1: Create run directory

Use a descriptive slug and date so each run has a clear, isolated folder.

**Run directory pattern:** `work/<purpose>-<YYYY-MM-DD>`

Examples:
- `work/fix-auth-2026-02-03`
- `work/feature-dashboard-2026-02-03`
- `work/debug-api-2026-02-05`

```bash
# From workspace root (directory that contains REPOS.md, runbooks, etc.)
DATE=$(date +%Y-%m-%d)   # or set explicitly, e.g. 2026-02-03
WORK_ROOT="work/my-fix-${DATE}"
mkdir -p "$WORK_ROOT"
cd "$WORK_ROOT"
```

---

## Step 2: Look up repos and clone only what you need

1. **Open [REPOS.md](../REPOS.md)** and note:
   - Which repos exist
   - Clone URLs
   - Branch/workflow conventions (develop vs main, PR expectations)

2. **Clone only the repos required for this fix** into `WORK_ROOT`. Avoid cloning everything if the task touches only one or two repos.

```bash
# From WORK_ROOT (e.g. work/my-fix-2026-02-03)
# Example: clone frontend and backend only
git clone https://github.com/your-org/frontend.git
git clone https://github.com/your-org/backend.git

# If you need all branches (e.g. for repos using develop):
cd frontend && git fetch origin 'refs/heads/*:refs/remotes/origin/*' && cd ..
```

3. **Check branch conventions:** Some repos may use `develop` for local development. After cloning, checkout the appropriate branch before running.

4. **Paths from workspace root:**
   `work/<purpose>-<date>/<repo-name>/`
   e.g. `work/fix-auth-2026-02-03/frontend`,
   `work/fix-auth-2026-02-03/backend`.

Use the same `WORK_ROOT` (and paths) in your later steps in this run.

---

## Step 3: Do the task-specific work

What you do next depends on the fix:

- **Feature implementation:** Follow **[feature.md](./feature.md)** or your plan.
- **Design work:** Follow **[design.md](./design.md)**.
- **Other fixes:** Checkout the right branches (see REPOS.md), make changes, run tests, open PRs or push as per repo workflow.

### When a PR is opened (trunk-style repos only)

For repos that use trunk-style development (PRs into main), rename the **clone directory** to include the PR number once the PR is open. That makes it easy to see which directory is tied to which PR.

```bash
# From WORK_ROOT, after opening PR #123 for backend
mv backend backend-123

# If you also opened PR #124 for frontend
mv frontend frontend-124
```

Use the new path for the rest of the run (e.g. `work/my-fix-2026-02-03/backend-123`).

---

## Step 4: Back out – delete run dir (and optional branches)

When the fix is done and you no longer need the local clones:

1. **Optional:** Delete feature branches on remotes if they're already merged.
2. **Delete only the run directory for this run** so the workspace stays clean.

**Important:** Delete **only** the specific run directory you created in Step 1 for *this* run. Do **not** delete other directories under `work/` — they may be from other runbooks or sessions.

```bash
# From workspace root — use the SAME path you used in Step 1 for THIS run only
rm -rf work/my-fix-2026-02-03
```

---

## Quick reference

| Step | Where | Action |
|------|--------|--------|
| 1 | workspace root | Create `work/<purpose>-<YYYY-MM-DD>/`. |
| 2 | REPOS.md + `work/.../` | Look up repos; clone only needed ones into run dir. |
| 3 | `work/.../<repo>/` | Task-specific work. For trunk-style repos, when PR is opened, rename clone dir to `<repo>-<pr#>`. |
| 4 | workspace root | Delete `work/<purpose>-<date>/`; optionally delete remote branches. |

---

## Notes for agents

- **Never touch `human-read-only/`.** Work only in `work/<run-dir>/`. The `human-read-only/` directory is for the user to inspect the baseline; agents do not edit or create files there (except on **end**: then refresh `human-read-only/` with `git pull` only).
- **One run folder per batch:** Use a single `work/<purpose>-<date>/` for the whole run so paths stay consistent.
- **Back out = this run only:** When deleting the run directory (Step 4), delete **only** the directory created for the current run. Never run `rm -rf work/*` or delete all children of `work/`.
- **REPOS.md is the source of truth** for repo names, clone URLs, and branch conventions. Don't guess repo list or URLs.
- **Clone only what you need** to keep the run dir small and fast.
- **Rename for PR visibility:** When a PR is opened for a trunk-style repo, rename that clone dir to `<repo>-<pr#>` so it's obvious which directory is tied to which PR.
