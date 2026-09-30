---
name: setup-matt-pocock-skills
description: "Configure this repo for the engineering skills: set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills."
disable-model-invocation: true
---

# Setup Matt Pocock's Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker**: where issues live (GitHub by default; local markdown is also supported out of the box)
- **Triage labels**: the strings used for the five canonical triage roles
- **Domain docs**: where `GLOSSARY.md` and ADRs live, and the consumer rules for reading them

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config`: is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root: does either exist? Is there already an `## Agent skills` section in either?
- `development/GLOSSARY.md` and `development/GLOSSARY-MAP.md`
- `development/adr/` and any `src/*/development/adr/` directories
- `development/agents/`: does this skill's prior output already exist?
- `.scratch/`: a sign that a local-markdown issue tracker convention is already in use
- On GitHub, which of the triage labels already exist (`gh label list`)
- Monorepo signals: a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. These are present only in a genuinely large multi-package repo; their absence means single-context, which is almost every repo.

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order. One section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Give a one-line explainer only when the choice genuinely branches; skip the section entirely when exploration already settled it (Section C when there's no monorepo).

**Section A: Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-tickets`, `triage`, and `to-spec` read from and write to it. They need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub**: issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab**: issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown**: issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.): ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

Record the choice in `development/agents/issue-tracker.md`. The GitHub and GitLab templates carry a "PRs as a request surface" flag, defaulted **off**. Leave it off and don't raise it: a user who wants external PRs in the triage queue can flip the flag in the file later.

**Section B: Triage label vocabulary.** Always run this section, even when the `triage` skill isn't installed: `to-spec` and `to-tickets` apply the `ready-for-agent` label when they publish. Ask exactly one question:

> Do you want to keep the default triage labels? (recommended: **yes**)

The defaults are the five canonical roles, each label string equal to its name: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. On **yes**, write them as-is. Only if the user says no, usually because their tracker already uses other names (e.g. `bug:triage` for `needs-triage`), collect the overrides so `triage` applies existing labels instead of creating duplicates.

**Section C: Domain docs.** Default to **single-context** (one `development/GLOSSARY.md` + `development/adr/`). This fits almost every repo; write it without asking.

Offer **multi-context** (a `development/GLOSSARY-MAP.md` pointing to per-context `GLOSSARY.md` files) only when exploration found monorepo signals. Then confirm which layout they want.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to `AGENTS.md` (see step 4)
- The contents of `development/agents/issue-tracker.md`, `development/agents/domain.md`, and `development/agents/triage-labels.md`
- Which triage labels will be created on the tracker (only the missing ones)

Let them edit before writing.

### 4. Write

**Instruction files:** the block lives in `AGENTS.md` (read by Codex), and `CLAUDE.md` imports it so Claude Code sees the same copy.

- Create `AGENTS.md` at the repo root if it doesn't exist.
- If `CLAUDE.md` exists, make sure it contains an `@AGENTS.md` line (add it under the first heading if missing); leave the rest of `CLAUDE.md` alone. If `CLAUDE.md` doesn't exist, create it containing just `@AGENTS.md`.

If an `## Agent skills` block already exists in `AGENTS.md`, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `development/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `development/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `development/agents/domain.md`.
```

Then write the files under `development/agents/`, using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md): GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md): GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md): local-markdown issue tracker
- [triage-labels.md](./triage-labels.md): label mapping
- [domain.md](./domain.md): domain doc consumer rules + layout

For "other" issue trackers, write `development/agents/issue-tracker.md` from scratch using the user's description.

Finally, on GitHub or GitLab, create any of the configured triage labels that don't exist yet (`gh label create <label> --description "<meaning>"`), so publishing with `--label ready-for-agent` doesn't fail. Never modify labels that already exist.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `development/agents/*.md` directly later; re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.
