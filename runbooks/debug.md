# Runbook: Debug (pipeline URL, PR link, endpoint/failure, or local app)

When the user says **"debug"** with one of the following, follow this runbook:

- **Pipeline run URL** (e.g. a GitHub Actions run link): inspect with `gh`, then handle the failure.
- **PR link or reference** (e.g. `https://github.com/OWNER/REPO/pull/174` or "PR 174"): resolve to the **latest workflow run** for that PR (the run they likely saw fail), then proceed as **Pipeline run URL**.
- **Endpoint and/or failure message** (e.g. "getusers {no email}"): ask for timeframe and environment, then use logs and code to form a theory and possible fix.
- **Local app** ("debug frontend", "debug backend", "debug mobile"): populate workspace, spin up the app locally, wait for the user to reproduce or explain, then debug and plan a fix.

---

## Step 0: Determine mode

| User input | Mode | Go to |
|------------|------|--------|
| A URL that looks like a GitHub Actions workflow run | **Pipeline run URL** | [Section 1](#1-mode-pipeline-run-url) |
| A PR URL or reference (e.g. "PR 174", "PR #174") | **PR link** | [Section 1](#1-mode-pipeline-run-url) — first [resolve PR to latest run](#10-resolve-pr-link-to-latest-run) |
| An endpoint name and/or failure message | **Endpoint/failure** | [Section 2](#2-mode-endpoint--failure-message) |
| "debug frontend", "debug backend", "debug mobile", etc. | **Local app** | [Section 3](#3-mode-local-app) |

If unclear (none of the above), ask the user: a pipeline run link, a PR link, an endpoint/error to investigate, or a local app to run and debug.

---

## 1. Mode: Pipeline run URL (or PR link resolved to a run)

Use **gh** to inspect the run, then handle the failure type.

### 1.0 Resolve PR link to latest run

When the user provides a **PR URL** or a **PR reference** (e.g. "debug PR 174"):

1. Parse **owner**, **repo**, and **PR number** from the URL or reference.
2. Get the PR's head branch: `gh pr view <N> --repo <OWNER>/<REPO> --json headRefName -q .headRefName`.
3. Get the **latest workflow run** for that branch: `gh run list --repo <OWNER>/<REPO> --branch <headRefName> --limit 1`.
4. From the list output, take the **run database id** or URL, then proceed to [1.1](#11-inspect-the-run-with-gh).

Do **not** ask the user to paste a run URL; they mean "debug the last run for this PR."

### 1.1 Inspect the run with gh

- Parse the URL: `https://github.com/OWNER/REPO/actions/runs/RUN_ID` → owner, repo, run id.
- Run: `gh run view RUN_ID --repo OWNER/REPO` (and optionally `--log` or `gh api repos/OWNER/REPO/actions/runs/RUN_ID/jobs`) to see status, conclusion, and job details.
- Identify the **failure type** from the run/job output or logs.

### 1.2 If it's a state lock (Terraform/dynamodb lock)

- **Check** whether another job or process is still running. If another run is legitimately holding the lock, wait or coordinate with the user before removing it.
- **Remove the lock** using appropriate tooling for your infrastructure (e.g. Terraform force-unlock, DynamoDB delete).
- **Retrigger** the workflow. Tell the user what you did.

### 1.3 If it's a test failure

- Clone the repo into a run dir per [general-fix.md](./general-fix.md) if not already present.
- Reproduce or infer the failure from the run logs; locate the failing test and the cause in the codebase.
- **Create a fix**, **explain** it to the user (what broke and why the fix is correct), and **ask for confirmation** before pushing.
- Once confirmed, push per [push-changes.md](./push-changes.md).

### 1.4 If it's something else

- **Best-effort**: from the run logs and repo context, form a theory, implement a fix (or document steps for the user), and push using the workflow for that repo.

---

## 2. Mode: Endpoint / failure message

User provides an **endpoint** and/or **failure message** (e.g. getusers, getusers {no email}). You need timeframe and environment to find logs.

### 2.1 Ask the user for context

- **Timeframe** of the error (e.g. "5 mins ago", "between 14:00 and 14:05 UTC").
- **Environment** (e.g. "staging", "production", "local").

### 2.2 Map endpoint to service and fetch logs

- From [REPOS.md](../REPOS.md) and the codebase, **map the endpoint** to the **service** (Lambda, container, etc.) that serves it.
- Use appropriate logging tools (CloudWatch, kubectl logs, etc.) for that service in the **timeframe** the user gave. Inspect logs for errors, status codes, and the failure message.

### 2.3 Form theory and possible fix

- Look at the **code** for that endpoint (handler, validation, response shaping).
- Form a **theory** of what happened.
- Propose a **possible fix**. Present the theory and fix to the user; implement and push (per [push-changes.md](./push-changes.md)) only after they confirm.

---

## 3. Mode: Local app

When the user says **"debug frontend"**, **"debug backend"**, **"debug mobile"**, or similar, set up the workspace, run the app locally, and work with them to reproduce and fix the issue.

### 3.1 Populate workspace (general-fix)

Follow **[general-fix.md](./general-fix.md)** Steps 1–2:

1. Create a **run directory** under `work/` named by purpose and date, e.g. `work/debug-frontend-2026-02-04`.
2. From **[REPOS.md](../REPOS.md)** clone **only the repos you need** into that directory.

Paths from workspace root: `work/<purpose>-<date>/<repo-name>/`.

### 3.2 Spin up the app locally

Run the app so the user can reproduce the issue. Use **[TOOLS.md](../TOOLS.md)** for exact commands.

- If the app fails to start (e.g. missing config, wrong branch, or syntax error), fix that first so the user has a running app.
- Tell the user the URL or how to open the app.

### 3.3 Wait for the user

- Invite the user to **try the flow** or **describe the problem** (what they did, what they expected, what they see).
- Ask for **errors** (browser console, terminal, network tab, or copy/paste of messages) if they have any.
- Do not assume the root cause; let them reproduce or explain before diving into code.

### 3.4 Debug and plan

- **Reproduce** the issue if possible (same steps, same env).
- **Inspect** logs, network requests, and relevant code.
- **Interview** the user if something is unclear.
- **Propose a plan** to resolve, then implement or guide the user step by step.
- If the issue is **backend/API**, use logs or the relevant repo to investigate and fix.

When done, **back out** per general-fix Step 4 (delete the work directory for this run), or leave it in place if the user will continue debugging.

---

## Quick reference

| Mode | Trigger | Main actions |
|------|---------|--------------|
| **Pipeline run URL** | User gives a GitHub Actions run URL | Use `gh` to inspect; handle state lock, test failure, or other issues; fix and push per repo. |
| **PR link** | User gives a PR URL or "PR #N" | Resolve to latest run for that PR; then same as Pipeline run URL. Do not ask for a run URL. |
| **Endpoint/failure** | User gives endpoint and/or failure message | Ask timeframe + environment; map endpoint to service; fetch logs; inspect code; theory + possible fix; implement after user confirms. |
| **Local app** | "debug frontend", "debug backend", etc. | general-fix → clone repos; start app (TOOLS.md); wait for user to reproduce/explain; debug, plan, resolve. |
