#!/usr/bin/env bash
# Install Fleece skills for Claude Code and/or OpenClaw / Codex agents.
#
# Usage:
#   bash install.sh           # auto-detect
#   bash install.sh --claude  # Claude Code only
#   bash install.sh --agents  # OpenClaw / Codex only
#   bash install.sh --all     # both

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_claude() {
  TARGET=".claude/skills"
  mkdir -p "$TARGET"
  for f in "$SCRIPT_DIR"/.claude/skills/fleece-*.md; do
    dest="$TARGET/$(basename "$f")"
    [ "$(realpath "$f")" = "$(realpath "$dest" 2>/dev/null)" ] && continue
    cp "$f" "$dest"
  done
  echo "✓ Claude Code skills installed to $TARGET/"
  echo "  Research:    /fleece-card /fleece-rates /fleece-partners /fleece-credits"
  echo "               /fleece-news /fleece-compare /fleece-wallet /fleece-roi /fleece-recommend"
  echo "  Redemption:  /fleece-mcc /fleece-flights /fleece-hotels"
  echo "  Profile:     /fleece-profile"
}

install_agents() {
  TARGET=".agents/skills/fleece"
  mkdir -p "$TARGET"
  src="$SCRIPT_DIR/.agents/skills/fleece/SKILL.md"
  dest="$TARGET/SKILL.md"
  [ "$(realpath "$src")" != "$(realpath "$dest" 2>/dev/null)" ] && cp "$src" "$dest"
  echo "✓ Agent skill installed to $TARGET/SKILL.md"
}

auto_detect() {
  INSTALLED=0
  if [ -d ".claude" ]; then
    install_claude
    INSTALLED=1
  fi
  if [ -d ".agents" ]; then
    install_agents
    INSTALLED=1
  fi
  if [ "$INSTALLED" -eq 0 ]; then
    echo "No .claude or .agents directory found. Pass --claude, --agents, or --all."
    exit 1
  fi
}

case "${1:-auto}" in
  --claude) install_claude ;;
  --agents) install_agents ;;
  --all)    install_claude; install_agents ;;
  auto)     auto_detect ;;
  *)        echo "Usage: bash install.sh [--claude|--agents|--all]"; exit 1 ;;
esac

echo ""
echo "BRAVE_API_KEY is optional — mcc, flights, and hotels work without it."
echo "Set BRAVE_API_KEY in your environment or .env file to enable live research commands."
