---
name: create-pr
description: Create a pull request whose description is the review — written for reviewers who will not read the diff. Documents every change as before → after (logic, design, behavior), every decision made in the session incl. rejected alternatives, everything kept for compatibility or worked around (legacy paths, dual endpoints, deferred cleanups), impact and risks, what is out of scope, how it was verified and what to check manually. Fixed section schema, identical across projects. Always opens the PR as a draft. Use whenever the user asks to create/open/write a PR, pull request or MR, to write or improve a PR description, or when a branch is ready to be handed over for review.
---

# Create a pull request

**Premise:** in the age of AI-written code the reviewer often does not read the diff. The PR
description is the review surface. If a change is not in the description, it will not be reviewed.
Therefore the description must contain *everything that changes*, as before → after, plus every
decision that was taken while producing the branch.

A list of files or commits is **not** a description. "Refactored X", "improved error handling" or
"cleaned up Y" are **not** descriptions. Each item states what the code did before, what it does now,
and who is affected.

## 0. Preconditions

- On a feature branch, never on `main`/`master`. Working tree committed (follow the repo's commit
  conventions; run the project's linters before committing).
- Base branch synced: `git fetch origin` — if `origin/<base>` moved ahead, rebase/merge first and say so.
- Determine the host from `git remote -v` (SSH URLs only):
  - `github.com` → plain `gh`.
  - GitHub Enterprise (e.g. `mobex.ghe.com`) → `GH_HOST=<host> gh … -R <owner>/<repo>`; `gh pr create`
    has no `--hostname` flag.
  - Azure DevOps → the `mcp__azure-devops__*` tools. The description schema below applies unchanged.

## 1. Know the diff — re-read whatever is not reliably in context

If you wrote the code in this session and still have it clearly in context — the before/after, the
callers you traced, the decisions — you do not need to read it again. In every other case, read it.
When in doubt, read: a wrong description costs more than the tokens. Read at least the affected parts
when:

- the branch has commits you did not write, or from an earlier session
- the conversation was compacted, or is long enough that details may have blurred
- you never looked at how a change affects its callers or consumers
- you cannot state before → after for a change concretely from memory
- you are asked to describe a branch you did not produce → read it fully:
  `git log --oneline origin/<base>..HEAD` and `git diff origin/<base>...HEAD`

Whatever the source, every change must answer three questions: *What did this do before? What does
it do now? Who calls or consumes it?* Changes that hide inside "refactors" and must be surfaced
explicitly:

- removed or added `try/catch`, changed exception → HTTP status mapping, swallowed vs. propagated errors
- changed null/empty handling, defaults, ordering, filtering, deduplication
- parallelism, timeouts, retries, pagination limits
- API contract (request/response shape, status codes, events, topics), config keys, migrations
- authorization scope, tenant/organization boundaries, data visibility
- a new endpoint, route, event, consumer or type **next to** an existing one; old paths kept "for now";
  anything labelled legacy, deprecated, temporary, fallback, shim, feature flag or "cleanup later"
- dead code that was actually dead (say why — e.g. "`catch (ServiceException)` never matched, SDK 5.x throws `ODataError`")

## 2. Collect every decision from the session

From the conversation, list every choice made while producing the branch: the approach taken, the
alternatives that were discussed or rejected and why, explicit user instructions, trade-offs, things
deliberately deferred. If any of that is not reliably in context (compaction, earlier session) reconstruct
it from commit messages, issue comments and the diff, and mark such items `(reconstructed)`. Decisions the agent made **without** asking the user are still decisions —
list them and mark them `(decided without user input)` so the reviewer can veto.

## 3. Write the body — fixed schema

Write the body to a file (`--body-file`, never inline; quoting breaks). Sections appear **in this
order with exactly these headings**. A section that does not apply says `None.` / `Keine.` — never
omit it, so nobody has to search.

Language: match the language of existing PRs in the repo (fallback: the README's language). Pick one
heading set and use it verbatim:

| # | English | German |
|---|---------|--------|
| 1 | `## Why` | `## Warum` |
| 2 | `## What changes (before → after)` | `## Was sich ändert (Vorher → Nachher)` |
| 3 | `## Compatibility leftovers & workarounds` | `## Kompatibilitäts-Altlasten & Workarounds` |
| 4 | `## Design decisions` | `## Designentscheidungen` |
| 5 | `## Impact & risks` | `## Auswirkungen & Risiken` |
| 6 | `## Out of scope` | `## Nicht Teil dieses PRs` |
| 7 | `## Verification` | `## Verifikation` |
| 8 | `## Manual check before merge` | `## Manuell prüfen vor Merge` |
| – | `Fixes #123` / `Closes #123` / `Refs #123` | same |

### 1 Why
Problem, motivation, link to the issue. Two to five sentences. What was broken or missing, and
what the observable symptom was.

### 2 What changes (before → after)
The complete inventory. One entry per changed behavior or piece of logic, **not** per file. For
larger PRs group with `### Frontend`, `### API & messaging`, `### Backend`, `### Infrastructure`.
Every entry has three parts:

```
- **<Topic>**
  - Before: <what the code did, concretely>
  - After: <what it does now, concretely>
  - Affected: <callers, endpoints, consumers, UI, jobs, data>
```

Concrete means: method names, endpoints, HTTP codes, values, defaults. Not "better", "more robust".

### 3 Compatibility leftovers & workarounds
The section reviewers most often need and least often get. List everything that was **kept,
duplicated or built around** instead of changed:

- old endpoints, routes, events, consumers, fields, flags or types kept "for now" next to new ones
- parallel old/new code paths, shims, adapters, fallbacks, feature toggles
- anything labelled legacy, deprecated, temporary, TODO, or "cleanup in a follow-up"
- workarounds around existing code that the task could have changed directly

For each: what was kept, the assumption that justified it (e.g. "frontend and backend roll out
non-atomically"), and what the cleanup would be. If the user did not ask for the leftover, mark it
`(decided without user input)` and name the direct alternative — the user usually wants the thing
changed, not worked around. `None.` when nothing was kept.

### 4 Design decisions
One `### Why X instead of Y?` subsection per decision from step 2. Body: the decision, the
alternatives considered, the reason. Include rejected approaches and user instructions
("user asked to keep the existing endpoint"). Mark agent-only decisions `(decided without user input)`.

### 5 Impact & risks
What people outside the diff must know: breaking changes (API, events, SDKs to regenerate, shared
libraries → extra reviews), rollout/migration steps, config or infrastructure changes, security and
authorization implications, changed failure modes (what a user sees when something fails now vs.
before), performance. State the risk and the mitigation or the accepted trade-off.

### 6 Out of scope
Deliberately excluded, deferred or noticed-but-untouched items, with issue links if they exist.
Prevents "why didn't you also…" review rounds.

### 7 Verification
What was actually run, with counts: test suites (`1284/1284`), targeted tests, lint, build,
`dotnet format` / `npm run lint`, generated-code checks. Only claims that were executed in the
session. If something was not run, say so.

### 8 Manual check before merge
Checklist (`- [ ]`) of what the reviewer should verify by hand — UI flows, error states, edge
cases the tests cannot cover. Derived from sections 2, 3 and 5.

### Title
Conventional commit, imperative, lower-case, ≤ 72 chars: `type(scope): summary`, e.g.
`fix(mdatasvc): tolerate stale app role assignments`.

## 4. Show the draft, wait for explicit approval

Show title + full body to the user and **wait**. An answer to a side question is not approval;
the user must say the text goes in as is. Offer that the user edits the text themselves.

## 5. Create — always as draft

```bash
gh pr create --draft --base <base> --head <branch> --title '<title>' --body-file <file>
```

(prefix `GH_HOST=<host>` and add `-R <owner>/<repo>` on GHE.) Never mark ready-for-review unless the
user explicitly asks. Report the URL.

## 6. Keep it in sync

Every later commit on the branch goes through steps 1–3 for the delta and updates the description with
`gh pr edit <n> --body-file <file>`. The description must always match the final diff — a stale
description is worse than none because the reviewer trusts it.

## Quick checklist

- [ ] Every change mapped to a before/after entry; anything not reliably in context re-read from the diff
- [ ] Every session decision listed, agent-only ones marked
- [ ] Changed failure modes and error → status mappings stated
- [ ] Every legacy path, dual endpoint, shim or deferred cleanup listed with its assumption — or `None.`
- [ ] All eight sections present, in order, verbatim headings; `None.` where empty
- [ ] Verification lists only what actually ran
- [ ] Draft approved by the user before `gh pr create`
- [ ] Created with `--draft`

See `references/example.md` for a complete filled-in example.
