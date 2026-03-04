# Runbook: End Session

When the user says **"end"**, follow this runbook to wrap up the session cleanly.

---

## Step 1: Review the conversation for loose ends

Before cleaning up, scan the conversation for anything left undone:

- **Uncommitted or unpushed changes** in any repo (work dirs, meta repo, human-read-only)
- **Unanswered questions** the user asked that weren't resolved
- **Spec decisions marked TBD** that were never finalised
- **Work-dir artefacts** that should have been persisted (e.g. a spec not yet copied to `specifications/`)
- **WORK-TO-PR.md entries** that need adding or updating
- **Meta code changes** (CONTEXT.md, runbooks, TOOLS.md, etc.) that were discussed but not committed

If anything is outstanding, **tell the user what's unfinished** before proceeding. Let them decide whether to address it now or leave it.

---

## Step 2: Delete work directories

Delete all directories under `work/` (but keep `work/WORK-TO-PR.md`):

```bash
# Delete everything in work/ except WORK-TO-PR.md
find work/ -mindepth 1 -maxdepth 1 ! -name 'WORK-TO-PR.md' -exec rm -rf {} +
```

---

## Step 3: Refresh human-read-only/

Pull latest on all repos in `human-read-only/`:

```bash
for repo in human-read-only/*/; do
  echo "--- $(basename $repo) ---"
  cd "$repo" && git pull --ff-only && cd ../..
done
```

---

## Step 4: Respond

Respond with: **"you can close this chat"**

Nothing else — no summary, no recap. Just that message.
