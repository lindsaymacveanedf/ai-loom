# Runbook: Resolve merge conflicts on a PR

Use this runbook when the user wants to **resolve merge conflicts** on an open pull request (e.g. branch is behind main and has conflicts). Follow it after reading **[CONTEXT.md](../CONTEXT.md)**.

**Repos this applies to:** Trunk-style repos with PRs. Get clone URL and branch conventions from **[REPOS.md](../REPOS.md)**.

---

## Overview

1. Get **PR number, repo, and PR branch** from the user's message or attached PR.
2. Create a **run directory** under `work/` (e.g. `work/pr145-resolve-conflicts-2026-02-04`).
3. **Clone** the repo, **checkout** the PR branch, **merge** main into it (resolve conflicts), **commit** the merge.
4. Rename clone to `<repo>-<pr#>` and update **work/WORK-TO-PR.md**.
5. **Push** the branch to update the PR, then tell the user the PR URL.

---

## Step 1: Get PR details

- **PR number** (e.g. 145).
- **Repo** (e.g. backend). Map from PR URL or context.
- **PR branch name** (e.g. `feature/new-auth`). From the user's message, attached PR, or GitHub (head ref).

If the user didn't specify a PR, ask which PR (number and repo) they mean.

---

## Step 2: Create run directory and clone

From the **workspace root** (directory containing REPOS.md, runbooks, work/):

```bash
DATE=$(date +%Y-%m-%d)
WORK_ROOT="work/pr${PR_NUM}-resolve-conflicts-${DATE}"
mkdir -p "$WORK_ROOT"
cd "$WORK_ROOT"
git clone <clone-url-from-REPOS.md>
cd <repo-name>
```

Use the clone URL for the repo from **[REPOS.md](../REPOS.md)**.

---

## Step 3: Checkout PR branch and merge main

```bash
git fetch origin <pr-branch> main
git checkout <pr-branch>
git merge origin/main --no-ff --no-edit
```

- If the repo has `merge.ff = only`, the merge will fail with "Not possible to fast-forward, aborting." Use `--no-ff` explicitly so the merge creates a merge commit and surfaces conflicts.
- If the merge succeeds with no conflicts, commit (if needed) and skip to Step 5.

---

## Step 4: Resolve conflicts

1. List conflicted files: `git status` (or `git diff --name-only --diff-filter=U`).
2. Open each conflicted file and resolve:
   - Remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
   - Keep the correct logic (often the PR branch's version, or a sensible combination of both). Prefer the version that matches the PR's intent and doesn't reference undefined variables.
3. Stage resolved files: `git add <path> ...`
4. Verify no unmerged paths: `git ls-files -u` (should be empty).
5. Complete the merge: `git commit -m "Merge main into <pr-branch>; resolve conflicts in <files>"`

---

## Step 5: Rename clone and update WORK-TO-PR.md

From `WORK_ROOT`:

```bash
mv <repo-name> <repo-name>-<pr#>
```

Example: `mv backend backend-145`.

Then edit **work/WORK-TO-PR.md**: add a row for this run directory, repo clone name, and PR link. See existing rows and the convention at the bottom of the file.

---

## Step 6: Push the branch

Push the PR branch so the PR on GitHub is updated and conflicts are cleared:

```bash
cd <WORK_ROOT>/<repo>-<pr#>   # e.g. work/pr145-resolve-conflicts-2026-02-04/backend-145
git push origin <pr-branch>
```

**Agent:** Run the push from the clone directory. If push fails (e.g. auth or permission), give the user the exact command and PR URL so they can push manually. On success, confirm the PR is updated and give them the PR URL.

---

## Quick reference

| Step | Action |
|------|--------|
| 1 | Get PR number, repo, PR branch (user or attachment). |
| 2 | Create `work/pr<N>-resolve-conflicts-<date>/`, clone repo from REPOS.md. |
| 3 | Checkout PR branch, `git merge origin/main --no-ff --no-edit`. |
| 4 | Resolve conflicts, `git add`, `git commit` to complete merge. |
| 5 | Rename clone to `<repo>-<pr#>`, update work/WORK-TO-PR.md. |
| 6 | Push branch (`git push origin <pr-branch>`); on failure, give user the command and PR URL. |
