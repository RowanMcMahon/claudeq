#!/bin/sh
# Install claudeq: copy claudeq.zsh into the user's config dir and source it from .zshrc.
# Non-destructive: never removes anything, backs up a changed claudeq.zsh before replacing it,
# and only appends to .zshrc when the source line isn't already there. Safe to re-run.
set -eu

src_dir=$(cd "$(dirname "$0")" && pwd)
src="$src_dir/claudeq.zsh"
dest_dir="${XDG_CONFIG_HOME:-$HOME/.config}/claudeq"
dest="$dest_dir/claudeq.zsh"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"
# $HOME stays unexpanded so .zshrc keeps working if the home dir moves
source_line="source \"\${XDG_CONFIG_HOME:-\$HOME/.config}/claudeq/claudeq.zsh\""

say() { printf '%s\n' "$*"; }

[ -f "$src" ] || { say "error: $src not found; run install.sh from a clone of the repo"; exit 1; }
command -v zsh >/dev/null 2>&1 || say "warning: zsh not found; claudeq aliases only work in zsh"
command -v claude >/dev/null 2>&1 || say "warning: claude not found on PATH; install Claude Code first"

mkdir -p "$dest_dir"
if [ ! -f "$dest" ]; then
  cp "$src" "$dest"
  say "installed $dest"
elif cmp -s "$src" "$dest"; then
  say "up to date: $dest"
else
  backup="$dest.bak-$(date +%Y%m%d%H%M%S)"
  cp "$dest" "$backup"
  cp "$src" "$dest"
  say "updated $dest (previous version saved to $backup)"
fi

if [ -f "$zshrc" ] && grep -qF 'claudeq/claudeq.zsh' "$zshrc"; then
  say "already sourced from $zshrc"
else
  printf '\n# claudeq: one-shot Claude questions (claudeq[s|m|l][1-5])\n%s\n' "$source_line" >> "$zshrc"
  say "added source line to $zshrc"
fi

# Older hand-written claudeq aliases defined after the source line would override these
if grep -nE '^[[:space:]]*alias[[:space:]]+claudeq' "$zshrc" >/dev/null 2>&1; then
  say "note: $zshrc already defines claudeq aliases of its own; remove them to use claudeq's:"
  grep -nE '^[[:space:]]*alias[[:space:]]+claudeq' "$zshrc" | sed 's/^/  /'
fi

say "done. open a new terminal or run: source $zshrc"
