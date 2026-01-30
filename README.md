# Claude Code Skills

A collection of custom [Claude Code](https://claude.com/claude-code) skills for personal use.

## Installation

### Clone the entire repo

```bash
git clone git@github.com:Xitee1/claude-skills.git ~/.claude/skills
```

### Or copy individual skills

```bash
mkdir -p ~/.claude/skills
cp -r bump-version ~/.claude/skills/
```

Once installed, skills are available in all Claude Code sessions. Invoke them with `/skill-name` or let Claude use them automatically based on context.

## Available Skills

| Skill | Description |
|-------|-------------|
| [bump-version](bump-version/SKILL.md) | Bumps the version of the current project (patch, minor, or major) and creates a release branch |

## Adding a New Skill

1. Create a directory named after the skill (lowercase, hyphenated)
2. Add a `SKILL.md` with YAML frontmatter and instructions:

```yaml
---
name: my-skill
description: When to use this skill and what it does.
---

Instructions for Claude go here.
```

3. Optionally add supporting directories: `scripts/`, `references/`, `assets/`

See the [official docs](https://code.claude.com/docs/en/skills) and [Agent Skills spec](https://agentskills.io/specification) for the full format reference.
