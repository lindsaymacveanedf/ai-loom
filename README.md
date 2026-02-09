# AI Loom

A framework for coordinating **multiple AI agents** across multi-repo development workflows. AI Loom provides runbooks, context files, and conventions that help AI agents (Claude, Cursor, Copilot, etc.) work effectively on your codebase.

## Getting Started

To set up AI Loom for your project, tell an AI agent to `start init`. The agent will follow [runbooks/init.md](./runbooks/init.md) to:

- Gather your project metadata (name, repos, tools, architecture)
- Generate REPOS.md, TOOLS.md, and CONTEXT.md
- Set up the work directory structure

Example:

```
You: start init
Copilot: I'll set up AI Loom for your workspace...
```

Then follow the agent's prompts to configure your workspace.

## Chat keywords (AI agents)

Agents recognise these short commands:

| Keyword | Action |
|---------|--------|
| **init** | Follow [runbooks/init.md](./runbooks/init.md): gather project metadata and generate configuration files for REPOS, TOOLS, and CONTEXT. |
| **start** | Read [CONTEXT.md](./CONTEXT.md), then ask what you'd like to do. |
| **design** / **plan** | Follow [runbooks/design.md](./runbooks/design.md): interview to produce a spec/plan for a feature or complex fix; optionally implement and open a PR. |
| **feature** (e.g. **start my-repo feature add a flag**) | Follow [runbooks/feature.md](./runbooks/feature.md): immediately attempt to implement — parse repo and feature description, set up work dir and clone, create feature branch, implement, push/PR. No design interview first. |
| **debug** (PR link, pipeline URL, endpoint/failure, or **debug app-name**) | Follow [runbooks/debug.md](./runbooks/debug.md): PR link → latest run for that PR, then pipeline flow; pipeline URL → inspect, handle failures; endpoint/failure → logs, theory + fix; local app → set up workspace, run app, debug. |
| **evaluate** | Follow [runbooks/evaluate.md](./runbooks/evaluate.md) for the PR you provide: clone repo, assess risk; if low risk merge and delete work dir; if high risk explain why. |
| **conflicts** | Follow [runbooks/resolve-conflicts.md](./runbooks/resolve-conflicts.md) for the PR you provide: merge main, resolve conflicts, push. |
| **end** | Delete the current work directory, update `work/WORK-TO-PR.md`, then end the chat. |
| **clean** | Delete all subdirs under `work/` and reset `work/WORK-TO-PR.md`. |

## Directory Structure

```
ai-loom/
├── CONTEXT.md          # Root context for agents - start here
├── CLAUDE.md           # Claude-specific agent instructions
├── REPOS.md            # Repository list, clone URLs, branch conventions
├── TOOLS.md            # CLI tools and commands
├── .cursorrules        # Cursor IDE agent configuration
├── .github/copilot-instructions.md  # GitHub Copilot instructions
├── runbooks/           # Operational procedures for AI agents
├── docs/               # Project documentation
├── current/            # Read-only baseline repos (for inspection)
├── work/               # Temporary working directories (per-session)
└── utils/              # Utility scripts
```

## Core Concepts

### The Work Directory Pattern

- **Never touch `current/`** — read-only baseline repos for inspection
- **Always work in `work/`** — temporary per-session directories
- **Pattern:** `work/<purpose>-<YYYY-MM-DD>/<repo>/`
- **Cleanup:** When user says "end", the work dir is deleted and `current/` is refreshed

### Runbooks as Procedures

Runbooks are not just documentation — they are **step-by-step procedures** that AI agents follow. Each runbook handles a specific workflow (debugging, feature implementation, PR evaluation, etc.).

### Multi-Repo Coordination

AI Loom is designed for projects that span multiple repositories. REPOS.md defines clone URLs and branch conventions; agents clone only what they need for each task.

## Customization

After running `init.sh`, customize these files for your project:

- **REPOS.md** — Add your repositories and their conventions
- **TOOLS.md** — Document your CLI tools and common commands
- **CONTEXT.md** — Add project-specific context and architecture
- **runbooks/** — Add or modify runbooks for your workflows

## License

MIT
