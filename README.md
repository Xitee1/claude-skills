# My custom claude skills

## Installation
### Add the marketplace
`/plugin marketplace add git@github.com:Xitee1/claude-skills.git`

### Install a specific skill (coding-helper-skills as example)
`/plugin install coding-helper-skills@xitee-skills`

### ..or interactively browse available skills
`/plugin`

### Updating
`/plugin marketplace update xitee-skills`

## Contents

### Skills
- `create-pr` — reviewer-oriented PR descriptions in a fixed schema (why, before → after, design decisions, impact & risks, out of scope, verification, manual checks). Always opens the PR as a draft.

### Commands
- `/bump-version` — bump patch/minor/major in the project's version file.
- `/commit-branch-pr` — commit current changes to a branch and open a PR (uses `create-pr`).
- `/commit-branch-pr-pick` — same, but cherry-picks only the relevant commits.
