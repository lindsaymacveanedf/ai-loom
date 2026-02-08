# GitHub Copilot Instructions

This file provides context and instructions for GitHub Copilot when working in this repository.

## Project Overview

This is an **AI Loom** workspace — a framework for coordinating AI agents across multi-repo development workflows. The workspace contains runbooks, context files, and conventions that help AI agents work effectively.

## Key Files to Reference

When helping with tasks, reference these files for context:

- **CONTEXT.md** — Root context with architecture, guidelines, and runbook references
- **REPOS.md** — Repository list, clone URLs, and branch conventions
- **TOOLS.md** — CLI tools and common commands
- **runbooks/** — Operational procedures for common workflows

## Work Directory Pattern

- **Never modify files in `current/`** — this is the read-only baseline for inspection
- **All work happens in `work/`** — create run directories like `work/<purpose>-<date>/`
- Clone only the repos needed for each task

## Coding Guidelines

- Comment **why**, not what — assume the code says how
- Prefer clarity, testability, and scalability over cleverness
- Branch names: `<task#>-<purpose>` (e.g., `123-fix-auth-handler`)
- No shared packages unless explicitly configured; duplication over premature abstraction

## When Making Changes

1. Check REPOS.md for the correct repository and branch conventions
2. Follow the appropriate runbook from `runbooks/`
3. Use clickable markdown links for PRs: `[PR #N](url)`
4. Update `work/WORK-TO-PR.md` when opening PRs

## Agent Instructions

- If the prompt lacks information, ask clarifying questions
- Do not hallucinate architecture — ask if unclear
- Suggest before rewriting unless in tests or infrastructure
- Prioritize code clarity and maintainability
