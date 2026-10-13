#!/bin/bash
# Copy an existing Obsidian vault into this repository, which then becomes the vault.
# Refuses to run while the GitHub repository is public. Proves the copy byte-identical
# by sha256, records original timestamps in .vault-manifest.tsv (git does not keep them),
# keeps empty folders with .gitkeep, then commits and pushes the current branch.
#
# Usage: scripts/vault-import.sh [--assume-private] [--no-push] /path/to/existing/vault
#   --assume-private  proceed when the GitHub API cannot answer (rate limit, offline);
#                     only after confirming on github.com that the repository is private
#   --no-push         commit but do not push
#
# Excluded from the copy: .git, .DS_Store, .obsidian/workspace.json,
# .obsidian/workspace-mobile.json, .obsidian/cache (per-device window layout and caches).
set -euo pipefail

die() { echo "vault-import: $*" >&2; exit 1; }
assume_private=0; push=1
while [ $# -gt 0 ]; do
  case "$1" in
    --assume-private) assume_private=1; shift ;;
    --no-push) push=0; shift ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    -*) die "unknown option $1" ;;
    *) break ;;
  esac
done
[ $# -eq 1 ] || die "usage: $0 [--assume-private] [--no-push] /path/to/vault"
[ -d "$1" ] || die "$1 is not a folder"

src=$(cd "$1" && pwd -P)
repo=$(git rev-parse --show-toplevel 2>/dev/null) || die "run this from inside a clone of the repository"
repo=$(cd "$repo" && pwd -P)
[ -d "$src/.obsidian" ] || die "$src has no .obsidian folder, so it is not an Obsidian vault"
case "$repo/" in "$src/"*) die "the repository is inside the vault; clone it elsewhere" ;; esac
case "$src/" in "$repo/"*) die "the vault is inside the repository; move it out first" ;; esac
[ -z "$(git -C "$repo" status --porcelain)" ] || die "the repository has uncommitted changes; commit or stash them first"

# 1. Visibility gate. Unauthenticated, the GitHub API answers 200 only for public repositories.
slug=$(git -C "$repo" remote get-url origin | sed -E 's#\.git$##' | awk -F'[/:]' '{print $(NF-1)"/"$NF}')
code=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "https://api.github.com/repos/$slug" || true)
case "$code" in
  200) die "github.com/$slug is PUBLIC; importing would publish the vault. Make it private (GitHub > Settings > General > Danger Zone > Change visibility), then re-run." ;;
  404) echo "visibility: github.com/$slug is private" ;;
  *) [ "$assume_private" = 1 ] || die "cannot verify github.com/$slug is private (GitHub API HTTP ${code:-none}). Confirm on github.com, then re-run with --assume-private."
     echo "visibility: unverified (HTTP ${code:-none}); proceeding on --assume-private" ;;
esac

# Portable helpers: macOS ships BSD stat and shasum, Linux GNU stat and sha256sum.
if stat -f %z / >/dev/null 2>&1; then
  stat_batch() { TZ=UTC xargs -0 stat -t '%Y-%m-%dT%H:%M:%SZ' -f '%z%t%Sm%t%SB'; }
else
  stat_batch() { TZ=UTC xargs -0 stat --printf '%s\t%y\t%w\n'; }
fi
if command -v sha256sum >/dev/null 2>&1; then hash_batch() { xargs -0 sha256sum; }
else hash_batch() { xargs -0 shasum -a 256; }; fi
# sha256sum prefixes a backslash when a name needs escaping; the digest is the next 64 chars.
digests() { (cd "$1" && tr '\n' '\0' < "$list" | hash_batch) | sed 's/^\\//' | cut -c1-64; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
list="$tmp/files"
prune='( -name .git -o -name .DS_Store -o -path ./.obsidian/workspace.json -o -path ./.obsidian/workspace-mobile.json -o -path ./.obsidian/cache )'

# 2. Inventory. Names containing a newline cannot round-trip through this list; refuse them.
(cd "$src" && find . $prune -prune -o \( -type f -o -type l \) -print) | sed 's#^\./##' | LC_ALL=C sort > "$list"
n=$(wc -l < "$list" | tr -d ' ')
[ "$n" -gt 0 ] || die "no files found in $src"
links=$(cd "$src" && find . $prune -prune -o -type l -print | sed 's#^\./##')
[ -z "$links" ] || die "symlinks are not imported faithfully by git; replace them with the files they point to: $links"
nl=$(cd "$src" && find . $prune -prune -o -name "$(printf '*\n*')" -print | head -5)
[ -z "$nl" ] || die "file names containing a newline: $nl"
(cd "$src" && tr '\n' '\0' < "$list" | stat_batch) > "$tmp/stat"
[ "$(wc -l < "$tmp/stat" | tr -d ' ')" = "$n" ] || die "stat returned a different line count than the file list"

# 3. Pre-flight checks, all before anything is copied.
big=$(paste "$list" "$tmp/stat" | awk -F'\t' '$2 > 100 * 1048576 {printf "  %s (%.0f MB)\n", $1, $2 / 1048576}')
[ -z "$big" ] || die "GitHub rejects files over 100 MB; move these out of the vault or into Git LFS:
$big"
paste "$list" "$tmp/stat" | awk -F'\t' '$2 > 50 * 1048576 {printf "warning: %s is %.0f MB (GitHub warns above 50 MB)\n", $1, $2 / 1048576}'
ignored=$(cd "$repo" && git check-ignore --no-index --stdin < "$list" || true)
[ -z "$ignored" ] || die "the repository's .gitignore would silently drop these vault files; adjust .gitignore first:
$ignored"
clash="$tmp/clash"
: > "$clash"
while IFS= read -r f; do if [ -e "$repo/$f" ]; then printf '%s\n' "$f" >> "$clash"; fi; done < "$list"
if [ -s "$clash" ]; then
  differ=$(paste "$clash" <(list="$clash" digests "$src") <(list="$clash" digests "$repo") | awk -F'\t' '$2 != $3 {print "  " $1}')
  [ -z "$differ" ] || die "these vault files would overwrite different repository files; rename one side first:
$differ"
fi

# 4. Copy, preserving modification times and permissions on this machine.
tar_opts=""
tar --version 2>/dev/null | grep -q 'GNU tar' && tar_opts="--verbatim-files-from"
# COPYFILE_DISABLE stops macOS tar from adding ._ AppleDouble files.
(cd "$src" && COPYFILE_DISABLE=1 tar -cf - $tar_opts -T "$list") | (cd "$repo" && tar -xpf -)
(cd "$src" && find . $prune -prune -o -type d -empty -print) | sed 's#^\./##' | while IFS= read -r d; do
  mkdir -p "$repo/$d" && : > "$repo/$d/.gitkeep"
done

# 5. Verify every byte, then write the manifest from the source's metadata.
digests "$src" > "$tmp/src.sha"
digests "$repo" > "$tmp/dst.sha"
bad=$(paste "$list" "$tmp/src.sha" "$tmp/dst.sha" | awk -F'\t' '$2 != $3 {print "  " $1}')
[ -z "$bad" ] || die "copy differs from the source for:
$bad"
bytes=$(awk -F'\t' '{s += $1} END {printf "%.0f", s}' "$tmp/stat")
{
  printf 'path\tbytes\tsha256\tmodified_utc\tcreated_utc\n'
  paste "$list" "$tmp/src.sha" "$tmp/stat" | awk -F'\t' 'BEGIN {OFS = "\t"} {print $1, $3, $2, $4, ($5 == "-" || $5 == "" ? "unknown" : $5)}'
} > "$repo/.vault-manifest.tsv"
echo "verified: $n files, $bytes bytes, sha256 identical to $src"

# 6. Commit, then confirm git stored every file.
cd "$repo"
git add -A
untracked=$(while IFS= read -r f; do git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 || printf '  %s\n' "$f"; done < "$list")
[ -z "$untracked" ] || die "git did not stage these files (nothing committed):
$untracked"
if git diff --cached --quiet; then echo "nothing to commit: the repository already holds this vault"; exit 0; fi
git commit -q -m "Import Obsidian vault: $n files, $bytes bytes, sha256-verified"
echo "committed: $(git log -1 --format='%h %s')"
if [ "$push" = 1 ]; then
  git push -u origin "$(git branch --show-current)"
else
  echo "not pushed (--no-push)"
fi
