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

## Trigger Examples

- "Localize this SwiftUI app to Arabic and English."
- "Review all RTL issues in this iOS app."
- "Add in-app language switching for this Xcode project."
- "Move all visible app strings into localization files."

## Scope

These skills are intended for Apple-platform projects, especially SwiftUI and UIKit apps managed in Xcode.
