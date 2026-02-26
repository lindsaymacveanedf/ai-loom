# init.md — AI Loom Workspace Initialization

This runbook guides AI agents through setting up an AI Loom workspace. Instead of running `init.sh`, agents follow these steps to gather project information and generate the configuration files.

---

## Overview

Initialization collects project metadata and generates the source-of-truth configuration files:
- **REPOS.md** — Repository URLs and branch workflows
- **TOOLS.md** — Project tools and CLI conventions
- **CONTEXT.md** — Architecture overview
- **work/WORK-TO-PR.md** — Mapping of work directories to PRs

---

## Prerequisites

- AI Loom workspace is initialized (has AGENTS.md, CONTEXT.md, REPOS.md, etc.)
- User is ready to configure the workspace

---

## Step 1: Gather Project Metadata

Ask the user for the following information:

1. **Project/Organization name** — What is this workspace called?
2. **GitHub organization or username** — Where are the repos hosted? (e.g., `my-org`, `my-username`)
3. **Number of repositories** — How many repos does this project use?

Store these values for file generation.

---

## Step 2: Collect Repository Details

For each repository, ask:

1. **Repository name** — Short name (e.g., `frontend`, `backend`, `infrastructure`)
2. **Description** — What does this repo do? (e.g., `React web application`, `Node.js API`)
3. **Branch workflow** — How does work flow into main?
   - **Option 1:** Trunk-based; PRs into `main`
   - **Option 2:** Uses `develop` for preproduction, merge to `main` for production
   - **Option 3:** Direct commits to `main` (no PR requirement)

Build a list of repos with their metadata and chosen workflows.

---

## Step 3: Collect Tools

Ask which tools the project uses (yes/no for each):

- AWS CLI
- Terraform
- Docker
- Kubernetes (kubectl)
- Any others specific to the project

---

## Step 4: Collect Architecture Components

Ask the user to describe the project architecture. Prompt: *"What are your main architecture components?"* (e.g., `API: Node.js Lambda`, `Frontend: React + Vite`, `Database: PostgreSQL on RDS`)

Collect a list of components; user can enter multiple or leave blank if not ready.

---

## Step 5: Generate Configuration Files

### Generate/Update REPOS.md

Use the collected repository metadata to generate REPOS.md:

```markdown
# Repository URLs

Reference clone URLs for [PROJECT_NAME] repositories.

- **[repo1]**: https://github.com/[GITHUB_ORG]/[repo1] — [description1]
- **[repo2]**: https://github.com/[GITHUB_ORG]/[repo2] — [description2]
...

## Branch and workflow

- **[repo1]**: [workflow text for repo1]
- **[repo2]**: [workflow text for repo2]
...

## Work directory and cloning for any fix

For any fix that needs one or more of these repos cloned locally: create a run directory under `work/<purpose>-<date>/`, look up this file for clone URLs, and clone only the repos you need. See **[runbooks/general-fix.md](./runbooks/general-fix.md)** for the full pattern.

---

## Clone examples

\`\`\`bash
git clone https://github.com/[GITHUB_ORG]/[repo1].git
git clone https://github.com/[GITHUB_ORG]/[repo2].git
\`\`\`
```

### Update TOOLS.md

If tools were selected, add a tools table to TOOLS.md under the "## Tools" section. Example:

```markdown
| Tool | Purpose |
|------|---------|
| **AWS CLI** | SSO login, Lambda, API Gateway, DynamoDB, etc. |
| **Terraform** | Infrastructure as code, IaC deployments. |
| **Docker** | Containerization and local services. |
| **kubectl** | Kubernetes cluster management. |
```

### Update CONTEXT.md

Add an "## Project Components" section to CONTEXT.md with the collected architecture components:

```markdown
## Project Components

- **[component1]**
- **[component2]**
- **[component3]**
```

### Ensure work/ Directory Exists

Check that `work/` and `work/WORK-TO-PR.md` exist. If not, create them:
- `work/` directory
- `work/WORK-TO-PR.md` with a table showing work dir → PR mappings (empty to start)

---

## Step 6: Summary

Display a summary of what was configured:

```
✓ Project: [PROJECT_NAME]
✓ GitHub Org: [GITHUB_ORG]
✓ Repositories: [count] repos configured
✓ Tools: [list of tools]
✓ Architecture documented: [yes/no]

Files generated/updated:
  - REPOS.md
  - TOOLS.md
  - CONTEXT.md
  - work/WORK-TO-PR.md

Next steps:
  1. Clone baseline repos into human-read-only/:
     cd human-read-only/
     git clone https://github.com/[GITHUB_ORG]/[repo1].git
     git clone https://github.com/[GITHUB_ORG]/[repo2].git
     ...
  2. Review the generated files to ensure they're accurate
  3. Commit and push to your repository
```

---

## Notes

- All file generation must follow the format of existing files in the workspace.
- The user can leave fields blank if they're not ready to fill them in; use sensible defaults (e.g., "TBD" for architecture).
- Once this runbook completes, the workspace is ready for use with `general-fix` and other runbooks.

