# iOS Dev Skills

Reusable agent skills for iOS app development workflows.

Skills that improve common Apple-platform engineering tasks such as localization, RTL review, release preparation, testing, and product copy.

Compatible with [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Cursor](https://cursor.sh), [Codex](https://openai.com/codex), and [40+ other coding agents](https://skills.sh) via [skills.sh](https://skills.sh).

## Included Skills

### `apple-arabic-localization`

Use this skill when localizing Apple-platform apps between Arabic and English, reviewing RTL and LTR behavior, extracting visible strings into localization resources, wiring in-app language switching, or preparing Arabic App Store copy for Xcode-based apps.

Included references:

- `references/apple-localization-checklist.md` — end-to-end implementation checklist
- `references/rtl-review.md` — Arabic/LTR visual and semantic review
- `references/copy-guidelines.md` — Arabic/English product copy and store copy rules

## Install

### Via skills.sh (recommended)

Install all skills to your current project:

```bash
npx skills add Abdo-codes/iOS-dev-skills
```

Install only the Arabic localization skill:

```bash
npx skills add Abdo-codes/iOS-dev-skills --skill apple-arabic-localization
```

Install globally (available in all projects):

```bash
npx skills add Abdo-codes/iOS-dev-skills -g
```

### Manual

Copy the skill folder into your agent's skills directory:

```bash
# Claude Code
cp -R apple-arabic-localization .claude/skills/

# Cursor / Codex / other agents
cp -R apple-arabic-localization .agents/skills/
```

## Repository Layout

```text
iOS-dev-skills/
  apple-arabic-localization/
    SKILL.md                          # Skill definition (frontmatter + instructions)
    references/
      apple-localization-checklist.md # Implementation checklist
      rtl-review.md                   # RTL visual review guide
      copy-guidelines.md              # Arabic/English copy rules
```

## Trigger Examples

- "Localize this SwiftUI app to Arabic and English."
- "Review all RTL issues in this iOS app."
- "Add in-app language switching for this Xcode project."
- "Move all visible app strings into localization files."
- "Prepare Arabic App Store copy for this app."

## Scope

These skills are intended for Apple-platform projects, especially SwiftUI and UIKit apps managed in Xcode.
