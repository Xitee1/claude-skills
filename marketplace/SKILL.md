---
name: marketplace
description: Browse, install, and manage Claude Code skills from the community marketplace.
argument-hint: [list|install <name>|uninstall <name>|update|search <query>|installed]
---

# Claude Skills Marketplace

You are managing skills from the Claude Skills Marketplace.

**Repository:** https://github.com/Xitee1/claude-skills
**Registry URL:** https://raw.githubusercontent.com/Xitee1/claude-skills/main/registry.json

## Commands

Based on the user's argument (`$1`), perform one of the actions below.
If no argument is provided, default to `list`.

---

### `list` — Browse available skills

1. Fetch the registry:
   ```
   curl -sf https://raw.githubusercontent.com/Xitee1/claude-skills/main/registry.json
   ```
2. For each skill in the registry, check if it is already installed by testing if `~/.claude/skills/<name>/SKILL.md` exists.
3. Display a formatted table/list:
   ```
   <name> — <description>
     Tags: <tags>    Status: Installed ✅ / Not installed
   ```

---

### `install <name>` — Install a skill

The argument can be a single skill name or a comma-separated list (e.g. `install bump-version,another-skill`).

For each skill name:

1. Fetch the registry and find the skill entry. If the skill does not exist, report an error and continue with the next one.
2. For each file listed in the skill's `files` array:
   ```
   mkdir -p ~/.claude/skills/<name>
   curl -sf <raw_base_url>/<name>/<file> -o ~/.claude/skills/<name>/<file>
   ```
3. Confirm what was installed.

If the skill is already installed, ask whether the user wants to reinstall/update it.

---

### `uninstall <name>` — Remove a skill

1. Check that `~/.claude/skills/<name>` exists.
2. Show the skill name and ask for confirmation before deleting.
3. Remove it:
   ```
   rm -rf ~/.claude/skills/<name>
   ```
4. Confirm removal.

**Important:** Never uninstall the `marketplace` skill itself without an explicit double confirmation — the user would lose the ability to manage skills.

---

### `update` — Update all installed skills

1. Fetch the latest registry.
2. List all directories in `~/.claude/skills/` that match a skill in the registry.
3. For each match, re-download all files from the registry entry (same as install).
4. Report which skills were updated.

---

### `search <query>` — Search for skills

1. Fetch the registry.
2. Filter skills where the `name`, `description`, or any `tag` matches the query (case-insensitive substring match).
3. Display matching results in the same format as `list`.

---

### `installed` — List installed skills

1. List all directories under `~/.claude/skills/`.
2. For each one, check if it exists in the registry (fetch it once).
3. Display each installed skill with its description (from registry) or mark as "Custom / untracked" if not in the registry.

---

## Error Handling

- If `curl` fails (no network, 404, etc.), display a clear error message and suggest the user check their internet connection or verify the skill name.
- Never silently fail — always report outcomes.

## Notes

- The skills directory is `~/.claude/skills/`.
- All downloads use the `raw_base_url` from the registry + `/<skill-name>/<file>`.
- Always use `curl -sf` (silent + fail on HTTP errors).
