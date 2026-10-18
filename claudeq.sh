# claudeq[model][effort] — throwaway one-shot `claude --print` questions (no saved session, web access)
# Works in zsh and bash (including macOS's bash 3.2); source it from your shell's rc file.
#   model:  s=haiku  m=sonnet  l=opus             (default: s)
#   effort: 1=low  2=medium  3=high  4=xhigh  5=max  (default: 1)
# e.g. claudeq "hi", claudeqs "hi", claudeql4 "hi", claudeq1 "hi"

_claudeq() {
  local model=$1 effort=$2 cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
  shift 2
  # Double-quoted: avoid backticks and $ in this text, the shell would expand them
  claude --allowedTools=WebSearch,WebFetch --print --no-session-persistence \
    --model="$model" --effort="$effort" \
    --append-system-prompt="Your response is printed raw to a terminal by a one-shot shell command, not shown in the Claude Code UI. Markdown is not rendered: do not use headings, bold, italics, code fences or backticks. Use plain text, short paragraphs, '-' bullets and indented code. Draw tables, charts and graphs with Unicode box-drawing and block characters (e.g. ┌─┬┐│├┼┤└┴┘ ▁▂▃▄▅▆▇█), laid out on a monospace grid: pad every cell so columns line up and rows are the same width, and avoid emoji or other double-width characters. The terminal is $cols columns wide: keep tables and charts within that width and print them directly, never inside a fenced code block (prose can wrap naturally). The user cannot reply, so do not ask follow-up questions; answer directly and concisely." \
    "$@"
}

for _cq_m in '' s m l; do
  case $_cq_m in
    m) _cq_model=sonnet ;;
    l) _cq_model=opus ;;
    *) _cq_model=haiku ;;
  esac
  for _cq_e in '' 1 2 3 4 5; do
    case $_cq_e in
      2) _cq_effort=medium ;;
      3) _cq_effort=high ;;
      4) _cq_effort=xhigh ;;
      5) _cq_effort=max ;;
      *) _cq_effort=low ;;
    esac
    alias "claudeq$_cq_m$_cq_e=_claudeq $_cq_model $_cq_effort"
  done
done
unset _cq_m _cq_e _cq_model _cq_effort
