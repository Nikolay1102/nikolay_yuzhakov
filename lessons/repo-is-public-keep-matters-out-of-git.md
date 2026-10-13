Summary: The GitHub repository Nikolay1102/nikolay_yuzhakov is PUBLIC (checked Oct. 8, 2026), so nothing under matters/ may be committed; a .gitignore now blocks it.

- Checked with the GitHub MCP search_repositories call on Oct. 8, 2026: "private": false, "visibility": "public". Re-checked Oct. 13, 2026: unauthenticated https://api.github.com/repos/Nikolay1102/nikolay_yuzhakov returns 200 (a private repo returns 404); list_repos also reports "visibility": "public".
- The same block covers the Obsidian vault: scripts/vault-import.sh refuses to import while the API returns 200, and the session-start hook prints the visibility every session.
- CLAUDE.md requires matter material to stay out of git while the repo is public. The root .gitignore excludes matters/* except the template.
- Consequence: matter files (MATTER.md, record/, drafts/) written in a session live only in that container and are lost when it is reclaimed. Deliver drafts to the user with SendUserFile in the same session.
- A full-history backup bundle is held by the user (nikolay_yuzhakov-full-history-2026-10-13.bundle, sha256 5e470f85acefdddbf815c0531f0f517dfb7c51b3e587b05d5fbd1fd56f259e68). Once the repo is private, restore from it with: git fetch <bundle> '+refs/heads/*:refs/restored/*', then merge what is needed.
- To lift: the user changes the repo to private (GitHub Settings > General > Danger Zone > Change visibility), then a session re-checks visibility, deletes the matters/* lines from .gitignore, and commits the matter directory.
