# Claude Skills Marketplace

A community marketplace for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills. Browse, install, and manage individual skills directly from Claude Code — no need to clone the entire repo.

## Quick Start

### One-line install

Run this to install the marketplace skill, which lets you manage everything else from inside Claude Code:

```bash
curl -sf https://raw.githubusercontent.com/Xitee1/claude-skills/main/install.sh | bash
```

### Then use it in Claude Code

```
/skill marketplace list                  # Browse all available skills
/skill marketplace install bump-version  # Install a specific skill
/skill marketplace search versioning     # Search by keyword
/skill marketplace installed             # See what you have installed
/skill marketplace update                # Update all installed skills
/skill marketplace uninstall bump-version # Remove a skill
```

You can also install multiple skills at once:
```
/skill marketplace install bump-version,some-other-skill
```

## Available Skills

| Skill | Description |
|-------|-------------|
| **bump-version** | Bumps the version of the current project (patch, minor, or major) |

## Manual Installation

If you prefer not to use the marketplace, you can still install skills manually:

1. Create the skills folder: `mkdir -p ~/.claude/skills`
2. Copy individual skill folders into `~/.claude/skills/`

Or clone the entire repo:
```bash
git clone https://github.com/Xitee1/claude-skills.git ~/.claude/skills
```

## Contributing a Skill

Want to add your own skill to the marketplace? Here's how:

### 1. Create your skill folder

```
your-skill-name/
  SKILL.md
```

### 2. Write your SKILL.md

Use YAML frontmatter for metadata, then describe the skill behavior in markdown:

```markdown
---
name: your-skill-name
description: Short description of what your skill does.
argument-hint: [arg1|arg2|arg3]
---

Instructions for Claude on how to execute this skill.
```

### 3. Add it to the registry

Add an entry to `registry.json`:

```json
{
  "name": "your-skill-name",
  "description": "Short description of what your skill does.",
  "version": "1.0.0",
  "author": "your-github-username",
  "tags": ["relevant", "tags"],
  "files": ["SKILL.md"]
}
```

### 4. Update .gitignore

Add a whitelist entry for your skill folder:

```
!your-skill-name/**
```

### 5. Open a pull request

Submit a PR to [Xitee1/claude-skills](https://github.com/Xitee1/claude-skills) and it will be reviewed for inclusion.

## How It Works

The marketplace is itself a Claude Code skill. When you run `/skill marketplace`, Claude reads the `SKILL.md` instructions and uses `curl` to fetch the skill registry from this GitHub repo. It then downloads individual skill files directly into your `~/.claude/skills/` directory — so you only install what you need.

```
~/.claude/skills/
  marketplace/          # The marketplace manager (installed by install.sh)
    SKILL.md
  bump-version/         # An individual skill (installed via marketplace)
    SKILL.md
  your-custom-skill/    # Your own local skills work alongside marketplace ones
    SKILL.md
```
