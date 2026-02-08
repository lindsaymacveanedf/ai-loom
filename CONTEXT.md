# Agent context – start here

Read this file at the **start of a new chat**. It tells you where runbooks, references, and procedures live, and gives a terse overview of the project. The code is the truth; this file is the map.

---

## Overview (terse)

<!-- CUSTOMIZE: Add a brief description of your project here -->
This workspace coordinates work across **multiple repos**; the list, clone URLs, and branch conventions are in **[REPOS.md](./REPOS.md)**.

**Default workflow:** `work/` exists. Create a run directory under `work/<purpose>-<date>/`, clone only the repos you need from REPOS.md, do the task **in that run dir**, then back out. See runbook **[general-fix](./runbooks/general-fix.md)**. **Never touch `current/`** — work only in `work/`. The `current/` directory is for the user to inspect the baseline codebase; agents must not modify it. When the user says **"end"**, the session work dir is deleted after refreshing **`current/`** (git pull only in each repo we worked on) so the user has an up-to-date baseline; `current/` is gitignored.

---

## When to read what

- **New chat, or task is fix / deploy / runbook / change request / PR comments:** Read this file, then the relevant runbook from `runbooks/`.
- **User says "push" or "push our changes":** [runbooks/push-changes.md](./runbooks/push-changes.md) — per-repo convention.
- **User says "design" (or "design specs"):** [runbooks/design.md](./runbooks/design.md) — interview the user to produce a written spec/plan for a feature or complex fix; optionally implement and open a PR.
- **User says "debug" with a PR link, pipeline run URL, an endpoint/failure, or "debug <app>":** [runbooks/debug.md](./runbooks/debug.md) — PR link: resolve to latest workflow run for that PR, then same as pipeline. Pipeline URL: use gh to inspect; handle failures. Endpoint/failure: ask timeframe and environment, use logs, form theory and fix. Local app: general-fix, spin up app, wait for user, then debug and plan a fix.
- **User says "conflicts" (or "resolve conflicts") and references a PR:** [runbooks/resolve-conflicts.md](./runbooks/resolve-conflicts.md) — set up work dir, clone repo, merge main into PR branch, resolve conflicts, commit, update WORK-TO-PR.md, push branch.
- **User says "evaluate" and references a PR:** [runbooks/evaluate.md](./runbooks/evaluate.md) — clone repo into work dir, assess risk; if low risk merge and delete work dir; if high risk explain why.
- **User says "feature" (e.g. start my-repo feature add a flag):** [runbooks/feature.md](./runbooks/feature.md) — immediately attempt to implement: parse repo and feature description, set up work dir and clone, create feature branch, implement, push/PR per push-changes. No design interview first.
- **Repo list, clone URLs, branch conventions:** [REPOS.md](./REPOS.md).
- **Which work dirs map to which PRs:** [work/WORK-TO-PR.md](./work/WORK-TO-PR.md).
- **CLI tools and commands:** [TOOLS.md](./TOOLS.md).

---

## Runbooks (operational procedures)

All runbooks live in **`runbooks/`**.

| Runbook | Purpose |
|--------|---------|
| [general-fix.md](./runbooks/general-fix.md) | Set up a work directory and clone only the repos you need (work dir → clone from REPOS.md → task work → back out). |
| [clear-work-dir.md](./runbooks/clear-work-dir.md) | **When user wants to clear work dir:** Remove all run subdirs under `work/` and reset WORK-TO-PR.md to a clean table. |
| [push-changes.md](./runbooks/push-changes.md) | **When user says "push":** per-repo convention — create PR or push direct to main based on repo settings. |
| [design.md](./runbooks/design.md) | **When user says "design":** Interview to produce a written spec/plan for a feature or complex fix; optionally implement and open a PR. |
| [debug.md](./runbooks/debug.md) | **When user says "debug":** Handle pipeline failures, endpoint issues, or local app debugging. |
| [resolve-conflicts.md](./runbooks/resolve-conflicts.md) | **When user says "conflicts":** Clone repo, merge main into PR branch, resolve conflicts, commit, push branch. |
| [evaluate.md](./runbooks/evaluate.md) | **When user says "evaluate":** Clone repo into work dir, assess risk; if low risk merge; if high risk explain why. |
| [feature.md](./runbooks/feature.md) | **When user says "feature":** Immediately attempt to implement — parse repo and feature description, set up work dir and clone, create feature branch, implement, push/PR. |

---

## Key reference docs

| Doc | Purpose |
|-----|---------|
| [REPOS.md](./REPOS.md) | Repo list, clone URLs, branch conventions. **Source of truth** when cloning. |
| [work/WORK-TO-PR.md](./work/WORK-TO-PR.md) | Map of run directories under `work/` to open/merged PRs. Update when adding run dirs. |
| [TOOLS.md](./TOOLS.md) | CLI tools and common commands per component. |

---

## Architecture (terse)

<!-- CUSTOMIZE: Add your project architecture here -->
<!-- Example:
- **API:** AWS Lambda + API Gateway, Node.js, DynamoDB
- **Admin:** React + TypeScript (Vite)
- **Mobile:** React Native/Expo
- **Infra:** Terraform, GitHub Actions
-->

---

## Development guidelines

- Ask if the prompt lacks enough information.
- Comment **why**, not what; avoid magic numbers and stringly-typed code.
- Prefer clarity, testability, and scalability over cleverness.
- Branch names: `<task#>-<purpose>` (e.g. `123-fix-auth-handler`).
- No shared packages across components unless explicitly configured; duplication over premature abstraction.
- Components talk over HTTP; if ownership is unclear, prefer the API.
- **PR and repo links:** When referencing a pull request or GitHub URL, always use a clickable markdown link (e.g. `[PR #142](https://github.com/...)`) so the user can open it in one click.
