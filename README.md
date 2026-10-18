# claudeq

Throwaway one-shot Claude Code questions, answered straight into the terminal.

    claudeq how do I undo the last git commit
    claudeqm3 chart the price of bitcoin over the last year
    git diff | claudeqm explain this change

Each run calls `claude --print` with:

- no saved session (`--no-session-persistence`)
- WebSearch and WebFetch pre-allowed
- a short system prompt explaining the output goes raw to a terminal (no markdown, Unicode tables/charts sized to the terminal width)

Words are joined into one question, so quotes are optional; quote anything your shell would expand, like `?` or `*`. Piped input is passed to Claude along with the question.

## Variants

The command name picks the model and effort: `claudeq[model][effort]`, where either suffix can be left off.

| Suffix | Meaning                                           | Default |
|--------|---------------------------------------------------|---------|
| model  | `s` haiku, `m` sonnet, `l` opus                   | `s`     |
| effort | `1` low, `2` medium, `3` high, `4` xhigh, `5` max | `1`     |

So `claudeq` = haiku/low, `claudeql` = opus/low, `claudeq3` = haiku/high, `claudeql5` = opus/max.

Flags override the name: `-m` takes `s|m|l` or any model name `claude` accepts, `-e` takes `1-5` or a level name. Use `--` before a question that starts with `-`. See `claudeq --help`.

## Requirements

- macOS or Linux
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` on your PATH), signed in

`claudeq` is a POSIX `sh` script, so it works from any shell, scripts, editors and cron.

## Install

    curl -fsSL https://raw.githubusercontent.com/RowanMcMahon/claudeq/main/install.sh | sh

Or from a clone:

    git clone https://github.com/RowanMcMahon/claudeq.git
    cd claudeq
    ./install.sh

The same script works on macOS and Linux. It:

- copies `claudeq` to `~/.local/bin` (or `$XDG_BIN_HOME`, or `$CLAUDEQ_BIN_DIR` if set), backing up any changed copy already there
- links the 23 variant names (`claudeqs`, `claudeql4`, ...) to it, leaving alone any existing file with one of those names
- if that directory isn't on your PATH, adds it in your shell's startup file:

  | Shell | macOS                                                          | Linux        |
  |-------|----------------------------------------------------------------|--------------|
  | zsh   | `~/.zshrc` (or `$ZDOTDIR/.zshrc`)                               | same         |
  | bash  | first existing of `~/.bash_profile`, `~/.bash_login`, `~/.profile` (else creates `~/.bash_profile`) | `~/.bashrc` |
  | fish  | `~/.config/fish/conf.d/claudeq.fish`                            | same         |

- warns if `claude` is missing or too old, if another program earlier on PATH has a claudeq name, or if your shell defines `claudeq` aliases (which would run instead of the program)

It never deletes anything and is safe to re-run. Then open a new terminal and try `claudeq --help`.

To update, run the same install command again (or `git pull && ./install.sh`).

## Uninstall

    claudeq --uninstall

It lists what it will remove and asks before doing anything; add `--yes` to skip the question (needed when there's no terminal to ask on). It removes:

- the program and the variant links pointing at it (any unrelated file with a claudeq name is kept)
- copies saved by updates (`claudeq.bak-*`)
- the PATH line the installer added, backing up the startup file first; if other programs live in the same directory, the line is kept since they may rely on it

`./install.sh --uninstall` does the same thing, as does `curl -fsSL https://raw.githubusercontent.com/RowanMcMahon/claudeq/main/install.sh | sh -s -- --uninstall`.

## Customising

Edit the installed `~/.local/bin/claudeq`: the model and effort letters are in `set_model` and `set_effort`, and the system prompt is in `prompt`. The prompt is a double-quoted string, so avoid backticks and `$` in it; the shell would expand them. Re-running the installer replaces a changed copy, but backs it up first.
