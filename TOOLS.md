# Tools available to agents

This file lists the CLI tools and commands agents can use when working in this workspace. Use it when you need to run builds, deploy, authenticate, or work with a specific component.
**Context:** For when to use which repo and workflow, see **[CONTEXT.md](./CONTEXT.md)**. For clone URLs and branch conventions, see **[REPOS.md](./REPOS.md)**.

---
## CLI Tools & Common Commands

### cus-ebs-ai-env-init
 - **Terraform:** Used for infrastructure provisioning
	 - `make plan` (in `bootstrap/`): Plan Terraform changes
	 - `make apply` (in `bootstrap/`): Apply Terraform changes
 - **Makefile:** Preconfigured commands for Terraform

### cus-ebs-ai-unbilled-frontend
 - **npm/yarn:** JavaScript package management
	 - `npm install`: Install dependencies
	 - `npm start`: Start development server (uses `env-cmd` and `react-scripts`)
	 - `npm run build`: Build production assets
 - **TypeScript:** Static type checking

### General
 - **AWS CLI:** Required for platform admin access (env-init)
# Tools available to agents

This file lists the CLI tools and commands agents can use when working in this workspace. Use it when you need to run builds, deploy, authenticate, or work with a specific component.

**Context:** For when to use which repo and workflow, see **[CONTEXT.md](./CONTEXT.md)**. For clone URLs and branch conventions, see **[REPOS.md](./REPOS.md)**.

---

## Agent terminal rules

- **Long output → pipe to file in the work dir.** If a command may produce long output (AWS logs, large API responses, `terraform plan`, etc.), pipe to a temp file **inside the current work directory** and read it with `read_file`, rather than dumping to the terminal. The terminal requires manual scrolling which blocks the agent. **Never use `~/tmp`, `$HOME/tmp`, or `/tmp`** — keep everything under `work/` so cleanup is automatic when the work dir is deleted.
  ```bash
  # Do this (from inside your work/<purpose>-<date>/ dir):
  aws logs filter-log-events ... > ./logs.txt 2>&1
  curl -s ... -o ./api_response.json
  # Then inspect with read_file or grep, not by scrolling the terminal.
  ```
- **Pagers:** Always disable pagers — use `git --no-pager`, `| cat`, or `AWS_PAGER=""`.
- **Targeted output:** Prefer `grep`, `head`, `tail`, `jq` filters over dumping everything.

---

## Tools assumed available

| Tool | Typical use |
|------|-------------|
| **Git** | Clone, branch, commit, push; runbooks assume `work/` and multi-repo workflows. |
| **Node / npm** | JavaScript/TypeScript projects (install, build, test, lint). |
| **AWS CLI** | Authentication via aws-toolbox.exe, managing AWS resources. |
| **Terraform** | Infrastructure as code (used in cus-ebs-ai-env-init). |

### NOT available

| Tool | Alternative |
|------|-------------|
| **gh** (GitHub CLI) | **Not installed.** Use the GitHub REST API via `curl` with `$GITHUB_TOKEN`. See notes below. |

### GitHub API access

- **PAT** is available as `$GITHUB_TOKEN` in the shell environment.
- **curl on this machine** requires `--ssl-no-revoke` (Windows Schannel revocation check fails against GitHub).
- **Pattern:**
  ```bash
  curl -s --ssl-no-revoke --max-time 15 \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/OWNER/REPO/actions/runs/RUN_ID/jobs"
  ```

---

## Authentication

### AWS CLI

The unbilled project uses AWS profiles configured with `aws-toolbox.exe` for Azure AD SSO authentication:

**Available AWS Profiles:**
- `unbilled-primary` — Primary AWS account (248108944979)
- `unbilled-secondary` — Secondary AWS account (450312424446)
- `unbilled-sandbox` — Sandbox AWS account (382535610125)

**Usage:**
```bash
# Set the AWS profile for your session
export AWS_PROFILE=unbilled-sandbox

# Or use with specific commands
aws s3 ls --profile unbilled-sandbox
aws lambda list-functions --profile unbilled-primary
```

**Note:** Authentication is handled automatically by `aws-toolbox.exe` via Azure AD integration.

---

## Common commands (per component)

Use these when working inside a cloned repo or the corresponding directory in the workspace.

### Frontend (React + TypeScript)

```bash
cd cus-ebs-ai-unbilled-frontend
npm install
npm start              # Dev server
npm run build          # Production build
npm test              # Run tests
npm run lint          # Run linter
```

### Backend

```bash
cd cus-ebs-ai-unbilled-backend
# Commands TBD - repository is currently empty
```

### API

```bash
cd cus-ebs-ai-unbilled-api
# Commands TBD - repository is currently empty
```

### Infrastructure (Terraform)

```bash
cd cus-ebs-ai-env-init/terraform
terraform init
terraform plan
terraform apply
```

---

## Quick reference

| Need | Tool / command |
|------|----------------|
| GitHub PRs / API | `gh pr view`, `gh pr create`, `gh api`, `gh api graphql` |
| AWS account access | `export AWS_PROFILE=unbilled-sandbox` |
| Frontend dev server | `cd cus-ebs-ai-unbilled-frontend && npm start` |
| Terraform plan | `cd cus-ebs-ai-env-init/terraform && terraform plan` |
| List AWS Lambda functions | `aws lambda list-functions --profile unbilled-primary` |
