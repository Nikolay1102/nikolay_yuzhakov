# Working in this repository

This repository is for drafting litigation briefs, worked on mainly through Claude Code cloud sessions. The account has a cloud-session limit, and each session runs in a container that is deleted once the session goes idle. Two consequences drive everything below: a session that ends early wastes a scarce slot, and anything not committed and pushed is gone.

## Matters and briefs

Each matter lives in `matters/<matter-name>/`: `MATTER.md` is the case file (start one by copying `matters/_template/MATTER.md`), `record/` holds the record documents, and `drafts/` holds brief drafts in Markdown. Read `MATTER.md` before working on a matter and update it before ending the turn, so the next session starts from what is already established instead of re-deriving it.

- No authority enters a draft unverified. Confirm every case, statute, quotation, and pin cite against the retrieved source with the Midpage legal research tools, and log it in the matter's authorities table. A citation you could not verify stays in the draft only as `[UNVERIFIED: ...]`.
- Every factual assertion cites the record (exhibit, ECF number, page or paragraph), and the cite must match a document in `record/`. If the record does not support a fact, say so rather than softening the sentence.
- Draft in Markdown so revisions stay surgical and diffs show what changed. Produce the .docx only when the user asks for a filing version.
- Confidentiality: before committing anything under `matters/` other than the template, check that the GitHub repository is private. If it is public, keep the material out of git and tell the user.

## The vault

This repository is also the user's Obsidian vault. Their desktop Obsidian syncs it with the Obsidian Git plugin, so notes they write arrive here and notes you commit reach them once your commit is on the branch their Obsidian pulls (the default branch). `VAULT-SETUP.md` holds their setup steps; `scripts/vault-import.sh` performed the import.

- The SessionStart hook (`.claude/hooks/vault-context.sh`) prints the repository's visibility, every note's path and title, and the notes and lessons that other sessions committed to branches this checkout lacks. Those unmerged notes are memory: read them before working.
- The note list is a map, not the content. Before answering anything about the user, their matters, people, dates, money, or past decisions, search the vault (`grep -rniI --exclude-dir=.git -e '<term>' .`, trying spelling and transliteration variants of every name) and read the matching notes; answer from them and name the note. If the vault holds nothing, say so instead of filling the gap from general knowledge.
- Obsidian syntax: `[[Note]]` and `[[Note|alias]]` link to the file named `Note.md` anywhere in the vault, `![[file]]` embeds, YAML frontmatter holds properties, `#tag` tags. Write new notes the same way and link them to existing ones.
- Leave `.obsidian/` (the user's app settings and plugins) alone, and do not rename or move the user's notes unless asked: Obsidian links break.
- Git does not keep file timestamps. Original modified and created times are in `.vault-manifest.tsv`; later history is `git log -- <note>`.
- The confidentiality rule above covers the vault: while the hook reports the repository public, commit no vault notes or personal facts.

## Finish the task in the session that started it

You are operating autonomously. The user is not watching in real time and cannot answer questions mid-task, so asking 'Want me to...?' or 'Shall I...?' will block the work. For reversible actions that follow from the original request, proceed without asking. Stop only for destructive actions or genuine scope changes the user must decide.

Exception: when the user is describing a problem, asking a question, or thinking out loud rather than requesting a change, the deliverable is your assessment. Report your findings and stop.

Before ending your turn, check your last paragraph. If it is a plan, a list of next steps, or a promise about work you have not done, do that work now with tool calls. Do not stop or suggest a new session because the conversation is long; the context window is 1M tokens.

If a question comes up partway, first do everything that doesn't depend on the answer, then either state the assumption you made or put the question at the end of a turn that also delivers that progress. If one part is blocked, complete every other part and say exactly what you left out and why.

## Scope

The request sets the scope: don't quietly narrow, widen, or swap it. Something else worth doing that the task didn't call for is a suggestion to make at the end, not a change to make.

## Spend tokens on the work, not on overhead

- Request independent reads, searches, and lookups in one response rather than one per turn.
- Delegate independent subtasks to sub-agents and keep working while they run.
- Edit files surgically; rewrite a whole file only when most of it changes.
- For a long deliverable, settle structure and hard decisions in reasoning, then write the deliverable once in the reply. Drafting it in full in reasoning and again in the reply doubles the turn without improving the result.

## Report only what you can prove

Before reporting progress, audit each claim against a tool result from this session. If something is not verified, say so. If a step failed or was skipped, say that.

## Persist before ending

Commit and push finished work to the session's branch before ending a turn.

## Lessons: memory that survives the container

Claude Code's automatic memory is stored in the container's home directory and is lost when the container is reclaimed, so the durable memory for this repository is the `lessons/` directory. Its index loads into every session:

@lessons/INDEX.md

When you learn something a future session would need (a correction from the user, a confirmed approach, a fact that took real effort to establish), write one file per lesson in `lessons/` with a one-line summary at the top, add its line to `lessons/INDEX.md`, and commit it with the work. Record why it mattered. Update an existing lesson rather than adding a duplicate, and delete lessons that turn out to be wrong. Don't save what the repository or git history already records.
