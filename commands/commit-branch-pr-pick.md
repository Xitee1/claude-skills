---
name: commit-branch-pr-pick
description: Commit the current changes to a new branch and create a PR. Cherry-picks only the relevant changes into the branch for a clean PR.
---

Commit the current changes to a new branch (or use an existing if an existing branch is fitting).
If the branch contains other commits (e.g. not coming directly from the main/master branch), you must cherry pick your changes so that only the relevant commits will get merged to main/master.
Then push the branch and create a pull request (if a MCP for the git host is configured).