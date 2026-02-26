# REPOS.md

## Repository List

### cus-ebs-ai-env-init
- **Purpose:** Environmental initialization for Customer EBS AI projects
- **Key files:**
	- `bootstrap/` (Terraform bootstrap, Makefile)
	- `terraform/` (Terraform config)
	- `README.md`

### cus-ebs-ai-unbilled-api
- **Purpose:** API for unbilled
- **Key files:**
	- `README.md`

### cus-ebs-ai-unbilled-backend
- **Purpose:** Backend for unbilled
- **Key files:**
	- `README.md`

### cus-ebs-ai-unbilled-frontend
- **Purpose:** Web app for unbilled
- **Key files:**
	- `src/` (React/TypeScript source)
	- `public/` (static assets)
	- `package.json`, `tsconfig.json`
	- `README.md`

## Branch and workflow

All repositories use **trunk-based development**:
- PRs are created against `main` branch
- **cus-ebs-ai-env-init**: Minimum 2 reviews required
- **cus-ebs-ai-unbilled-frontend**: Minimum 1 review required
- **cus-ebs-ai-unbilled-backend**: Minimum 1 review required
- **cus-ebs-ai-unbilled-api**: Minimum 1 review required
- Branch protection enabled on `main`
- Delete branch on merge enabled

## Work directory and cloning for any fix

For any fix that needs one or more of these repos cloned locally: create a run directory under `work/<purpose>-<date>/`, look up this file for clone URLs, and clone only the repos you need. See **[runbooks/general-fix.md](./runbooks/general-fix.md)** for the full pattern (create run dir → clone from REPOS.md → task work → back out).
# Repository URLs

Reference clone URLs for **cus-ebs-ai-unbilled** project repositories.

## Repositories

- **cus-ebs-ai-env-init**: https://github.com/edfenergy/cus-ebs-ai-env-init.git — Environmental initialization and control plane setup (Terraform, GitHub repo management)
- **cus-ebs-ai-unbilled-frontend**: https://github.com/edfenergy/cus-ebs-ai-unbilled-frontend.git — Web application for unbilled (React + TypeScript + Material-UI)
- **cus-ebs-ai-unbilled-backend**: https://github.com/edfenergy/cus-ebs-ai-unbilled-backend.git — Backend for unbilled
- **cus-ebs-ai-unbilled-api**: https://github.com/edfenergy/cus-ebs-ai-unbilled-api.git — API for unbilled

## Branch and workflow

All repositories use **trunk-based development**:
- PRs are created against `main` branch
- **cus-ebs-ai-env-init**: Minimum 2 reviews required
- **cus-ebs-ai-unbilled-frontend**: Minimum 1 review required
- **cus-ebs-ai-unbilled-backend**: Minimum 1 review required
- **cus-ebs-ai-unbilled-api**: Minimum 1 review required
- Branch protection enabled on `main`
- Delete branch on merge enabled

## Work directory and cloning for any fix

For any fix that needs one or more of these repos cloned locally: create a run directory under `work/<purpose>-<date>/`, look up this file for clone URLs, and clone only the repos you need. See **[runbooks/general-fix.md](./runbooks/general-fix.md)** for the full pattern (create run dir → clone from REPOS.md → task work → back out).

---

## Upstream Modules (read-only reference, cloned to `edf-modules/`)

These are shared EDF Terraform modules consumed by the project repos. Cloned locally for inspection — **do not modify** unless coordinating with the platform team.

- **terraform-module-aws-github-action-control-plane-role**: git@github.com:edfenergy/terraform-module-aws-github-action-control-plane-role.git — Creates OIDC CI/CD roles in the control plane account (used in `cus-ebs-ai-env-init/terraform/control_plane.tf`)
- **terraform-module-aws-github-action-role**: git@github.com:edfenergy/terraform-module-aws-github-action-role.git — Creates target-account GitHub Actions roles (read-only + read-write) with Allow `*` / Deny guardrails (used in `cus-ebs-ai-env-init/terraform/accounts.tf`)
- **terraform-module-aws-github-oidc-role**: git@github.com:edfenergy/terraform-module-aws-github-oidc-role.git — Low-level OIDC role + trust policy; used by the control-plane-role module above

---

## Clone examples

```bash
# Clone all repositories
git clone git@github.com:edfenergy/cus-ebs-ai-env-init.git
git clone git@github.com:edfenergy/cus-ebs-ai-unbilled-frontend.git
git clone git@github.com:edfenergy/cus-ebs-ai-unbilled-backend.git
git clone git@github.com:edfenergy/cus-ebs-ai-unbilled-api.git
```
