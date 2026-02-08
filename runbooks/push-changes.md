# Runbook: Push changes from work directory

When the user says **"push"**, **"push our changes"**, or **"push changes"**, apply the **per-repo push convention** below for each repo in the work dir that has uncommitted or unpushed changes.

This runbook is the **source of truth** for how to ship work dir changes. Read it whenever the user asks to push.

**Do not ask** whether to open a PR or push direct for repos that are configured for direct-to-main. For those repos, push straight to main.

---

## Per-repo push convention

Check **[REPOS.md](../REPOS.md)** for each repo's push workflow. Common patterns:

| Workflow | Action | Example repos |
|----------|--------|---------------|
| **PR-based** | Create a feature branch from main (or develop), commit changes, push the branch, open a pull request. Do **not** push directly to main. | Most application repos |
| **Direct-to-main** | Commit on main, push `main` to origin. No PR. Do not ask—just push. | Scripts, utilities, ops tooling |
| **Develop branch** | For preproduction work: branch from `develop`, push branch, open PR to `develop`. For production: merge to main via release process. | Repos with staging environments |

**Default:** If a repo is not explicitly configured, prefer **create a PR** unless REPOS.md or project docs say otherwise.

---

## Steps (when user says "push")

1. **Identify repos with changes** in the current work dir (e.g. `work/<purpose>-<date>/`): `git status` in each clone.
2. **For each repo**, apply the convention from REPOS.md:
   - **PR repos:** Create a descriptive branch (e.g. `fix-terraform-deploy-concurrency`), commit, push branch, run `gh pr create --repo <owner/repo> --base main` (or `--base develop` for develop-based repos). Optionally update work/WORK-TO-PR.md and rename clone to `<repo>-<pr#>` per [general-fix.md](./general-fix.md).
   - **Direct-to-main repos:** Commit on main (or merge feature branch into main), then `git push origin main`.
3. **AI Loom workspace root** (this repo): If REPOS.md, CONTEXT.md, runbooks, or other root files changed, commit locally and push if a remote is configured.

---

## Reference

- **Repo list and clone URLs:** [REPOS.md](../REPOS.md)
- **Branch/workflow per repo:** [REPOS.md](../REPOS.md) (section "Branch and workflow")
- **Work dir setup and clone dir rename:** [general-fix.md](./general-fix.md)
- **Map work dirs to PRs:** [work/WORK-TO-PR.md](../work/WORK-TO-PR.md)
