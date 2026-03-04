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

### GitHub API access (no `gh` CLI — use `curl`)

- **PAT** is available as `$GITHUB_TOKEN` in the shell environment.
- **curl on this machine** requires `--ssl-no-revoke` (Windows Schannel revocation check fails against GitHub).
- **All runbooks that reference `gh` commands must use these `curl` equivalents instead.**

#### Common recipes

**Create a PR:**
```bash
curl -s --ssl-no-revoke --max-time 30 \
  -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/pulls" \
  -d '{"title":"PR title","head":"branch-name","base":"main","body":"Description"}' \
  | grep -E '"html_url"|"number"'
```

**View a PR (get state, head branch, etc.):**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/pulls/NUMBER"
```

**Merge a PR (squash):**
```bash
curl -s --ssl-no-revoke --max-time 30 \
  -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/pulls/NUMBER/merge" \
  -d '{"merge_method":"squash"}'
```

**List workflow runs for a branch:**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/actions/runs?branch=BRANCH&per_page=1"
```

**Get workflow run jobs:**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/actions/runs/RUN_ID/jobs"
```

**Get PR review comments:**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/pulls/NUMBER/comments"
```

**Get combined commit status (legacy statuses):**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/commits/SHA/status"
```

**Get check runs for a commit (GitHub Actions checks):**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/commits/SHA/check-runs"
```

**Get deployments for a SHA:**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/deployments?sha=SHA&per_page=5"
```

**Get deployment statuses:**
```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/deployments/DEPLOY_ID/statuses"
```

> **Tip:** For long responses, pipe output to a file in your work dir and use `read_file` to inspect: `> ./pr_response.json`

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
| GitHub PRs / API | `curl --ssl-no-revoke -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/...` |
| AWS account access | `export AWS_PROFILE=unbilled-sandbox` |
| Frontend dev server | `cd cus-ebs-ai-unbilled-frontend && npm start` |
| Terraform plan | `cd cus-ebs-ai-env-init/terraform && terraform plan` |
| List AWS Lambda functions | `aws lambda list-functions --profile unbilled-primary` |
