---
name: commit-branch-pr
description: Commit the current changes to a new branch and create a PR.
---

Commit the current changes to a new branch (or use an existing if an existing branch is fitting).
It doesn't matter if the branch contains commits from other branches (when the branch is not coming from main/master directly).
No need to cherry pick.
Then push the branch and create a pull request (if a MCP for the git host is configured).

For the pull request itself follow the `create-pr` skill of this plugin: re-read from the diff whatever is not reliably in context, write the description in its fixed before → after schema, get the text approved, and always create the PR as a draft.
