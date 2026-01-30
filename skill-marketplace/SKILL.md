---
name: skill-marketplace
description: Install, list, update, or uninstall Claude skills from the marketplace.
argument-hint: [list|install|uninstall|update] [skill-name]
---

You are managing the Claude Skills Marketplace. This skill allows users to discover and install Claude skills from the community marketplace.

## Available Commands

### List available skills
When the user asks to "list", "browse", or "show" skills, fetch the skills registry and display all available skills with their descriptions.

```bash
curl -sf "https://raw.githubusercontent.com/Xitee1/claude-skills/main/skills.json"
```

### Install a skill
When the user wants to install a skill:
1. **Validate the skill name**: Ensure it contains only alphanumeric characters, hyphens, and underscores. Reject names containing `/`, `\`, `..`, or other path components.
2. First, fetch the skills registry and verify the skill exists
3. Check if the skill is already installed and warn the user if so
4. Create the skill directory in `~/.claude/skills/<skill-name>/`
5. Download and save the SKILL.md file

```bash
# Validate skill name (must be alphanumeric with hyphens/underscores only)
# Reject: ../../etc, foo/bar, .., etc.

# Check if skill exists in registry first
curl -sf "https://raw.githubusercontent.com/Xitee1/claude-skills/main/skills.json" | grep -q '"id": "<skill-name>"'

# Check if already installed
if [ -d ~/.claude/skills/<skill-name> ]; then
    echo "Skill already installed. Use 'update' to update it."
fi

# Create skills directory if it doesn't exist
mkdir -p ~/.claude/skills/<skill-name>

# Download the skill file (with error handling)
curl -sf "https://raw.githubusercontent.com/Xitee1/claude-skills/main/<skill-name>/SKILL.md" > ~/.claude/skills/<skill-name>/SKILL.md
if [ $? -ne 0 ]; then
    rm -rf ~/.claude/skills/<skill-name>
    echo "Failed to download skill"
fi
```

### Uninstall a skill
When the user wants to uninstall/remove a skill:
1. **Validate the skill name**: Same validation as install - alphanumeric, hyphens, underscores only
2. Confirm the skill exists in `~/.claude/skills/<skill-name>/`
3. Remove the skill directory

```bash
# Validate skill name first, then:
if [ -d ~/.claude/skills/<skill-name> ]; then
    rm -rf ~/.claude/skills/<skill-name>
    echo "Skill uninstalled successfully"
else
    echo "Skill not found"
fi
```

### Update a skill
When the user wants to update a skill:
1. Verify the skill is installed
2. Re-download the SKILL.md from the repository

### Update all skills
When the user wants to update all skills:
1. List installed skills from `~/.claude/skills/`
2. For each installed skill, check if it exists in the marketplace registry
3. If the skill exists in the marketplace, re-download the latest version
4. If a local skill doesn't exist in the marketplace, skip it and inform the user

Note: "all" is a reserved keyword for the update command.

## Important Notes
- The skills directory is `~/.claude/skills/`
- Each skill is stored in its own subdirectory with a `SKILL.md` file
- After installing skills, restart Claude Code (close and reopen the application) for new skills to be recognized
- The marketplace skill itself is installed to `~/.claude/skills/skill-marketplace/` like other skills

## Security Considerations
- Always validate skill names before use - they must contain only alphanumeric characters, hyphens (-), and underscores (_)
- Never accept skill names containing path separators (`/`, `\`) or relative path components (`..`)
- Verify the skill exists in the registry before attempting to download

## Response Format
When listing skills, format the output as a nice table or list showing:
- Skill name
- Description
- Category (if available)
- Whether it's already installed (check if directory exists in ~/.claude/skills/)

When installing/uninstalling, confirm the action and show the result.
