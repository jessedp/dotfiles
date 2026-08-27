# Instruction-file conventions (all agents, all repos)

Canonical copy: `~/.dotfiles/agents/CONVENTIONS.md` (same path on every machine). Tool-specific
mechanics (Claude `@imports`, memory formats) may change; these rules are about *where things
live* and do not.

## 0. When this applies — only when asked
- These conventions are applied **only when Jesse explicitly asks** to create, restructure, split,
  or "clean up" an instruction/doc/memory file. They are a spec for that job, not a standard to
  enforce.
- **Never** reorganize, trim, or "bring into compliance" an existing AGENTS.md, `docs/`,
  `planning/` or memory file as a side effect of other work, even if it plainly violates §2–§5.
  Existing files reached their current shape deliberately (e.g. `atl_ledger/AGENTS.md` is long on
  purpose); Jesse revisits them on his own schedule.
- If a file looks like it would benefit from restructuring, you may say so in **one sentence** at
  the end of your reply — once — and drop it.
- Ordinary edits to existing files follow the file's *existing* structure, not this document.
- New files created from scratch (a new repo's AGENTS.md, a new `docs/` file) do follow §1–§6.

## 1. One instruction file per repo
- `AGENTS.md` is the instruction file. `CLAUDE.md` and `GEMINI.md` are **symlinks** to it.
  Never overwrite a symlink with a file; never let the three drift.
- Global preferences (machines, memory rules, personal habits) are NOT repeated in project
  files. They live in `~/.dotfiles/claude/CLAUDE.md` (Claude) and equivalents.

## 2. AGENTS.md is an index, not a manual — ≤ ~120 lines
It is loaded into context on every turn, so every line has a recurring cost. It contains only:
1. **What this is** — 2–3 lines, plus which repo/host is authoritative for its data.
2. **How to work here** — run / test / deploy commands, package manager, DB connection *pointer*
   (`.env`), the hard rules ("never …", "ask before …").
3. **Where the details are** — a map: `docs/data-model.md`, `docs/lessons.md`, `docs/ops.md`,
   `planning/`, with one clause each saying *when* to read it.
Anything else — schemas, column semantics, API quirks, history, decisions — is a detail and
moves out. Import a detail file into every turn only if it is needed on every turn.

## 3. Details live in files with fixed names
| File | Holds | Style |
| --- | --- | --- |
| `docs/data-model.md` | schemas, tables, join keys, provenance, what a column means | current-state; edited in place |
| `docs/lessons.md` | gotchas, "we tried X, it failed because Y", API quirks | dated bullets, append-only |
| `docs/ops.md` | hosts, crons, deploy steps, where prod/dev copies live | current-state; name the host |
| `planning/NN_title.md` | decisions and plans | numbered, dated, **never rewritten** — supersede with a new one |
| `README.md` | setup for a human cloning the repo | — |
Existing projects with `plan/` or a different `docs/` layout keep their names; add the missing
files rather than renaming what works. Link, don't duplicate: a fact has one home.

## 4. Facts must be locatable and dated
- Machine-specific facts name the machine (`lehrer`, `oscar`, `oddjob`, `ls2`, `woa-1`).
- Status and coverage statements carry an absolute date ("as of 2026-08-26"), never "now".
- "Which instance is the truth" for the Atlanta data projects is the authority table in
  `~/projects/python/atl-data/AGENTS.md`; project files point there instead of restating it.

## 5. Agent memory is not documentation
Tool memory (Claude auto-memory etc.) holds **feedback, preferences, and pointers** — how Jesse
likes to work, and where to look. Durable project facts go in the repo files above. A memory
index (`MEMORY.md`) is one line per memory, no inline content.

## 6. Secrets
Never in instruction files, docs, or memory. `.env` (gitignored) holds them; docs say *which
file and which variable*, not the value.

## 7. When restructuring an existing file
- **Move, don't rewrite.** Keep wording and headings; relocate blocks to the files in §3.
  Cut only what is provably stale, and say so in the commit message.
- Leave a short "Moved to …" line where large sections used to be, for one release cycle.
- Verify the symlinks still point at `AGENTS.md` afterwards.
- One commit per repo, titled `docs: split AGENTS.md into index + docs/`.
