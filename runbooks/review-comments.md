# Runbook: Handle PR review comments

When the user says **"comments"** with a PR reference, or provides a PR review/changes URL, follow this runbook to triage and resolve review comments on a pull request.

**Prereq:** The PR branch should already be checked out in a `work/` directory. If not, set up per [general-fix.md](./general-fix.md).

---

## Step 1: Fetch review comments

Use the GitHub API (since `gh` CLI is not available — see [TOOLS.md](../TOOLS.md)):

```bash
curl -s --ssl-no-revoke --max-time 15 \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/pulls/PR_NUM/comments"
```

Parse each comment for: **ID**, **file:line**, **body** (the suggestion or concern), and **in_reply_to_id** (to identify threads vs replies).

---

## Step 2: Triage each comment

For every top-level review comment (not a reply), decide:

| Decision | Criteria | Action |
|----------|----------|--------|
| **Accept** | Comment identifies a real bug, inconsistency, security risk, or style violation worth fixing | Fix in code, reply explaining what was done |
| **Reject** | Comment is incorrect, not applicable, or would make things worse | Reply explaining **why** it's rejected |
| **Defer** | Valid but out of scope for this PR | Reply explaining it will be addressed in a follow-up |

Present the triage table to the user **before** making changes if there's any ambiguity. If all comments are clear-cut, proceed directly.

---

## Step 3: Implement fixes

- Make all accepted fixes in the working copy.
- Run formatters/linters as needed (e.g. `terraform fmt`).
- **Single commit** with a message summarising all changes:

```
fix: address PR review comments

- <summary of fix 1>
- <summary of fix 2>
- ...
```

- Push to the PR branch.

---

## Step 4: Reply to each comment thread

For **each** review comment, post a reply using the GitHub API:

```bash
curl -s --ssl-no-revoke --max-time 15 -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/OWNER/REPO/pulls/PR_NUM/comments" \
  -d '{"body":"<reply>","in_reply_to":<COMMENT_ID>}'
```

Reply format:
- **Accepted:** `**Accepted.** <what was done and commit ref>`
- **Rejected:** `**Rejected.** <why — be specific>`
- **Deferred:** `**Deferred.** <why and where it will be tracked>`

---

## Step 5: Resolve all addressed threads

Use the GraphQL API to resolve each thread:

1. **Get thread IDs:**

```bash
curl -s --ssl-no-revoke --max-time 15 -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/graphql" \
  -d '{"query":"query { repository(owner:\"OWNER\", name:\"REPO\") { pullRequest(number:PR_NUM) { reviewThreads(first:50) { nodes { id isResolved comments(first:1) { nodes { body } } } } } } }"}'
```

2. **Resolve each unresolved thread** (accepted or rejected — both get resolved; deferred stays open):

```bash
curl -s --ssl-no-revoke --max-time 10 -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/graphql" \
  -d '{"query":"mutation { resolveReviewThread(input: {threadId: \"THREAD_ID\"}) { thread { isResolved } } }"}'
```

3. **Verify** all expected threads are resolved:

```bash
# Should show N/N resolved
```

---

## Step 6: Report

Present a summary table to the user:

| # | File | Comment | Decision | Resolution |
|---|------|---------|----------|------------|
| 1 | `file.tf:30` | Description | ✅ Accepted | What was fixed |
| 2 | `file.tf:85` | Description | ❌ Rejected | Why |
| 3 | `file.tf:120` | Description | ⏳ Deferred | Where tracked |

---

## Notes

- **Do not skip the reply step.** Every comment must get a reply before being resolved — silent resolution is bad practice.
- **Rejected comments still get resolved** — the reply explains why, and resolution indicates the thread has been addressed (not necessarily agreed with).
- **Deferred comments stay unresolved** as a reminder they need follow-up.
- If the PR has no review comments, report that to the user.
