#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_AGENTS="${HOME}/.claude/agents"
DEST_COMMANDS="${HOME}/.claude/commands"

echo "Installing t-kiro-agent..."
mkdir -p "${DEST_AGENTS}" "${DEST_COMMANDS}"

echo "  Copying agents -> ${DEST_AGENTS}"
cp -v "${SCRIPT_DIR}/subagents/"*.md "${DEST_AGENTS}/"

echo "  Copying commands -> ${DEST_COMMANDS}"
cp -v "${SCRIPT_DIR}/commands/"*.md "${DEST_COMMANDS}/"

cat <<EOF

t-kiro-agent installed.

Next steps:
  1. Fully restart Claude Code, or reload the Cursor window (Cmd+Shift+P -> Developer: Reload Window).
  2. From any git repo, start with: /requirements <feature-name>

Specs will be written to: ~/.kiro/<repo-name>/<feature-name>/
EOF
