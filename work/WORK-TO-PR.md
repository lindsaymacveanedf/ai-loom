# Work directories → PRs

Maps each run directory under `work/` to its open/merged PRs for **trunk-style repos**. See [runbooks/general-fix.md](../runbooks/general-fix.md) for the rename convention.

| Run directory | Repo clone(s) | PR(s) | Notes |
|---------------|---------------|-------|--------|
| `debug-backend-pr13-2026-02-27` | `cus-ebs-ai-env-init` | [PR #18](https://github.com/edfenergy/cus-ebs-ai-env-init/pull/18) | Route53 subdomain zones + NS delegation. Requires 2 reviews. |
| `debug-backend-pr13-2026-02-27` | `cus-ebs-ai-unbilled-backend` | [PR #13](https://github.com/edfenergy/cus-ebs-ai-unbilled-backend/pull/13) | Simplified to data lookup. Depends on env-init PR #18. |

**Convention:** When you open a PR for a trunk-style repo, rename that clone dir to `<repo>-<pr#>` (e.g. `backend-142`). Update this file when adding or removing run dirs.
