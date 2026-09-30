# Domain docs

This repo's domain docs live under `development/`. Layout: **single-context**.

```
development/
├── GLOSSARY.md   the project's domain vocabulary
└── adr/          architecture decision records: 0001-slug.md, 0002-slug.md, ...
```

Both are created lazily by the `domain-modeling` skill (also run by `grill-with-docs`): `GLOSSARY.md` when the first term is resolved, `adr/` when the first ADR is needed. If a file doesn't exist yet, there's nothing to read; carry on.

## Rules for skills that consume these docs

- **Use the glossary's vocabulary.** Before writing a spec, ticket, issue title, or review, read `development/GLOSSARY.md` and use its canonical terms. Never use a word listed under a term's `_Avoid_` line.
- **Respect ADRs.** Before proposing a change in an area, scan `development/adr/` for decisions touching it. Don't silently contradict an accepted ADR; if the work needs to reverse one, say so explicitly and name the ADR.
- **Flag conflicts, don't fix them in passing.** If the code or the conversation contradicts the glossary or an ADR, surface it to the user. Only the `domain-modeling` skill edits these files.

<!--
Multi-context variant (only for repos with genuinely separate bounded contexts):
replace the layout above with `development/GLOSSARY-MAP.md`, which lists each
context and links to its own GLOSSARY.md. Consumers read the map first, then the
glossary for the context they're working in.
-->
