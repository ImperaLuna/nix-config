# Claude Code hook for SessionEnd and PreCompact, packaged by default.nix as
# claude-memory-pass (writeShellApplication adds the shebang and strict mode).
# Reads the thread's transcript and has a background `claude -p` run update
# the project's memory folder (~/.claude/projects/<project>/memory/), so every
# thread leaves its lessons behind whether or not the model saved them itself.
#
# Settings (environment):
#   MEMORY_PASS_MODEL      model for the pass (default: sonnet)
#   MEMORY_PASS_MIN_TURNS  skip threads with fewer user messages (default: 3)
#   MEMORY_PASS_MAX_CHARS  transcript characters sent, newest kept (default: 120000)
#   MEMORY_PASS_DIR        override the memory folder (testing)
#   MEMORY_PASS_FOREGROUND=1  run in the foreground (testing)
# `claude` comes from the calling session's PATH, so host wrappers and
# provider settings (Vertex at work) apply to the pass too.

# The pass is itself a Claude session; don't let it trigger another pass.
[ -n "${CLAUDE_MEMORY_PASS:-}" ] && exit 0

input=$(cat)
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
event=$(jq -r '.hook_event_name // "unknown"' <<<"$input")
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

model=${MEMORY_PASS_MODEL:-sonnet}
min_turns=${MEMORY_PASS_MIN_TURNS:-3}
max_chars=${MEMORY_PASS_MAX_CHARS:-120000}
memdir=${MEMORY_PASS_DIR:-$(dirname "$transcript")/memory}
log="$HOME/.claude/memory-pass.log"

# Conversation text only: user prompts and assistant replies, no tool traffic.
extract() {
  jq -r '
    select(.type == "user" or .type == "assistant")
    | select(.isSidechain != true)
    | .type as $who
    | (.message.content
       | if type == "string" then .
         else [.[] | select(.type == "text") | .text] | join("\n") end) as $t
    | select($t != "" and ($t | startswith("<") | not))
    | "## \($who)\n\($t)\n"' "$1"
}

turns=$(jq -r 'select(.type == "user") | .message.content | if type == "string" then "s" else (map(select(.type == "text")) | if length > 0 then "s" else empty end) end' "$transcript" | wc -l)
if [ "$turns" -lt "$min_turns" ]; then
  echo "$(date -Is) skip $event: $turns user messages in $transcript" >>"$log"
  exit 0
fi

work=$(mktemp -d)
extract "$transcript" | tail -c "$max_chars" >"$work/conversation.md"
mkdir -p "$memdir"

case "$event" in
  PreCompact) what="is about to be compacted" ;;
  *) what="just ended" ;;
esac

prompt=$(cat <<EOF
You maintain a persistent memory folder for a coding project: $memdir

Read the conversation on stdin (a Claude Code thread that $what). Then read $memdir/MEMORY.md and any memory files it points to.

Save what a future thread in this project would need and could not get from the code or git history:
- user: who the user is, their role, expertise, preferences.
- feedback: corrections or confirmed approaches, with the reason.
- project: goals, decisions, constraints, ongoing work. Convert relative dates to absolute ones (today is $(date +%F)).
- reference: pointers to external resources (URLs, dashboards, tickets).

Rules:
- One fact per file, named <type>_<short_slug>.md, with frontmatter:
  ---
  name: <short-kebab-slug>
  description: <one line, used to judge relevance later>
  metadata:
    type: user | feedback | project | reference
  ---
  then the fact. For feedback and project add **Why:** and **How to apply:** lines.
- Update an existing file when it covers the fact. Delete one the conversation proved wrong. Never duplicate.
- Keep MEMORY.md as an index: one line per file, "- [Title](file.md) — hook". No content in it.
- Skip anything that only mattered inside this conversation, secrets, and things the repo already records.
- If nothing is worth saving, change nothing.
Reply with one line listing the files you changed, or "no changes".
EOF
)

run() {
  cd "$work"
  CLAUDE_MEMORY_PASS=1 claude -p "$prompt" \
    --model "$model" \
    --add-dir "$memdir" \
    --allowedTools "Read" "Glob" "Edit(/$memdir/**)" "Bash(rm $memdir/*)" \
    <"$work/conversation.md" 2>&1 | sed "s|^|$(date -Is) $event: |" >>"$log"
  rm -rf "$work"
}

if [ -n "${MEMORY_PASS_FOREGROUND:-}" ]; then
  run
else
  (run &) >/dev/null 2>&1
fi
exit 0
