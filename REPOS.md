# Repository URLs

Reference clone URLs for your repositories. Run `./init.sh` to configure these.

<!-- CUSTOMIZE: Add your repositories here -->
<!-- Example:
- **frontend**: https://github.com/your-org/frontend
- **backend**: https://github.com/your-org/backend
- **infrastructure**: https://github.com/your-org/infrastructure
-->

## Branch and workflow

<!-- CUSTOMIZE: Document your branch conventions per repo -->
<!-- Example:
- **frontend**: Uses **develop** as its persistent preproduction branch; merge to main for production.
- **backend**: Trunk-based development; work is done via PRs into main (no long-lived develop branch).
- **infrastructure**: Trunk-based; PRs run `terraform plan` only; merge to **main** to deploy.
- **scripts**: Commit straight to **main**; no PR requirement.
-->

## Work directory and cloning for any fix

For any fix that needs one or more of these repos cloned locally: create a run directory under `work/<purpose>-<date>/`, look up this file for clone URLs, and clone only the repos you need. See **[runbooks/general-fix.md](./runbooks/general-fix.md)** for the full pattern (create run dir → clone from REPOS.md → task work → back out).

---

## Clone examples

```bash
# Example clone commands (customize for your repos)
# git clone https://github.com/your-org/frontend.git
# git clone https://github.com/your-org/backend.git
# git clone https://github.com/your-org/infrastructure.git
```
