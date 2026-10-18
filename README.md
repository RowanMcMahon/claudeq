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

| Suffix | Meaning                                     | Default |
|--------|---------------------------------------------|---------|
| model  | `s` haiku, `m` sonnet, `l` opus             | `s`     |
| effort | `1` low, `2` medium, `3` high, `4` xhigh, `5` max | `1`     |

So `claudeq` = haiku/low, `claudeql` = opus/low, `claudeq3` = haiku/high, `claudeql5` = opus/max.

## Install

Add to `~/.zshrc`:

    source ~/sites/claudeq/claudeq.zsh

Edit the `models`, `efforts` or `sys` values in `claudeq.zsh` to change the scheme. Avoid backticks in `sys`: it's a double-quoted string, so the shell would run them as commands.
