# Runbook: Clear work directory

Use this runbook when the user wants to **clear the work directory**. First clarify whether they want a full clean or to only remove run dirs whose PRs are closed/merged.

**Trigger:** User says they want to clear the work dir, clean all work subdirs, reset work, or similar.

---

## Step 0: Clarify intent

**Ask the user:** Do you want a **full clean** (delete all work subdirs regardless of PR status), or should I **only delete run dirs whose PRs are closed/merged**?

Then follow either **Full clean** or **Check PRs first** below.

---

## Full clean (delete everything regardless)

1. **Delete every subdirectory** under `work/` from the workspace root. Do **not** delete `work/WORK-TO-PR.md`.
   - From repo root: remove each `work/<subdir>/` (e.g. `rm -rf work/pr145-conflicts-2026-02-04 work/feature-auth-2026-02-04` … or use a shell loop over `work/*/`).
   - Only remove directories; leave `work/WORK-TO-PR.md` in place.

2. **Reset work/WORK-TO-PR.md** to the standard header and table header row, with no data rows. Preserve the convention note at the bottom.

   Standard content:

   ```markdown
   # Work directories → PRs

   Maps each run directory under `work/` to its open/merged PRs for **trunk-style repos**. See [runbooks/general-fix.md](../runbooks/general-fix.md) for the rename convention.

   | Run directory | Repo clone(s) | PR(s) | Notes |
   |---------------|---------------|-------|--------|

   **Convention:** When you open a PR for a trunk-style repo, rename that clone dir to `<repo>-<pr#>` (e.g. `backend-142`). Update this file when adding or removing run dirs.
   ```

3. **Ensure current/ has all repos and is up to date:** For every repo listed in [REPOS.md](../REPOS.md), ensure `current/<repo>` exists — if not, clone it. Then in each `current/<repo>`: `git fetch origin`, then `git reset --hard origin/main` (or `origin/develop` where configured). This discards any local changes and leaves current/ matching the remote.

4. **Reply briefly:** Confirm that all work subdirs are removed, WORK-TO-PR.md has been reset, and current/ is up to date.

---

## Check PRs first (only delete where PRs are closed/merged)

For each run directory under `work/`, determine whether it is tied to an **open** PR in the remote repo. Delete only run dirs that have **no** open PR. Keep run dirs that have at least one open PR.

### 1. Discover clones and branches in each run dir

- List every subdirectory under `work/` (each `work/<name>/`).
- For each run dir, look at its **immediate children**: any directory that contains a **`.git`** is a full clone. For each such clone, record:
  - **Branch:** `git -C <path> rev-parse --abbrev-ref HEAD`
  - **Remote:** `git -C <path> remote get-url origin` (normalize to `owner/repo` for `gh`).
- Run dirs that contain only **partial copies** (subdirs named like a repo but **no** `.git`) or only files (e.g. `spec.md`) have no branch to check; use the **run dir name** to infer a PR number when possible.

### 2. Decide "open PR" per run dir

- **If the run dir has at least one full clone (with `.git`):**
  - For each clone on a **feature branch** (not `main` or `develop`): check if that branch has an **open** PR:
    `gh pr list --repo <owner>/<repo> --head <branch> --state open`.
    If the list is non-empty, this run dir is tied to an open PR → **keep**.
  - For each clone on **main** or **develop**: that clone is not tied to a feature PR; it does not by itself imply an open PR.
  - If **any** clone in the run dir is on a feature branch with an open PR → **keep** the run dir. If **all** clones are on main/develop or their feature branches have **no** open PR → **delete**.
- **If the run dir has no full clone** (only partial copies or files):
  - Infer PR from the run dir name (e.g. `pr-266`, `pr170`, `pr174`) and repo. Use `gh pr view <number> --repo <owner>/<repo> --json state`. If **OPEN** → **keep**; if **MERGED** or **CLOSED** → **delete**.
  - If the run dir name does not imply a PR number, treat as **no open PR** → **delete**.
- **Repos that push straight to main**: run dirs that only contain such clones on `main` have no open PR → **delete**.

### 3. Delete and update

- **Delete** only run dirs that have no open PR.
- **Update work/WORK-TO-PR.md:** Remove table rows for run dirs that were deleted. **Add** rows for any run dirs that were **kept** and are not yet in the table.
- **Ensure current/ has all repos and is up to date:** As in full clean step 3.
- **Reply briefly:** Say what was deleted and what was left (if any), and confirm current/ is up to date.
