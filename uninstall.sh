#!/usr/bin/env bash
set -euo pipefail

DEST_AGENTS="${HOME}/.claude/agents"
DEST_COMMANDS="${HOME}/.claude/commands"

AGENTS=(requirements-agent.md design-agent.md tasks-agent.md execution-agent.md)
COMMANDS=(requirements.md design.md tasks.md execute.md)

echo "Uninstalling t-kiro-agent..."

for f in "${AGENTS[@]}"; do
  if [[ -f "${DEST_AGENTS}/${f}" ]]; then
    rm -v "${DEST_AGENTS}/${f}"
  fi
done

for f in "${COMMANDS[@]}"; do
  if [[ -f "${DEST_COMMANDS}/${f}" ]]; then
    rm -v "${DEST_COMMANDS}/${f}"
  fi
done

cat <<EOF

t-kiro-agent uninstalled.

Your specs under ~/.kiro/ are preserved. To remove them manually:
  rm -rf ~/.kiro/
EOF
