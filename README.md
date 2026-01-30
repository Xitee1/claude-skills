# Claude Skills Marketplace

A community marketplace for Claude Code skills. Easily discover, install, and manage skills without manual cloning.

## Quick Start - Install the Marketplace

To get started, install the marketplace skill first. This is a one-time setup:

```bash
mkdir -p ~/.claude/skills/skill-marketplace && curl -sf "https://raw.githubusercontent.com/Xitee1/claude-skills/main/skill-marketplace/SKILL.md" -o ~/.claude/skills/skill-marketplace/SKILL.md || echo "Failed to download marketplace skill"
```

After installing, restart Claude Code (close and reopen the application) to load the marketplace skill.

## Using the Marketplace

Once the marketplace skill is installed, you can use these commands in Claude Code:

### List Available Skills
```
/skill-marketplace list
```

### Install a Skill
```
/skill-marketplace install bump-version
```

### Uninstall a Skill
```
/skill-marketplace uninstall bump-version
```

### Update a Skill
```
/skill-marketplace update bump-version
```

### Update All Skills
```
/skill-marketplace update all
```

## Available Skills

| Skill | Description |
|-------|-------------|
| [bump-version](./bump-version) | Bumps the version of the current project (patch, minor, or major) |

## Manual Installation (Alternative)

If you prefer to install skills manually:

### Option 1 - Git Clone (all skills)
1. Make sure `~/.claude/skills` does not exist
2. Clone this repo: `git clone git@github.com:Xitee1/claude-skills.git ~/.claude/skills`

### Option 2 - Manual Copy (individual skills)
1. Create the folder `~/.claude/skills`
2. Copy the individual skill folders you want to use

## Contributing Skills

Want to add your own skill to the marketplace?

1. Fork this repository
2. Create a new folder with your skill name (e.g., `my-skill/`)
3. Add a `SKILL.md` file with front matter:
   ```markdown
   ---
   name: my-skill
   description: A brief description of what your skill does.
   argument-hint: [optional arguments]
   ---
   
   Your skill instructions here...
   ```
4. Add your skill to `skills.json`:
   ```json
   {
     "id": "my-skill",
     "description": "A brief description of what your skill does.",
     "argumentHint": "[optional arguments]",
     "category": "your-category"
   }
   ```
5. Update `.gitignore` to whitelist your skill folder by adding:
   ```
   !my-skill/
   !my-skill/**
   ```
6. Submit a pull request

## Skill Format

Each skill is a folder containing a `SKILL.md` file with:

- **Front matter**: YAML metadata (name, description, argument-hint)
- **Body**: Instructions for Claude to follow when the skill is invoked
