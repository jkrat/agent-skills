# Agent Skills

Personal agent skills shared by Claude Code and Codex, versioned with git.

## Skills

### How it works

Each skill has one canonical copy at `skills/<skill-name>/` in this repo. `install.sh` symlinks every skill folder, one link per skill, into both:

- `~/.agents/skills/<skill-name>`: Codex's user-level skills folder
- `~/.claude/skills/<skill-name>`: Claude Code's personal skills folder

The whole `~/.claude/skills` or `~/.agents/skills` directory is never symlinked, because Claude Code keeps its own things there (such as `synced/` and `.trash/`).

The links point at this working tree, so:

- editing a file here takes effect in both tools immediately
- `git checkout <tag|branch>` changes which version both tools use

A versioned `hooks/post-merge` hook reruns `install.sh` after every pull or merge.

On Windows (Git Bash), `install.sh` sets `MSYS=winsymlinks:nativestrict` so that `ln -s` creates real symlinks. This needs Developer Mode, or an elevated shell.

### Setup on a new machine

```bash
git clone <remote> ~/Documents/3016/AI-Infra/agent-skills \
  && ~/Documents/3016/AI-Infra/agent-skills/install.sh \
  && git -C ~/Documents/3016/AI-Infra/agent-skills config core.hooksPath hooks
```

If a real (non-symlinked) folder with the same name as a repo skill already exists in `~/.claude/skills` or `~/.agents/skills`, `install.sh` skips it and says so. Move that folder into `skills/` first, then rerun the script. Also remove any old copies from `~/.codex/skills/` so Codex doesn't see the same skill twice.

### Adding, editing, renaming, deleting

- **Add:** create `skills/<skill-name>/SKILL.md`. The frontmatter `name` must match the folder name. Then run `./validate.sh` and `./install.sh`.
- **Edit:** edit the files in `skills/`. The change is live in both tools right away.
- **Rename:** rename the folder and update `name` in the frontmatter, then rerun `./install.sh`. The old links are removed automatically.
- **Delete:** delete the folder, then rerun `./install.sh`.

Commit when you're happy with the change.

Skill layout:

```
skills/<skill-name>/
├── SKILL.md          (required)
├── references/       (optional; docs loaded on demand)
├── scripts/          (optional; executed, not read)
└── agents/openai.yaml (optional; Codex UI metadata, ignored by Claude Code)
```

### Portability rules

`./validate.sh` checks the following rules. Errors fail the run; warnings don't.

- Frontmatter starts on line 1 with `---`.
- `name` matches the folder name, and names are unique across skills.
- `description` says what the skill does and when to use it, with the key use case first. It must be 1,024 characters or fewer.
- Frontmatter uses only cross-tool fields: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.
  - Claude Code–only fields such as `model`, `context` or `disable-model-invocation` produce warnings.
- The body avoids Claude Code–only syntax that Codex won't run: `` !`cmd` `` lines, ` ```! ` blocks, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}` and `$ARGUMENTS`.
  - Use plain relative paths (`scripts/check.sh`) and plain instructions ("run `git diff`") instead.
- `SKILL.md` stays under about 500 lines. Move long material to `references/`.

### Pinning a version

Releases are tagged with a `skills-` prefix, for example `skills-v1.0.0`.

```bash
git tag skills-v1.1.0 && git push --tags     # release
git checkout skills-v1.0.0 && ./install.sh   # pin both tools to a version
git checkout main && ./install.sh            # back to latest
```

### Caveat

Claude Code cloud sessions, routines, and Cowork don't read `~/.claude/skills`, so these skills are only available in local sessions.

### Skill list

| Skill | Description |
|---|---|
| `code-review` | Two-axis review (Standards and Spec) of the changes since a commit, branch, tag, or merge-base. |
| `domain-modeling` | Build and sharpen a project's domain model: `development/GLOSSARY.md` and ADRs in `development/adr/`. |
| `grilling` | Grill the user relentlessly about a plan, decision, or idea. |
| `grill-with-docs` | Grilling plus domain-modeling: interview about a design and write the glossary and ADRs as you go. |
| `implement` | Implement a piece of work based on a spec or set of tickets. |
| `setup-matt-pocock-skills` | Configure a repo's issue tracker, triage labels, and domain doc layout (`development/agents/`). |
| `to-spec` | Turn the current conversation into a spec and publish it to the issue tracker. |
| `to-tickets` | Break a plan or spec into tracer-bullet tickets with blocking edges, published to the tracker. |

### Per-repo configuration

`to-spec`, `to-tickets`, `code-review`, and `domain-modeling` read configuration from the repo they run in:

- `AGENTS.md` contains an `## Agent skills` block, and `CLAUDE.md` imports it with `@AGENTS.md`.
- `development/agents/` holds `issue-tracker.md`, `triage-labels.md`, and `domain.md`.
- The triage labels must exist on the repo's GitHub: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix`.

To set up a new repo, run `/setup-matt-pocock-skills` in it.
