# Vault setup

This makes the repository your Obsidian vault. Obsidian on your computer and every Claude cloud session then read and write the same files: you see what Claude writes, and Claude sees what you write.

## 1. Make the repository private (first, and required)

The repository is public today, so anything committed is readable by anyone. On GitHub open this repository, then Settings > General > Danger Zone > Change visibility > Make private. Until then the import script refuses to run and Claude sessions refuse to commit vault content.

Afterwards, delete the `matters/*` lines from `.gitignore` (or ask Claude to) so case files can be committed too. Then give Claude the Oct. 13, 2026 backup bundle to restore from.

## 2. Put this setup on the default branch

Cloud sessions start from the default branch, `claude/cloud-sessions-fable-setup-qb2wc6`. Merge the branch `claude/obsidian-vault-cloud-sync-pmch6u` into it: open and merge a pull request on GitHub, or ask Claude to open one. (Optional: rename the default branch to `main` under Settings > General.)

## 3. Clone and import (in a terminal)

```sh
git clone https://github.com/Nikolay1102/nikolay_yuzhakov.git ~/Vault
cd ~/Vault
scripts/vault-import.sh "/path/to/your current vault"
```

To get the path, type the command up to the opening quote and drag the vault folder into the terminal window. If git asks for a password, sign in once with GitHub Desktop or `gh auth login`.

The script stops without changing anything if the repository is public, a file exceeds GitHub's 100 MB limit, the vault contains symlinks, a vault file would be dropped by `.gitignore`, or a vault file would overwrite a different repository file. Otherwise it copies everything except `.git`, `.DS_Store`, `.obsidian/workspace*.json`, and `.obsidian/cache` (window layout and caches, which differ per device); keeps empty folders; checks every file's sha256 against the original; records original modified and created dates in `.vault-manifest.tsv`; then commits and pushes. Success ends with `verified: N files, B bytes, sha256 identical to ...`.

## 4. Open it in Obsidian and turn on sync

1. Obsidian > Open another vault > Open folder as vault > `~/Vault`.
2. Settings > Community plugins > Turn on > Browse > search "Git" > Install > Enable.
3. In the Git plugin's settings: auto commit-and-sync interval 5 minutes, auto pull interval 5 minutes, pull on startup on, push on commit-and-sync on. (Names differ slightly between plugin versions; older ones say "vault backup".)
4. Leave the old vault folder untouched as a backup until you have spot-checked notes, then stop opening it: two copies drift apart.

## What Claude gets

Each cloud session clones the default branch, so it starts with every note as of your last sync. A start-up hook lists every note with its title, reports whether the repository is private, and shows notes and lessons that earlier sessions left on branches not yet merged. `CLAUDE.md` requires Claude to search the vault before answering anything about you or your work.

## Limits

- Claude holds the map of the vault at all times and searches the full text when a question needs it; it does not hold every note's text in mind at once. Nothing is out of reach, but the answer depends on the search, which is why `CLAUDE.md` makes it mandatory.
- A session sees the vault as of its start. Edits you make while it runs reach it only after a `git pull`.
- Claude commits to its own session branch. Your Obsidian shows those notes after the branch is merged into the default branch; until then the next session still sees them through the start-up hook.
- Obsidian Sync and iCloud are invisible to cloud sessions; git is the only bridge. Files over 100 MB need Git LFS.
