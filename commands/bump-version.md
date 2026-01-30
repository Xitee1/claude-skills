---
name: bump-version
description: Bumps the version of the current project (patch, minor, or major).
argument-hint: [patch|minor|major]
---

Increment the $1 version (default: patch) in the project's version file (package.json, Cargo.toml, pyproject.toml, or version.txt).

Examples:
- patch: 1.2.3 -> 1.2.4
- minor: 1.2.3 -> 1.3.0
- major: 1.2.3 -> 2.0.0

Then create a branch `release/v<new-version>`, commit with `chore: bump version to <new-version>`, and push.

If there are two or more projects (e.g. frontend and backend), ask which one or if all should be updated.
Skip projects that use dynamic versioning (e.g. using git tags).
If no version file is found, ask the user which file to use.
