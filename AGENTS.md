# AGENTS.md — AI Agent Configuration

This file serves as a portable, AI-readable profile for AI agents working in this codebase. It provides patterns, workflows, and principles that apply across different AI tools (Copilot, Cursor, Claude, GPTs, etc.).

---

## Purpose

AI Loom is a meta-framework for coordinating AI agents across multi-repository projects. This file tells agents how to behave when working in this workspace.

---

## Core Principles

### 1. Work Directory Isolation
- **Never touch `human-read-only/`** — read-only baseline for user inspection; agents must NEVER create, edit, or delete files there
- **Always work in `work/`** — create run directories for each task
- Pattern: `work/<purpose>-<YYYY-MM-DD>/<repo>/`

### 2. Runbooks Are Procedures
- Runbooks in `runbooks/` are step-by-step procedures, not just documentation
- Follow them to completion when triggered by keywords
- Each runbook handles a specific workflow (debug, feature, design, etc.)

### 3. Source of Truth
- **REPOS.md** — Repository list, clone URLs, branch conventions
- **TOOLS.md** — CLI tools and commands
- **CONTEXT.md** — Architecture and guidelines
- Don't guess — look up the source of truth

---

## Keyword Triggers

When the user's message contains these keywords, follow the corresponding runbook:

| Keyword | Runbook | Action |
|---------|---------|--------|
| init | init.md | Gather project metadata and generate REPOS.md, TOOLS.md, CONTEXT.md, work/ structure |
| start | CONTEXT.md | Read context, ask what to do |
| design / plan | design.md | Interview → spec → optionally implement |
| feature | feature.md | Immediately implement (no interview) |
| debug | debug.md | Handle pipeline/PR/endpoint/local debugging |
| evaluate | evaluate.md | Assess PR risk, merge if low risk |
| conflicts | resolve-conflicts.md | Merge main, resolve conflicts, push |
| end | — | Delete work dir, refresh human-read-only/, cleanup |
| clean | clear-work-dir.md | Delete work dirs, reset WORK-TO-PR.md |

---

## Coding Guidelines

- Comment **why**, not what
- Avoid magic numbers and stringly-typed code
- Prefer clarity, testability, and scalability over cleverness
- Branch names: `<task#>-<purpose>` (e.g., `123-fix-auth-handler`)
- No shared packages unless explicitly configured

---

## Agent Behavior

### Do:
- Ask if the prompt lacks information
- Reference source-of-truth docs (REPOS.md, TOOLS.md, CONTEXT.md)
- Use clickable markdown links for PRs: `[PR #N](url)`
- Follow runbooks to completion
- Send macOS notifications when waiting for user input

### Don't:
- Hallucinate architecture — ask if unclear
- Modify files in `human-read-only/`
- Guess repository URLs or branch conventions
- Create scripts without asking first
- Create new runbooks without confirming they'll be reused

---

## Integration with AI Tools

This workspace is designed to work with multiple AI tools:

- **Claude Code** — Uses CLAUDE.md for instructions
- **Cursor** — Uses .cursorrules for configuration
- **GitHub Copilot** — Uses .github/copilot-instructions.md
- **Other agents** — Read CONTEXT.md and AGENTS.md

All these files share the same core principles and guidelines.
