# Contributing

Thanks for improving these iOS development agent skills.

This repository is intentionally small: each contribution should make one skill easier to discover, install, or use in a real Apple-platform project.

## Good First Contributions

- Fix README drift when a skill is added or renamed.
- Improve a skill trigger description so agents load it for the right tasks.
- Add a focused reference file for details that would make `SKILL.md` too long.
- Add or improve a small deterministic script when a workflow is repetitive or error-prone.
- Tighten examples, checklists, or gotchas based on real Xcode, SwiftUI, UIKit, or tvOS issues.

## Adding a Skill

Start from `skill-template/` when creating a new skill.

A skill should include:

- `SKILL.md` with YAML frontmatter containing `name` and `description`.
- Clear trigger wording in `description`, including the user phrases that should activate the skill.
- Concise workflow guidance in the body.
- Optional `references/` files for detailed guidance that should only be loaded when needed.
- Optional `scripts/` for repeatable checks or transformations.

Avoid adding extra documentation inside a skill folder unless the skill directly needs it. Put repository-level docs in the repository root.

## Skill Quality Checklist

Before opening a PR, check that the skill:

- Has a specific name that matches its folder.
- Explains when to use it and when not to use it.
- Focuses on Apple-platform work where this repository has expertise.
- Keeps `SKILL.md` lean and moves long examples into `references/`.
- Uses scripts for fragile or repetitive shell workflows.
- Mentions verification steps when the skill changes code or user-facing behavior.
- Updates `README.md` with install commands, included references, and trigger examples.

## Pull Request Checklist

- Keep the PR focused on one skill or one documentation improvement.
- Run `git diff --check` before submitting.
- Include a short summary of what changed and why.
- Mention any validation you performed, such as running a script, checking Markdown, or testing install commands.
