# iOS Dev Skills

Reusable Codex skills for iOS app development workflows.

This repository is meant to hold shareable skills that improve common Apple-platform engineering tasks such as localization, RTL review, release preparation, testing, and product copy.

## Included Skills

### `apple-arabic-localization`

Use this skill when localizing Apple-platform apps between Arabic and English, reviewing RTL and LTR behavior, extracting visible strings into localization resources, wiring in-app language switching, or preparing Arabic App Store copy for Xcode-based apps.

Included references:

- `references/apple-localization-checklist.md`
- `references/rtl-review.md`
- `references/copy-guidelines.md`

## Repository Layout

```text
iOS-dev-skills/
  apple-arabic-localization/
    SKILL.md
    references/
```

## Using A Skill

Copy the skill folder into your Codex skills directory.

Common locations:

- `~/.agents/skills/`
- `skills/` inside a project repo

Example:

```bash
cp -R apple-arabic-localization ~/.agents/skills/
```

After that, start a new Codex session if your skill inventory is cached.

## Install Via skills.sh

Install the whole repository:

```bash
npx skills add Abdo-codes/iOS-development-agent-skills
```

Install only the Arabic localization skill:

```bash
npx skills add https://github.com/Abdo-codes/iOS-development-agent-skills --skill apple-arabic-localization
```

## Use With Claude

This skill format is compatible with Claude as well.

### Claude.ai

1. Download or clone this repository.
2. Zip the `apple-arabic-localization/` folder if needed.
3. In Claude.ai, open `Settings` -> `Capabilities` -> `Skills`.
4. Upload the skill folder or zip.
5. Enable the skill for your workspace or account.

### Claude Code

Anthropic documents the same skill format as portable across Claude.ai and Claude Code. You can use the `apple-arabic-localization/` folder as a Claude-compatible skill and place it in your Claude Code skills directory, depending on your setup.

## Trigger Examples

- "Localize this SwiftUI app to Arabic and English."
- "Review all RTL issues in this iOS app."
- "Add in-app language switching for this Xcode project."
- "Move all visible app strings into localization files."

## Scope

These skills are intended for Apple-platform projects, especially SwiftUI and UIKit apps managed in Xcode.
