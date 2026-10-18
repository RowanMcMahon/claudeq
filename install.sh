#!/bin/sh
# Install claudeq on macOS or Linux: copies the claudeq program into a bin dir and links its
# variants (claudeqs, claudeql4, ...) to it.
# Non-destructive: never deletes or overwrites anything it didn't create, backs up a changed
# claudeq before replacing it, and only touches a shell startup file when the bin dir isn't
# already on PATH. Safe to re-run, e.g. after git pull to update.
#
# Usage: ./install.sh                             installs to ~/.local/bin (or $XDG_BIN_HOME)
#        CLAUDEQ_BIN_DIR=/some/dir ./install.sh   installs somewhere else
set -eu

src_dir=$(cd "$(dirname "$0")" && pwd)
src="$src_dir/claudeq"
bin_dir=${CLAUDEQ_BIN_DIR:-${XDG_BIN_HOME:-$HOME/.local/bin}}
dest="$bin_dir/claudeq"
marker="# claudeq: add $bin_dir to PATH"

say() { printf '%s\n' "$*"; }
die() { say "error: $*" >&2; exit 1; }

[ -f "$src" ] || die "$src not found; run install.sh from a clone of the repo"

os=$(uname -s)
case $os in
  Darwin|Linux) ;;
  *) say "warning: untested OS ($os); continuing as on Linux" ;;
esac
shell_name=$(basename "${SHELL:-sh}")

if ! command -v claude >/dev/null 2>&1; then
  say "warning: claude not found on PATH; install Claude Code first"
elif ! claude --help 2>/dev/null | grep -q -- '--no-session-persistence'; then
  say "warning: your Claude Code is too old for claudeq's flags; update it (claude update)"
fi

# 1. The program
mkdir -p "$bin_dir"
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
chmod 755 "$dest"

# 2. Variant names, as symlinks to claudeq
linked=0
taken=""
for m in '' s m l; do
  for e in '' 1 2 3 4 5; do
    name="claudeq$m$e"
    [ "$name" = claudeq ] && continue
    link="$bin_dir/$name"
    if [ -L "$link" ] && [ "$(readlink "$link")" = claudeq ]; then
      continue
    elif [ -e "$link" ] || [ -L "$link" ]; then
      taken="$taken $name"
    else
      ln -s claudeq "$link"
      linked=$((linked + 1))
    fi
  done
done
say "linked $linked new variants in $bin_dir"
[ -z "$taken" ] || say "warning: left these existing files alone, so those variants aren't installed:$taken"

# 3. PATH
case ":$PATH:" in
  *":$bin_dir:"*)
    say "$bin_dir is already on PATH"
    ;;
  *)
    # Keep $HOME unexpanded so the line survives a home dir move
    case $bin_dir in
      "$HOME"/*) path_expr="\$HOME${bin_dir#"$HOME"}" ;;
      *) path_expr=$bin_dir ;;
    esac
    case $shell_name in
      zsh) rc="${ZDOTDIR:-$HOME}/.zshrc"; line="export PATH=\"$path_expr:\$PATH\"" ;;
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
        line="export PATH=\"$path_expr:\$PATH\""
        ;;
      fish)
        rc="${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/claudeq.fish"
        mkdir -p "$(dirname "$rc")"
        line="fish_add_path \"$bin_dir\""
        ;;
      *) rc="" ;;
    esac
    if [ -z "$rc" ]; then
      say "warning: $bin_dir isn't on PATH and $shell_name isn't a shell this installer knows; add it yourself"
    elif [ -f "$rc" ] && grep -qF "$marker" "$rc"; then
      say "PATH line already in $rc"
    else
      printf '\n%s\n%s\n' "$marker" "$line" >> "$rc"
      say "added $bin_dir to PATH in $rc"
    fi
    ;;
esac

# 4. Anything that would run instead of the installed program
shadowed=""
for f in "$bin_dir"/claudeq*; do
  [ -L "$f" ] || [ "$f" = "$dest" ] || continue
  name=$(basename "$f")
  found=$(command -v "$name" 2>/dev/null || true)
  [ -z "$found" ] || [ "$found" = "$f" ] || shadowed="$shadowed $name"
done
[ -z "$shadowed" ] || say "warning: other programs earlier on PATH take precedence for:$shadowed"
# Aliases and functions beat programs on PATH; ask the user's shell what it defines
case $shell_name in
  zsh|bash)
    aliases=$("$SHELL" -ic 'alias' </dev/null 2>/dev/null | grep -E '^(alias )?claudeq' || true)
    if [ -n "$aliases" ]; then
      say "warning: your $shell_name config defines claudeq aliases, which override the program; remove them:"
      printf '%s\n' "$aliases" | cut -d= -f1 | sed 's/^/  /'
    fi
    ;;
esac

say "done. open a new terminal, then try: claudeq --help"
