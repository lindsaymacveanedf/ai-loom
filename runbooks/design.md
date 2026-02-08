# Runbook: Design (specs and implementation plan)

When the user says **"design"** (or "design specs", "design a feature", "design a fix"), follow this runbook to **interview** them, produce a **written plan/spec** for a feature or complex fix, and optionally **implement and open a PR**. The flow usually starts with a business or user-experience challenge and may span multiple codebases.

---

## Overview

1. **Read [CONTEXT.md](../CONTEXT.md)** (workspace root), as for any start.
2. **Interview:** Ask questions in rounds until the user confirms everything is covered. Clarify problem, scope, constraints; identify client(s), backend, and downstream changes.
3. **Write the spec:** Produce a short written plan (problem, scope, components, implementation order, acceptance criteria). Save it so you can use it when implementing.
4. **Optional — Implement and PR:** If the user wants to implement now, follow [general-fix.md](./general-fix.md) to set up a work dir and clone the repos you need, implement per the spec, then follow [push-changes.md](./push-changes.md) to open a PR (or push direct per repo convention).

---

## Step 1: Read context

Read **[CONTEXT.md](../CONTEXT.md)** so you have the map: repos in [REPOS.md](../REPOS.md), architecture, and conventions. You will refer to REPOS.md when deciding which repos to clone for implementation.

---

## Step 2: Interview

**Establish the design subject:**

- **If the conversation already established a topic** (e.g. the user said "design" right after discussing a specific feature or fix): treat that as the design subject. Proceed with topic-specific questions or, if enough is already clear, skip to the written spec (Step 3). Do not ask generic "what are we designing?" questions.
- **Only when there is no prior conversation** establishing what to design: ask the general question batch below.

**Goal:** Understand the business or UX challenge, which surfaces to change first, whether backend/API changes are needed, and whether other clients are affected.

**Do not one-shot the interview.** Keep asking questions in rounds until the user confirms they are happy that everything is covered.

1. **First round:** Ask a batch of questions (use the question areas below when no prior context; otherwise ask only what's missing). Let the user answer in whatever order they prefer.
2. **After each round:** Ask explicitly: *"Anything else you want to add or clarify, or are we good to move on to the written spec?"* (or similar). If they add more, ask follow-up questions as needed, then ask again until they say they are done.
3. **Only when the user confirms** that coverage is complete → proceed to Step 3 (write the spec).

**Question areas** (use as a guide; ask in batches and follow up as needed):

- **Problem:** What is the business or user-experience challenge? Who is affected?
- **Primary surface:** Which client/component do we start with?
- **Backend/API:** Does this require new or changed endpoints, services, or data?
- **Other clients:** Will another client need to change as a result?
- **Constraints:** Compliance, performance, existing patterns, or "must not break X"?
- **Out of scope (for now):** What are we explicitly not doing in this iteration?

Use answers to decide: repos involved, order of work, and where to document the spec.

---

## Step 3: Write the spec

Produce a **short written plan** that you (and the user) can follow during implementation. Include:

- **Problem / goal:** One or two sentences.
- **Scope:** In scope and out of scope for this iteration.
- **Components and order:** e.g. "1) API: new endpoint X. 2) Frontend: screen Y. 3) Mobile: show Z when …"
- **Key decisions:** e.g. "Reuse existing pattern for auth; new database table for …"
- **Acceptance criteria:** How we know we're done (user-facing or testable).

**Where to save the spec:**

- If you are **only designing** (no implementation yet): create a run directory for this session, e.g. `work/design-YYYY-MM-DD/`, and write the spec there, e.g. `work/design-YYYY-MM-DD/spec.md`. Tell the user the path.
- If you are **designing then implementing in the same session**: use the same run dir you will create for implementation, e.g. `work/design-<short-name>-YYYY-MM-DD/`, and write `spec.md` in that directory. Then clone repos into that dir and implement.

Share the spec with the user (e.g. paste or point to the file) and confirm they're happy before moving to implementation.

---

## Step 4 (optional): Implement and open a PR

If the user wants to **implement now**:

1. **Set up work dir and clone repos**
   Follow **[general-fix.md](./general-fix.md)** Steps 1–2: create `work/design-<short-name>-YYYY-MM-DD/` (or reuse the dir where you wrote the spec), and from **[REPOS.md](../REPOS.md)** clone **only the repos you need**.

2. **Implement per the spec**
   Work in the order you defined. Use **[TOOLS.md](../TOOLS.md)** for run commands.

3. **Push and PR**
   Follow **[push-changes.md](./push-changes.md)**: create a PR or push direct per repo convention. Update **[work/WORK-TO-PR.md](../work/WORK-TO-PR.md)** when you open a PR.

If the user only wanted a plan, stop after Step 3. If they say **"end"** later, clean up the work directory per the end-cleanup rule.

---

## Quick reference

| Step | Action |
|------|--------|
| 1 | Read CONTEXT.md. |
| 2 | Establish design subject: if prior conversation set the topic, use that; otherwise ask general question batch. Interview in rounds; after each round ask if anything else to add or if ready to move on; only proceed when user confirms coverage is complete. |
| 3 | Write spec (problem, scope, components/order, decisions, acceptance criteria) in `work/design-.../spec.md`. Confirm with user. |
| 4 (optional) | General-fix: work dir + clone repos → implement per spec → push-changes (PR or direct per repo). |
