# Runbook: Evaluate a PR (risk assess, merge if low risk)

Use this runbook when the user wants to **evaluate** a pull request: clone the repo, assess risk, then merge and clean up if low risk, or explain why if high risk. Follow it after reading **[CONTEXT.md](../CONTEXT.md)**.

**Repos this applies to:** Any repo in REPOS.md with open PRs.

---

## Overview

1. Get **PR number, repo, and PR branch** from the user's message or attached PR.
2. Create a **run directory** under `work/` and **clone** the repo (e.g. `work/evaluate-pr150-2026-02-04`).
3. **Assess the PR**: review changes, release notes, and how the repo uses affected code; decide **low risk** vs **high risk**.
4. **If low risk:** Merge the PR (e.g. `gh pr merge`), then **delete** the run directory and update **work/WORK-TO-PR.md** if it was updated.
5. **If high risk:** Explain why; do not merge. The user can clean the work directory with **end** or **clean** if desired.

---

## Step 1: Get PR details

- **PR number** (e.g. 150).
- **Repo** (e.g. backend). Infer from the PR URL or user message.
- **PR branch name**. From the user's message, attached PR, or `gh pr view <number> --repo <owner/repo> --json headRefName`.

If the user didn't specify a PR, ask which PR (number and repo) they mean.

---

## Step 2: Create run directory and clone

From the **workspace root** (directory containing REPOS.md, runbooks, work/):

```bash
DATE=$(date +%Y-%m-%d)
WORK_ROOT="work/evaluate-pr${PR_NUM}-${DATE}"
mkdir -p "$WORK_ROOT"
cd "$WORK_ROOT"
git clone <clone-url-from-REPOS.md>
cd <repo-name>
```

Use the clone URL for the repo from **[REPOS.md](../REPOS.md)**.

Optional: checkout the PR branch locally if you need to run builds or tests.

---

## Step 3: Assess risk

- **Review the PR**: diff, description, release notes / changelog for dependency bumps.
- **Consider**: breaking changes, security fixes, and whether this repo's usage is affected.
- **Classify:**
  - **Low risk:** Safe to merge (e.g. dependency bump with no impact on this repo's usage, or non-invasive change with clear benefit).
  - **High risk:** Do not merge; explain why (e.g. breaking API changes, infra or auth changes, unclear impact).

---

## Step 4a: If low risk — merge and delete workspace

1. Merge the PR (branch protection may require approval or admin override):

   ```bash
   gh pr merge <PR_NUM> --repo <owner>/<repo> --squash
   ```

   If blocked by policy, use `--admin` only if the user has admin rights; otherwise report that the PR is mergeable once requirements are met and provide the PR URL.

2. **Delete the run directory** and, if you added a row for this run to work/WORK-TO-PR.md, remove that row:

   ```bash
   # From workspace root
   rm -rf work/evaluate-pr<PR_NUM>-<DATE>
   ```

   Edit **work/WORK-TO-PR.md** and remove the row for `evaluate-pr<PR_NUM>-<DATE>` if present.

3. Confirm to the user: merged and workspace cleaned up; include the PR URL.

---

## Step 4b: If high risk — explain, do not merge

1. Explain clearly **why** the PR is high risk (e.g. breaking change that affects this repo, missing tests, infra impact).
2. Do **not** merge. Optionally suggest what would make it low risk (e.g. code changes, follow-up PR).
3. The user can clean the work directory later with **end** or **clean**.
