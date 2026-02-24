---
name: commit-branch-pr
description: Commit the current changes to a new branch and create a PR.
argument-hint: [patch|minor|major]
---

Commit the current changes to a new branch (or use an existing if an existing branch is fitting).
It doesn't matter if the branch contains commits from other branches (when the branch is not coming from main/master directly).
No need to cherry pick.
Then push the branch and create a pull request (if a MCP for the git host is configured).