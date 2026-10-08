# Working in this repository

This repository is worked on mainly through Claude Code cloud sessions. The account has a cloud-session limit, and each session runs in a container that is deleted once the session goes idle. Two consequences drive everything below: a session that ends early wastes a scarce slot, and anything not committed and pushed is gone.

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
