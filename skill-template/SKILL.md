---
name: your-skill-name
description: Use this skill when the user asks about specific Apple-platform workflow triggers, concrete technologies, or failure modes this skill covers. Include important phrases users are likely to say. State any explicit exclusions, such as not for Android or web-only work.
---

# Skill Title

## Overview

Use this skill for a focused Apple-platform workflow where generic coding guidance is not enough.

Keep this file concise. Add only the instructions an agent needs every time the skill is used. Move longer background, examples, or API details into `references/`.

## When To Use

- Add the main user task this skill handles.
- Add common trigger phrases, frameworks, or files.
- Add platform scope, such as iOS, iPadOS, macOS, watchOS, visionOS, or tvOS.

Do not use this skill for tasks outside its platform or workflow scope.

## Workflow

1. Inspect the project structure and identify the relevant app targets, packages, resources, or scripts.
2. Read only the reference files needed for the current task.
3. Make the smallest change that solves the user request.
4. Verify with focused commands, tests, previews, simulators, or review steps appropriate to the workflow.
5. Report changed files, validation results, and any remaining risks.

## Resources

- `references/example.md` — add only if the skill needs deeper guidance.
- `scripts/example.sh` — add only if the workflow benefits from a repeatable command.

## Gotchas

- Add real failure modes that agents often miss.
- Prefer concrete checks over broad advice.
- Keep examples short and specific.

## Deliverables

Adapt deliverables to the task. Common outputs include:

- Code or resource updates.
- A focused findings list.
- Verification commands and results.
- Follow-up tasks for issues outside the current scope.
