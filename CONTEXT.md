# CONTEXT.md

This is the single source of truth for any AI agent working in this workspace. Read this file at the start of every session.

---

## Purpose

AI Loom is a meta-framework for coordinating AI agents across multi-repository projects for Customer EBS AI. The workspace contains runbooks, context files, and conventions that help AI agents work effectively.

---

## Core Principles

### 1. Work Directory Isolation
- **Never touch `human-read-only/`** — read-only baseline for human inspection; agents must NEVER create, edit, or delete files there
- **Always work in `work/`** — create run directories for each task
- Pattern: `work/<purpose>-<YYYY-MM-DD>/<repo>/`

### 2. Runbooks Are Procedures
- Runbooks in `runbooks/` are step-by-step procedures, not just documentation
- Follow them to completion when triggered by keywords
- Each runbook handles a specific workflow (debug, feature, design, etc.)

### 3. Source of Truth
- **REPOS.md** — Repository list, clone URLs, branch conventions
- **TOOLS.md** — CLI tools and commands
- **This file** — Architecture, guidelines, and agent behavior
- Don't guess — look up the source of truth

---

## Keyword Triggers

When the user's message contains these keywords, follow the corresponding runbook:

| Keyword | Runbook | Action |
|---------|---------|--------|
| init | [init.md](./runbooks/init.md) | Gather project metadata and generate REPOS.md, TOOLS.md, CONTEXT.md, work/ structure |
| start | This file | Read context, ask what to do |
| design / plan | [design.md](./runbooks/design.md) | Interview → spec → optionally implement |
| feature | [feature.md](./runbooks/feature.md) | Immediately implement (no interview) |
| debug | [debug.md](./runbooks/debug.md) | Handle pipeline/PR/endpoint/local debugging |
| evaluate | [evaluate.md](./runbooks/evaluate.md) | Assess PR risk, merge if low risk |
| conflicts | [resolve-conflicts.md](./runbooks/resolve-conflicts.md) | Merge main, resolve conflicts, push |
| end | — | Delete work dir, refresh human-read-only/, cleanup |
| clean | [clear-work-dir.md](./runbooks/clear-work-dir.md) | Delete work dirs, reset WORK-TO-PR.md |
| push | [push-changes.md](./runbooks/push-changes.md) | Per-repo convention — create PR or push direct to main |

**Expanded routing:**
- **PR link, pipeline URL, endpoint failure, or "debug \<app\>":** [debug.md](./runbooks/debug.md) — resolve to workflow run, inspect with `gh`, form theory and fix.
- **"conflicts" with a PR reference:** [resolve-conflicts.md](./runbooks/resolve-conflicts.md) — set up work dir, clone, merge main into PR branch, resolve, commit, push.
- **"evaluate" with a PR reference:** [evaluate.md](./runbooks/evaluate.md) — clone, assess risk; low risk → merge; high risk → explain why.
- **"feature \<repo\> \<description\>":** [feature.md](./runbooks/feature.md) — immediately implement, no design interview.

---

## Additional Runbooks

| Runbook | Purpose |
|--------|---------|
| [general-fix.md](./runbooks/general-fix.md) | Set up a work directory and clone only the repos you need. |

---

## Key Reference Docs

| Doc | Purpose |
|-----|---------|
| [REPOS.md](./REPOS.md) | Repo list, clone URLs, branch conventions. **Source of truth** when cloning. |
| [TOOLS.md](./TOOLS.md) | CLI tools and common commands per component. |
| [work/WORK-TO-PR.md](./work/WORK-TO-PR.md) | Map of run directories under `work/` to open/merged PRs. |
| `docs/` | Developer guides (e.g. AWS CLI setup). |

---

## Architecture

### Project Components

- **cus-ebs-ai-env-init**: Environmental initialization and control plane setup
  - Terraform for AWS infrastructure provisioning
  - GitHub repository and team management
  - Control plane AWS account configuration

- **cus-ebs-ai-unbilled-frontend**: Web application for unbilled
  - React 19 + TypeScript
  - Material-UI (MUI) component library
  - Charts and data visualization (MUI X Charts)
  - Date range pickers for data filtering

- **cus-ebs-ai-unbilled-backend**: Backend services (in development)
  - Technology stack TBD

- **cus-ebs-ai-unbilled-api**: API layer (in development)
  - Technology stack TBD

### AWS Infrastructure

**Accounts:**
- **unbilled-primary** (248108944979) — Primary production environment
- **unbilled-secondary** (450312424446) — Secondary/DR environment
- **unbilled-sandbox** (382535610125) — Development and testing environment

**Authentication:** Azure AD SSO via `aws-toolbox.exe`

---

## Coding Guidelines

- Comment **why**, not what; avoid magic numbers and stringly-typed code
- Prefer clarity, testability, and scalability over cleverness
- Branch names: `<task#>-<purpose>` (e.g., `123-fix-auth-handler`)
- No shared packages across components unless explicitly configured; duplication over premature abstraction
- Components talk over HTTP; if ownership is unclear, prefer the API

---

## Agent Behavior

### Do:
- Ask if the prompt lacks information
- Reference source-of-truth docs (REPOS.md, TOOLS.md, this file)
- Use clickable markdown links for PRs: `[PR #N](url)`
- Follow runbooks to completion
- Suggest before rewriting unless in tests or infrastructure

### Don't:
- Hallucinate architecture — ask if unclear
- Modify files in `human-read-only/`
- Guess repository URLs or branch conventions
- Create scripts without asking first — prefer running commands directly for one-time tasks
- Create new runbooks without confirming they'll be reused — ask whether it is a repeatable procedure or a one-off fix first

### Always-apply rules:
- **Commit and push meta code:** When making changes to meta code (anything outside `work/` — runbooks, CONTEXT.md, REPOS.md, README.md, root docs), stage and commit in the root repo (this workspace), then push to origin. Do not commit or push anything under `work/`.
- **No file indexes in context docs:** Do not add or maintain indexes of individual files in context docs. Reference directories (e.g. `runbooks/`, `docs/`) and note what kind of content lives there. The agent discovers specific files by searching.
- **Clickable PR links:** When referencing a pull request or any GitHub URL, always format as a clickable markdown link: `[PR #142](https://github.com/ORG/REPO/pull/142)`. Never paste bare URLs.

---

## Integration with AI Tools

This workspace is designed to work with multiple AI tools:

- **GitHub Copilot** — Uses `.github/copilot-instructions.md` (auto-loaded, points here)
- **Cursor** — Uses `.cursorrules` for configuration
- **Other agents** — Read this file directly
