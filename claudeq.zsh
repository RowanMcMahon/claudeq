# claudeq[model][effort] — throwaway one-shot `claude --print` variants (no saved session, web access)
#   model:  s=haiku  m=sonnet  l=opus             (default: s)
#   effort: 1=low  2=medium  3=high  4=xhigh  5=max  (default: 1)
# e.g. claudeq "hi", claudeqs "hi", claudeql4 "hi", claudeq1 "hi"
() {
  local -A models=( s haiku m sonnet l opus )
  local -A efforts=( 1 low 2 medium 3 high 4 xhigh 5 max )
  local sys="Your response is printed raw to a terminal by a one-shot shell command, not shown in the Claude Code UI. Markdown is not rendered: do not use headings, bold, italics, code fences or backticks. Use plain text, short paragraphs, '-' bullets and indented code. Draw tables, charts and graphs with Unicode box-drawing and block characters (e.g. ┌─┬┐│├┼┤└┴┘ ▁▂▃▄▅▆▇█), laid out on a monospace grid: pad every cell so columns line up and rows are the same width, and avoid emoji or other double-width characters. The terminal is __COLS__ columns wide: keep tables and charts within that width and print them directly, never inside a fenced code block (prose can wrap naturally). The user cannot reply, so do not ask follow-up questions; answer directly and concisely."
  # double-quote the prompt so ${COLUMNS} expands each time an alias runs, not when it is defined
  local qsys=${(qqq)sys}
  qsys=${qsys//__COLS__/'${COLUMNS:-80}'}
  local m e cmd
  for m in '' ${(k)models}; do
    for e in '' ${(k)efforts}; do
      cmd="claude --allowedTools=WebSearch,WebFetch --print --no-session-persistence --append-system-prompt=$qsys"
      cmd+=" --model=${models[${m:-s}]} --effort=${efforts[${e:-1}]}"
      alias "claudeq${m}${e}=${cmd}"
    done
  done
}
