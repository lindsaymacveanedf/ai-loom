# Agent context — start here

Read **CONTEXT.md** at the start of every conversation. It is the single root context: runbooks, key docs (REPOS.md, work/WORK-TO-PR.md, TOOLS.md), architecture, and guidelines.

---

## Keyword triggers

When the user's message matches one of these keywords, read CONTEXT.md first, then read and follow the referenced runbook to completion.

| Keyword | Action |
|---------|--------|
| **start** | Read CONTEXT.md, then ask the user what they'd like to do. |
| **debug** (+ PR link, pipeline run URL, endpoint/failure, or "debug <app>") | Read and follow `runbooks/debug.md`. PR link → resolve to latest run for that PR, then pipeline flow; do not ask for a run URL. |
| **design** or **plan** (or "design specs", "plan a feature") | Read and follow `runbooks/design.md`. Do not jump to implementation; interview first. |
| **feature** (e.g. "start my-repo feature add a flag") | Read and follow `runbooks/feature.md`. Immediately attempt to implement; parse repo and feature description, set up work dir and clone, create feature branch, implement, push/PR. No design interview first. |
| **evaluate** (+ PR reference) | Read and follow `runbooks/evaluate.md`. |
| **conflicts** (or "resolve conflicts" + PR reference) | Read and follow `runbooks/resolve-conflicts.md`. |
| **clean** | Ask full clean vs PR-check; then delete work subdirs per choice, reset WORK-TO-PR.md if full clean. **Always finish by** ensuring `human-read-only/` has all repos from REPOS.md and each is up to date. Confirm briefly. |
| **end** | Identify the work directory and which repo(s) we adjusted. Refresh `human-read-only/` for repos we worked on; review unfinished work; delete the run dir; update WORK-TO-PR.md. **Always finish by** ensuring `human-read-only/` has all repos from REPOS.md and each is up to date with remote main (or develop where configured). Confirm cleanup is done. |

---

## Always-apply rules

These apply to every interaction regardless of keyword.

### Ask before creating scripts
Before creating any new shell script (`.sh`, `.bash`), Python script for a one-off task, or `scripts/` directory, ask the user for permission. Prefer running commands directly over generating scripts for one-time tasks.

### Ask before creating runbooks
Before creating a new runbook, ask whether it is a repeatable procedure or a one-off fix. Only create a runbook if the user confirms it will be repeated. For one-off operations, update existing docs if appropriate.

### Clickable PR and repo links
When referencing a pull request or any GitHub URL, always format as a clickable markdown link: `[PR #142](https://github.com/ORG/REPO/pull/142)`. Never paste bare URLs. When finishing a task involving a PR, **put the clickable PR link at the very end** of the summary so the user can click without scrolling.

### Commit and push meta code to ai-loom
When making changes to meta code (anything outside `work/` — runbooks, CONTEXT.md, REPOS.md, README.md, root docs), **stage** and **commit** in the **root repo** (this workspace), then push to origin. Do not commit or push anything under `work/`.

### macOS notifications when waiting for user input
**ALWAYS** send a macOS notification when you need user input (a question, a decision, or approval). Use `osascript -e 'display notification "<message>" with title "Claude Code" sound name "Glass"'`. Also send a notification when a long-running background task completes. Never leave the user waiting without a notification.

### No file indexes in context docs
Do not add or maintain indexes of individual files in context docs (CONTEXT.md, CLAUDE.md). Reference directories (e.g. `runbooks/`, `docs/`) and note what kind of content lives there. The agent discovers specific files by searching.

### Development guidelines
- Ask if the prompt lacks enough information.
- Comment **why**, not what; avoid magic numbers and stringly-typed code.
- Prefer clarity, testability, and scalability over cleverness.
- Branch names: `<task#>-<purpose>` (e.g. `123-fix-auth-handler`).
- No shared packages across components unless explicitly configured; duplication over premature abstraction.
- Components talk over HTTP; if ownership is unclear, prefer the API.

---

## Key references

| Doc | Purpose |
|-----|---------|
| [CONTEXT.md](./CONTEXT.md) | Root context — runbooks, architecture, guidelines. Read first. |
| [REPOS.md](./REPOS.md) | Repo list, clone URLs, branch conventions. Source of truth for cloning. |
| [TOOLS.md](./TOOLS.md) | CLI tools and common commands. |
| [work/WORK-TO-PR.md](./work/WORK-TO-PR.md) | Map of run directories to open/merged PRs. |
| `runbooks/` | All operational runbooks (general-fix, push-changes, debug, design, etc.). |
| `docs/` | Project documentation. |
