Summary: The GitHub repository Nikolay1102/nikolay_yuzhakov is PUBLIC (checked Oct. 8, 2026), so nothing under matters/ may be committed; a .gitignore now blocks it.

- Checked with the GitHub MCP search_repositories call on Oct. 8, 2026: "private": false, "visibility": "public".
- CLAUDE.md requires matter material to stay out of git while the repo is public. The root .gitignore excludes matters/* except the template.
- Consequence: matter files (MATTER.md, record/, drafts/) written in a session live only in that container and are lost when it is reclaimed. Deliver drafts to the user with SendUserFile in the same session.
- To lift: the user changes the repo to private (GitHub Settings > General > Danger Zone > Change visibility), then a session re-checks visibility, deletes the matters/* lines from .gitignore, and commits the matter directory.
