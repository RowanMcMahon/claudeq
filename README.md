# claudeq

Throwaway one-shot Claude Code questions from the terminal, via generated shell aliases.

    claudeq "how do I undo the last git commit"
    claudeqm3 "chart the price of bitcoin over the last year"

Each alias runs `claude --print` with:

- no saved session (`--no-session-persistence`)
- WebSearch and WebFetch pre-allowed
- a short system prompt explaining the output goes raw to a terminal (no markdown, Unicode tables/charts sized to the terminal width)

## Naming

`claudeq[model][effort]`, where either suffix can be left off:

| Suffix | Meaning                                           | Default |
|--------|---------------------------------------------------|---------|
| model  | `s` haiku, `m` sonnet, `l` opus                   | `s`     |
| effort | `1` low, `2` medium, `3` high, `4` xhigh, `5` max | `1`     |

So `claudeq` = haiku/low, `claudeql` = opus/low, `claudeq3` = haiku/high, `claudeql5` = opus/max.

## Requirements

- macOS or Linux
- zsh or bash (bash 3.2+, so macOS's built-in bash works)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` on your PATH), signed in

## Install

    git clone <this repo> claudeq
    cd claudeq
    ./install.sh

The same script works on macOS and Linux. It installs for your login shell (`$SHELL`); to pick one explicitly, run `./install.sh zsh` or `./install.sh bash`.

The installer:

- copies `claudeq.sh` to `${XDG_CONFIG_HOME:-~/.config}/claudeq/claudeq.sh`, backing up any changed copy already there
- adds a line sourcing it to your shell's startup file, only if one isn't already present:

  | Shell | macOS                                                          | Linux        |
  |-------|----------------------------------------------------------------|--------------|
  | zsh   | `~/.zshrc` (or `$ZDOTDIR/.zshrc`)                               | same         |
  | bash  | first existing of `~/.bash_profile`, `~/.bash_login`, `~/.profile` (else creates `~/.bash_profile`) | `~/.bashrc` |

- warns about any existing `alias claudeq...` lines in that file that would clash, without touching them
- warns if `claude` is missing or too old for the flags claudeq uses

It never deletes anything and is safe to re-run; re-running after `git pull` updates the installed copy.

Then open a new terminal, or `source` the startup file it names.

### Manual install

Copy `claudeq.sh` anywhere and add `. /path/to/claudeq.sh` to your shell's startup file.

## Uninstall

Remove the `# claudeq` comment and the line below it from your shell's startup file, then delete `~/.config/claudeq/`.

## Customising

Edit the installed `claudeq.sh`: the model and effort letters are in the two `case` blocks, and the system prompt is in `_claudeq`. The prompt is a double-quoted string, so avoid backticks and `$` in it; the shell would expand them.
