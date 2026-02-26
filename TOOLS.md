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

## Tools assumed available

| Tool | Typical use |
|------|-------------|
| **Git** | Clone, branch, commit, push; runbooks assume `work/` and multi-repo workflows. |
| **gh** (GitHub CLI) | PRs, workflows, API/GraphQL. |
| **Node / npm** | JavaScript/TypeScript projects (install, build, test, lint). |
| **AWS CLI** | Authentication via aws-toolbox.exe, managing AWS resources. |
| **Terraform** | Infrastructure as code (used in cus-ebs-ai-env-init). |

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
