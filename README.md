# claudeq

Throwaway one-shot Claude Code questions from the terminal, via generated zsh aliases.

    claudeq "how do I undo the last git commit"
    claudeqm3 "chart the price of bitcoin over the last year"

Each alias runs `claude --print` with:

- no saved session (`--no-session-persistence`)
- WebSearch and WebFetch pre-allowed
- a short system prompt explaining the output goes raw to a terminal (no markdown, Unicode tables/charts sized to `$COLUMNS`)

## Naming

`claudeq[model][effort]`, where either suffix can be left off:

| Suffix | Meaning                                           | Default |
|--------|---------------------------------------------------|---------|
| model  | `s` haiku, `m` sonnet, `l` opus                   | `s`     |
| effort | `1` low, `2` medium, `3` high, `4` xhigh, `5` max | `1`     |

So `claudeq` = haiku/low, `claudeql` = opus/low, `claudeq3` = haiku/high, `claudeql5` = opus/max.

## Requirements

- zsh
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` on your PATH), signed in

## Install

    git clone <this repo> claudeq
    cd claudeq
    ./install.sh

The installer:

- copies `claudeq.zsh` to `${XDG_CONFIG_HOME:-~/.config}/claudeq/claudeq.zsh`, backing up any changed copy already there
- appends a `source` line to `~/.zshrc` (or `$ZDOTDIR/.zshrc`) only if one isn't already present
- warns about any existing `alias claudeq...` lines in `.zshrc` that would clash, without touching them

It never deletes anything and is safe to re-run; re-running after `git pull` updates the installed copy.

Then open a new terminal, or `source ~/.zshrc`.

### Manual install

Copy `claudeq.zsh` anywhere and add `source /path/to/claudeq.zsh` to `~/.zshrc`.

## Uninstall

Remove the `# claudeq` comment and `source` line from `~/.zshrc`, then delete `~/.config/claudeq/`.

## Customising

Edit the `models`, `efforts` or `sys` values in the installed `claudeq.zsh`. Avoid backticks in `sys`: it's a double-quoted string, so the shell would run them as commands.
