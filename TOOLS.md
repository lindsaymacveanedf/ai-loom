# Tools available to agents

This file lists the CLI tools and commands agents can use when working in this workspace. Use it when you need to run builds, deploy, authenticate, or work with a specific component.

**Context:** For when to use which repo and workflow, see **[CONTEXT.md](./CONTEXT.md)**. For clone URLs and branch conventions, see **[REPOS.md](./REPOS.md)**.

---

## Tools assumed available

| Tool | Typical use |
|------|-------------|
| **Git** | Clone, branch, commit, push; runbooks assume `work/` and multi-repo workflows. |
| **gh** (GitHub CLI) | PRs, workflows, API/GraphQL. |
| **Node / npm / yarn** | JavaScript/TypeScript projects (install, build, test, lint). |

<!-- CUSTOMIZE: Add your project-specific tools -->
<!-- Example:
| **AWS CLI** | SSO login, Lambda, API Gateway, DynamoDB, etc. |
| **Terraform** | Infrastructure as code. |
| **Docker** | Containerization and local services. |
| **kubectl** | Kubernetes cluster management. |
-->

---

## Authentication

<!-- CUSTOMIZE: Document your authentication methods -->
<!-- Example:
### AWS SSO
```bash
aws sso login --profile your-profile
export AWS_PROFILE=your-profile
```

### GCP
```bash
gcloud auth login
gcloud config set project your-project
```
-->

---

## Common commands (per component)

Use these when working inside a cloned repo or the corresponding directory in the workspace.

<!-- CUSTOMIZE: Add commands for each of your components -->
<!-- Example:

### Frontend (React web app)

```bash
cd frontend
yarn install && yarn dev  # Dev server at localhost:3000
yarn build && yarn test && yarn lint
```

### Backend (Node.js API)

```bash
cd backend
npm install
npm run dev      # Local dev server
npm run test     # Run tests
npm run deploy   # Deploy to staging
```

### Infrastructure (Terraform)

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```
-->

---

## Quick reference

| Need | Tool / command |
|------|----------------|
| GitHub PRs / API | `gh pr view`, `gh pr create`, `gh api`, `gh api graphql` |
<!-- CUSTOMIZE: Add your quick reference commands -->
