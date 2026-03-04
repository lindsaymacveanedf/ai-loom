# Runbook: Manage a PR to green

When the user says **"manage"** with a **PR link or reference**, follow this runbook to shepherd the PR through all checks, resolve all review comments, and confirm successful deployment. Iterate in a loop until everything is green.

**Prereqs:** [CONTEXT.md](../CONTEXT.md), [REPOS.md](../REPOS.md), [TOOLS.md](../TOOLS.md).

---

## Trigger pattern

Typical form: **`manage <pr-link>`** or **`manage PR #N`**

Examples:
- `manage https://github.com/edfenergy/cus-ebs-ai-unbilled-backend/pull/14`
- `manage PR #14 backend`

Parse from the user message:
- **Owner / Repo** — from the URL or infer from repo name + [REPOS.md](../REPOS.md).
- **PR number** — from the URL or `#N`.

If ambiguous, ask once, then proceed.

---

## Overview

The manage loop has three convergence goals — iterate until **all three** are met:

| # | Goal | How to check | How to fix |
|---|------|--------------|------------|
| 1 | **All CI checks pass** | Combined commit status + check runs API | Debug runbook or direct fix, push, re-poll |
| 2 | **All review comments resolved** | GraphQL reviewThreads query | Comments runbook |
| 3 | **Deployment succeeds** | Deployment status API or workflow run status | Debug runbook, fix, push, re-poll |

**Ignore:** Review approval status — the user will handle human review once everything is green.

---

## Steps

### 1. Set up workspace (if not already present)

If the PR branch is not already checked out in a `work/` directory, set up per [general-fix.md](./general-fix.md):

```bash
DATE=$(date +%Y-%m-%d)
WORK_ROOT="work/manage-pr${PR_NUM}-${DATE}"
mkdir -p "$WORK_ROOT"
cd "$WORK_ROOT"
git clone <clone-url-from-REPOS.md>
cd <repo>
git checkout <pr-branch>
```

If a work dir already exists for this PR (e.g. from a previous `implement` run), reuse it — just `git pull` to get latest.

### 2. Get PR metadata

Fetch PR details to get the head SHA and branch name:

```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/OWNER/REPO/pulls/PR_NUM" \
  > ./pr_details.json
```

Extract:
- `head.sha` — the commit to check status against.
- `head.ref` — the branch name.

### 3. Enter the manage loop

Run a **poll loop** in the terminal that checks all three goals. The loop sleeps between iterations to avoid rate-limiting. Exit when all goals are met or when a failure needs manual intervention.

#### 3.1 Poll script

Run this as a background terminal process. It polls every **30 seconds** and writes status to a file you can inspect:

```bash
OWNER="<owner>"
REPO="<repo>"
PR_NUM=<number>
STATUS_FILE="./manage_status.txt"

while true; do
  echo "=== $(date) ===" > "$STATUS_FILE"

  # --- Goal 1: CI checks ---
  HEAD_SHA=$(curl -s --ssl-no-revoke --max-time 15 \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUM" \
    | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)

  # Combined status (legacy statuses)
  COMBINED=$(curl -s --ssl-no-revoke --max-time 15 \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$OWNER/$REPO/commits/$HEAD_SHA/status" \
    | grep -o '"state":"[^"]*"' | head -1 | cut -d'"' -f4)

  # Check runs (GitHub Actions, etc.)
  CHECKS_JSON=$(curl -s --ssl-no-revoke --max-time 15 \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$OWNER/$REPO/commits/$HEAD_SHA/check-runs")

  TOTAL_CHECKS=$(echo "$CHECKS_JSON" | grep -o '"total_count":[0-9]*' | cut -d: -f2)
  FAILED_CHECKS=$(echo "$CHECKS_JSON" | grep -o '"conclusion":"failure"' | wc -l)
  PENDING_CHECKS=$(echo "$CHECKS_JSON" | grep -o '"status":"in_progress"\|"status":"queued"' | wc -l)
  SUCCESS_CHECKS=$(echo "$CHECKS_JSON" | grep -o '"conclusion":"success"' | wc -l)

  echo "CI: combined=$COMBINED total=$TOTAL_CHECKS success=$SUCCESS_CHECKS failed=$FAILED_CHECKS pending=$PENDING_CHECKS" >> "$STATUS_FILE"

  # --- Goal 2: Review comments ---
  THREADS_JSON=$(curl -s --ssl-no-revoke --max-time 15 -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/graphql" \
    -d "{\"query\":\"query { repository(owner:\\\"$OWNER\\\", name:\\\"$REPO\\\") { pullRequest(number:$PR_NUM) { reviewThreads(first:100) { totalCount nodes { isResolved } } } } }\"}")

  TOTAL_THREADS=$(echo "$THREADS_JSON" | grep -o '"totalCount":[0-9]*' | head -1 | cut -d: -f2)
  UNRESOLVED=$(echo "$THREADS_JSON" | grep -o '"isResolved":false' | wc -l)
  echo "Comments: total=$TOTAL_THREADS unresolved=$UNRESOLVED" >> "$STATUS_FILE"

  # --- Goal 3: Deployment ---
  DEPLOY_JSON=$(curl -s --ssl-no-revoke --max-time 15 \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$OWNER/$REPO/deployments?sha=$HEAD_SHA&per_page=5")

  # If deployments exist, check latest status
  HAS_DEPLOYMENTS=$(echo "$DEPLOY_JSON" | grep -c '"id"')
  if [ "$HAS_DEPLOYMENTS" -gt 0 ]; then
    DEPLOY_ID=$(echo "$DEPLOY_JSON" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
    DEPLOY_STATUS=$(curl -s --ssl-no-revoke --max-time 15 \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$OWNER/$REPO/deployments/$DEPLOY_ID/statuses" \
      | grep -o '"state":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Deployment: id=$DEPLOY_ID status=$DEPLOY_STATUS" >> "$STATUS_FILE"
  else
    echo "Deployment: none found (checking workflow runs instead)" >> "$STATUS_FILE"
    # Fall back to workflow run status for the branch
    RUN_JSON=$(curl -s --ssl-no-revoke --max-time 15 \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$OWNER/$REPO/actions/runs?branch=$(curl -s --ssl-no-revoke --max-time 10 \
        -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUM" \
        | grep -o '"ref":"[^"]*"' | head -1 | cut -d'"' -f4)&per_page=1")
    RUN_STATUS=$(echo "$RUN_JSON" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    RUN_CONCLUSION=$(echo "$RUN_JSON" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)
    RUN_URL=$(echo "$RUN_JSON" | grep -o '"html_url":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Workflow: status=$RUN_STATUS conclusion=$RUN_CONCLUSION url=$RUN_URL" >> "$STATUS_FILE"
  fi

  # --- Summary ---
  echo "" >> "$STATUS_FILE"
  ALL_GREEN="true"

  if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo "❌ CI: $FAILED_CHECKS check(s) failed" >> "$STATUS_FILE"
    ALL_GREEN="false"
  elif [ "$PENDING_CHECKS" -gt 0 ]; then
    echo "⏳ CI: $PENDING_CHECKS check(s) still running" >> "$STATUS_FILE"
    ALL_GREEN="false"
  else
    echo "✅ CI: all checks passed" >> "$STATUS_FILE"
  fi

  if [ "$UNRESOLVED" -gt 0 ]; then
    echo "❌ Comments: $UNRESOLVED unresolved thread(s)" >> "$STATUS_FILE"
    ALL_GREEN="false"
  else
    echo "✅ Comments: all resolved" >> "$STATUS_FILE"
  fi

  cat "$STATUS_FILE"

  if [ "$ALL_GREEN" = "true" ]; then
    echo ""
    echo "🎉 ALL GREEN — PR is ready for human review"
    break
  fi

  echo ""
  echo "Sleeping 30s before next poll..."
  sleep 30
done
```

Start this as a **background process** and check its output periodically with `get_terminal_output`.

### 4. React to failures

When the poll loop or a manual check reveals a problem, handle it:

#### 4.1 CI check failure

1. Identify which check(s) failed — get the check run details:
   ```bash
   curl -s --ssl-no-revoke --max-time 15 \
     -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     "https://api.github.com/repos/OWNER/REPO/commits/HEAD_SHA/check-runs" \
     > ./check_runs.json
   ```
2. For each failed check, get the workflow run jobs and logs per the [debug runbook](./debug.md) §1.1.
3. Fix the issue in the local clone, commit, and push. The push triggers a new run — the poll loop will pick up the new SHA automatically.

#### 4.2 Unresolved review comments

1. Follow the [review-comments runbook](./review-comments.md) end-to-end:
   - Fetch comments → triage → fix → reply → resolve threads.
2. Push any code fixes. The poll loop will re-check threads on the next iteration.

#### 4.3 Deployment failure

1. Get deployment status details or workflow run logs.
2. Follow the [debug runbook](./debug.md) to diagnose and fix.
3. Push the fix. Re-poll.

#### 4.4 Checks still pending (stuck)

If checks remain `in_progress` or `queued` for more than **10 minutes** with no progress:
1. Check if the workflow run is stuck (e.g. waiting for approval, runner unavailable).
2. Report to the user — some situations (e.g. environment protection rules requiring manual approval) cannot be resolved by the agent.

### 5. Convergence

The loop exits when:
- **All CI checks** have conclusion `success` (or `neutral`/`skipped`).
- **All review threads** are resolved (unresolved count = 0).
- **Deployment** status is `success` (or no deployments exist and the latest workflow run succeeded).

### 6. Final report

Once all green, present a summary to the user:

```
✅ PR #N is ready for human review

| Goal | Status |
|------|--------|
| CI checks | ✅ N/N passed |
| Review comments | ✅ N/N resolved |
| Deployment | ✅ Succeeded |

🔗 [PR #N](https://github.com/OWNER/REPO/pull/N)

Iterations: X polls over ~Ym
Fixes applied: <list of commits pushed, if any>

Next step: Human review and merge.
```

---

## Key API endpoints reference

| Purpose | Endpoint |
|---------|----------|
| PR details (head SHA, branch) | `GET /repos/OWNER/REPO/pulls/NUMBER` |
| Combined commit status | `GET /repos/OWNER/REPO/commits/SHA/status` |
| Check runs for a commit | `GET /repos/OWNER/REPO/commits/SHA/check-runs` |
| Check run details (logs) | `GET /repos/OWNER/REPO/check-runs/CHECK_RUN_ID` |
| Workflow runs for branch | `GET /repos/OWNER/REPO/actions/runs?branch=BRANCH` |
| Workflow run jobs | `GET /repos/OWNER/REPO/actions/runs/RUN_ID/jobs` |
| Deployments for SHA | `GET /repos/OWNER/REPO/deployments?sha=SHA` |
| Deployment statuses | `GET /repos/OWNER/REPO/deployments/DEPLOY_ID/statuses` |
| Review threads (GraphQL) | `POST /graphql` — `reviewThreads` query |
| Resolve thread (GraphQL) | `POST /graphql` — `resolveReviewThread` mutation |

All calls require `Authorization: token $GITHUB_TOKEN` and `--ssl-no-revoke`. See [TOOLS.md](../TOOLS.md).

---

## Difference from other runbooks

| Runbook | When to use |
|---------|-------------|
| **manage** (this) | PR exists. Shepherd it to all-green: iterate on CI failures, review comments, deployment issues until everything passes. |
| **debug** | Investigate a specific failure (pipeline run, endpoint, local app). One-shot diagnosis and fix. |
| **evaluate** | Assess whether a PR is safe to merge (risk review). Does not iterate on failures. |
| **comments** | Handle review comments only. Called *by* manage as a sub-procedure. |

---

## Common mistakes to avoid

1. **Polling too fast** — 30 seconds minimum between polls. GitHub API rate limit is 5,000 requests/hour; each poll cycle uses ~5 requests.
2. **Ignoring the head SHA change** — after pushing a fix, the PR's head SHA changes. The poll script re-fetches it each iteration.
3. **Waiting for review approval** — this runbook explicitly ignores review approval status. The user handles that.
4. **Not reusing existing work dirs** — if `work/<purpose>-<date>/<repo>-<pr#>/` already exists, reuse it instead of cloning again.
5. **Trying `gh` CLI** — not installed. Use `curl` per [TOOLS.md](../TOOLS.md).
