#!/bin/sh
# Install claudeq on macOS or Linux, for zsh or bash.
# Copies claudeq.sh into the user's config dir and sources it from the right rc file.
# Non-destructive: never removes anything, backs up a changed claudeq.sh before replacing it,
# and only appends to the rc file when the source line isn't already there. Safe to re-run.
#
# Usage: ./install.sh [zsh|bash]   (defaults to your login shell, $SHELL)
set -eu

src_dir=$(cd "$(dirname "$0")" && pwd)
src="$src_dir/claudeq.sh"
dest_dir="${XDG_CONFIG_HOME:-$HOME/.config}/claudeq"
dest="$dest_dir/claudeq.sh"
# $HOME stays unexpanded so the rc file keeps working if the home dir moves
source_line=". \"\${XDG_CONFIG_HOME:-\$HOME/.config}/claudeq/claudeq.sh\""

say() { printf '%s\n' "$*"; }
die() { say "error: $*" >&2; exit 1; }

[ -f "$src" ] || die "$src not found; run install.sh from a clone of the repo"

os=$(uname -s)
case $os in
  Darwin|Linux) ;;
  *) say "warning: untested OS ($os); continuing as on Linux" ;;
esac

shell_name=${1:-$(basename "${SHELL:-}")}
case $shell_name in
  zsh)
    rc="${ZDOTDIR:-$HOME}/.zshrc"
    ;;
  bash)
    if [ "$os" = Darwin ]; then
      # macOS terminals start login shells, which read the first of these that exists;
      # creating .bash_profile when .profile exists would stop .profile being read
      rc="$HOME/.bash_profile"
      for f in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile"; do
        if [ -f "$f" ]; then rc=$f; break; fi
      done
    else
      # Linux terminals start non-login interactive shells, which read .bashrc
      rc="$HOME/.bashrc"
    fi
    ;;
  *)
    die "unsupported shell '${shell_name:-unknown}'; claudeq needs zsh or bash (run: ./install.sh zsh|bash)"
    ;;
esac
command -v "$shell_name" >/dev/null 2>&1 || say "warning: $shell_name not found on PATH"

if ! command -v claude >/dev/null 2>&1; then
  say "warning: claude not found on PATH; install Claude Code first"
elif ! claude --help 2>/dev/null | grep -q -- '--no-session-persistence'; then
  say "warning: your Claude Code is too old for claudeq's flags; update it (claude update)"
fi

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

if [ -f "$rc" ] && grep -qF 'claudeq/claudeq.sh' "$rc"; then
  say "already sourced from $rc"
else
  printf '\n# claudeq: one-shot Claude questions (claudeq[s|m|l][1-5])\n%s\n' "$source_line" >> "$rc"
  say "added source line to $rc"
fi

# Older hand-written claudeq aliases defined after the source line would override these
if grep -nE '^[[:space:]]*alias[[:space:]]+claudeq' "$rc" >/dev/null 2>&1; then
  say "note: $rc already defines claudeq aliases of its own; remove them to use claudeq's:"
  grep -nE '^[[:space:]]*alias[[:space:]]+claudeq' "$rc" | sed 's/^/  /'
fi

say "done ($os, $shell_name). open a new terminal or run: source $rc"
