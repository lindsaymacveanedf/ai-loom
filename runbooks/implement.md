# Runbook: Implement a specification

When the user says **"implement"** with a reference to a **spec file** in `specifications/`, follow this runbook to implement the spec end-to-end: clone, branch, code, commit, push, open PR with a thorough description.

**Repo list and clone URLs:** See **[REPOS.md](../REPOS.md)**. **Work dir setup:** [general-fix.md](./general-fix.md). **Push/PR convention:** [push-changes.md](./push-changes.md). **GitHub API recipes:** [TOOLS.md](../TOOLS.md).

---

## Trigger pattern

Typical form: **`implement <spec-file>`** or **`implement #file:<spec-file>`**

Examples:
- `implement #file:cloudfront-apigw-routing-2026-03-04.md`
- `implement specifications/new-feature-2026-03-15.md`

Parse from the user message:
- **Spec file:** The specification document (must exist in `specifications/`).
- **Repo:** Read the spec — it must state which repo(s) it targets.

If the spec file or target repo is unclear, ask once, then proceed.

---

## Steps

### 1. Read context

Read **[CONTEXT.md](../CONTEXT.md)**, **[REPOS.md](../REPOS.md)**, and **[TOOLS.md](../TOOLS.md)**.

### 2. Read and understand the spec

- Read the full spec file.
- Identify: **target repo(s)**, **files changed** (new, modified, deleted), **implementation order**, **key decisions**, **acceptance criteria**, **pre/post-deployment steps**.
- If the spec references a **reference implementation** (e.g. a repo cloned in `edf/`), read the relevant files there for patterns.

### 3. Read the existing codebase

- Read all files in `human-read-only/<repo>/` that the spec will modify or that neighbour the new files. This gives you the current state, naming conventions, variable patterns, and provider configuration.
- Read **all** environment tfvars / config files that will be modified.
- Read any reference implementation files mentioned in the spec.

### 4. Create work directory and clone

From the workspace root:

```bash
DATE=$(date +%Y-%m-%d)
SLUG="<short-spec-slug>"  # e.g. "cloudfront-apigw"
WORK_ROOT="work/${SLUG}-${DATE}"
mkdir -p "$WORK_ROOT"
```

Clone the target repo(s) from **[REPOS.md](../REPOS.md)** into the work dir. Create a feature branch:

```bash
cd "$WORK_ROOT"
git clone <clone-url>
cd <repo>
git checkout -b <descriptive-branch-name>
```

### 5. Implement changes

Follow the spec's **implementation order** (it's ordered for a reason — dependencies between files). For each file:

- **New files:** Create with full content.
- **Modified files:** Read the current version from the clone, apply changes precisely.
- **Deleted files:** Remove via `git rm`.

**Quality checks while implementing:**
- Follow the existing codebase conventions (naming, formatting, comment style).
- Ensure cross-references are correct (e.g. resource names referenced from other files).
- Verify provider aliases match (e.g. `aws.us_east_1`).
- Check that new variables have defaults where the spec says they should.
- Ensure all new resources are tagged consistently with existing patterns.

### 6. Commit

Write a **detailed commit message** with:
- **Subject line:** `feat: <concise summary>` (conventional commits style)
- **Body:** Bullet-point each major change category (new files, modified files, deleted files) with specifics — not just file names but *what* was added/changed and *why*.
- **Footer:** Reference the spec file name.

```bash
git add -A
git commit -m "feat: <subject>

- <category 1>: <details>
- <category 2>: <details>
...

Spec: <spec-file-name>"
```

### 7. Push and create PR

Push the branch, then create a PR via the GitHub API (see [TOOLS.md](../TOOLS.md) "Create a PR" recipe).

**The PR description must be thorough.** Use this structure:

```markdown
## Summary
<1–2 sentences: what this PR does and why, linking to the spec if possible>

## Problem
<What's wrong today / what's missing>

## Solution
<How this PR solves it — the approach, not the file list>

## Changes

### New files
| File | Purpose |
|------|---------|
| `path/to/file` | <what it contains and why> |

### Modified files
| File | What changed |
|------|--------------|
| `path/to/file` | <specific changes, not just "updated"> |

### Deleted files
| File | Why |
|------|-----|
| `path/to/file` | <reason for deletion> |

## Key design decisions
| Decision | Rationale |
|----------|-----------|
| <decision> | <why this choice was made> |

## Pre-deployment
<Any manual steps required before applying — e.g. tear down out-of-band resources>

## Testing
- [ ] <acceptance criterion 1>
- [ ] <acceptance criterion 2>
...
```

**Rules for the PR description:**
- Every new/modified/deleted file must be listed with a **specific** description of what it contains or what changed — not just the file name.
- Key design decisions from the spec must be included so reviewers understand *why*, not just *what*.
- Acceptance criteria from the spec become checkbox items in the Testing section.
- Pre-deployment steps (if any) must be called out explicitly.
- The description should be **self-contained** — a reviewer should understand the PR without needing to read the spec.

### 8. Post-PR housekeeping

- **Rename the clone directory** to include the PR number: `mv <repo> <repo>-<pr#>`
- **Update `work/WORK-TO-PR.md`** with the new run directory → PR mapping.
- **Commit and push meta changes** (WORK-TO-PR.md) in the root repo.

### 9. Reply to the user

Provide a brief summary with:
- Clickable PR link: `[PR #N](url)`
- Files changed count
- Any pre-deployment reminders
- Any items noted as out of scope / future work

---

## Difference from other runbooks

| Runbook | When to use |
|---------|-------------|
| **implement** (this) | User has a **spec file** with detailed requirements, file list, and implementation order. Follow the spec precisely. |
| **feature** | User gives a **brief description** (no spec). Implement directly from the description. |
| **design** | User wants to **plan first** — interview, produce a spec, then optionally implement. |

---

## Common mistakes to avoid

1. **Lazy PR descriptions** — "Implements spec X" is not acceptable. The PR description must be detailed enough for a reviewer to understand the full scope without reading the spec.
2. **Trying `gh` CLI** — it's not installed. Use `curl` with `$GITHUB_TOKEN` per [TOOLS.md](../TOOLS.md).
3. **Skipping the reference implementation** — if the spec references one, read it first. It shows the proven patterns.
4. **Not reading existing files** — always read the current state before modifying. Variable names, provider aliases, resource naming conventions must be consistent.
5. **Implementing out of order** — the spec's implementation order exists for dependency reasons. Follow it.
