#!/bin/bash
# Claude Skills Marketplace — Bootstrap Installer
# Usage: curl -sf https://raw.githubusercontent.com/Xitee1/claude-skills/main/install.sh | bash
#
# This installs the marketplace skill, which lets you browse
# and install individual skills directly from Claude Code.

set -e

SKILLS_DIR="$HOME/.claude/skills"
MARKETPLACE_DIR="$SKILLS_DIR/marketplace"
RAW_BASE="https://raw.githubusercontent.com/Xitee1/claude-skills/main"

echo "=== Claude Skills Marketplace Installer ==="
echo ""

# Create skills directory
mkdir -p "$MARKETPLACE_DIR"

# Download the marketplace skill
echo "Downloading marketplace skill..."
if curl -sf "$RAW_BASE/marketplace/SKILL.md" -o "$MARKETPLACE_DIR/SKILL.md"; then
    echo "Marketplace skill installed to $MARKETPLACE_DIR/"
else
    echo "Error: Failed to download marketplace skill. Check your internet connection."
    exit 1
fi

echo ""
echo "Installation complete!"
echo ""
echo "You can now use the marketplace in Claude Code:"
echo "  /skill marketplace list          — Browse available skills"
echo "  /skill marketplace install <name> — Install a skill"
echo "  /skill marketplace search <query> — Search for skills"
echo ""
echo "Or install skills directly:"

# Fetch registry and show available skills
echo ""
echo "Available skills:"
REGISTRY=$(curl -sf "$RAW_BASE/registry.json" 2>/dev/null) || true
if [ -n "$REGISTRY" ]; then
    echo "$REGISTRY" | grep -o '"name": *"[^"]*"' | sed 's/"name": *"//;s/"//' | while read -r name; do
        desc=$(echo "$REGISTRY" | grep -A1 "\"name\": *\"$name\"" | grep '"description"' | sed 's/.*"description": *"//;s/".*//')
        installed=""
        [ -f "$SKILLS_DIR/$name/SKILL.md" ] && installed=" [installed]"
        echo "  - $name: $desc$installed"
    done
else
    echo "  (Could not fetch registry — check your internet connection)"
fi
echo ""
