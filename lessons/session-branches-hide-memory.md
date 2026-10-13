Summary: Each session pushes to its own claude/* branch and the next session clones the default branch, so lessons and notes left on unmerged branches are invisible to later sessions unless something surfaces them.

- Found Oct. 13, 2026: two lessons committed by an earlier session to its own unmerged branch were absent from a session cloned from the default branch. That session would have re-derived both.
- Fix in place: .claude/hooks/vault-context.sh fetches all remote branches at session start and prints the commits, changed files, and full text of changed .md notes (matters/ excluded) on any branch not contained in HEAD.
- Memory becomes permanent, and visible in the user's Obsidian, only when a session branch is merged into the default branch. Merging is the user's call; say which branches carry unmerged lessons.
