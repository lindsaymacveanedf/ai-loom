# Runbook: Feature (immediate implementation)

When the user says **"feature"** (e.g. **"start my-repo feature add a flag"**), **immediately attempt to implement** the described feature. Do not run a design interview first — treat this as a direct implementation request.

**Repo list and clone URLs:** See **[REPOS.md](../REPOS.md)**. **Work dir setup:** [general-fix.md](./general-fix.md). **Push/PR convention:** [push-changes.md](./push-changes.md).

---

## Trigger pattern

Typical form: **`start <repo> feature <description>`**

Examples:
- `start frontend feature add a flag`
- `feature backend add a health check endpoint`
- `my-repo feature add dark mode toggle`

Parse from the user message:
- **Repo:** The named repo (must exist in REPOS.md).
- **Feature description:** The rest of the request (e.g. "add a flag", "add a health check endpoint"). Use this to drive implementation.

If the repo or feature description is unclear, ask once for the repo and/or a one-line description, then proceed.

---

## Steps

1. **Read [CONTEXT.md](../CONTEXT.md)** (workspace root).
2. **Parse** repo and feature description from the user message.
3. **Create a run directory** under `work/` (e.g. `work/feature-frontend-flag-YYYY-MM-DD`). Use [general-fix.md](./general-fix.md) Step 1.
4. **Clone only that repo** into the run dir from REPOS.md. Use the branch convention (main, or develop where configured). See general-fix Step 2.
5. **Create a feature branch** in the clone (e.g. `feature/add-flag` or `123-add-flag`). Branch naming: short slug from the feature description.
6. **Implement the feature** in that repo. Use the codebase and existing patterns; add tests if appropriate. Do not pause for a design spec — implement directly from the description.
7. **Push and open a PR** (or push to main) per [push-changes.md](./push-changes.md) for that repo. Update work/WORK-TO-PR.md if you create a PR.
8. **Reply** with a brief summary and, if applicable, the clickable PR link at the end.

---

## Difference from "design"

- **Design:** Interview first, produce a spec/plan, confirm with the user, then optionally implement. See [design.md](./design.md).
- **Feature:** No interview. Parse repo + description and **immediately attempt to implement**; ask only if repo or description is ambiguous.
