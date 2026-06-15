# iOS Dev Skills

Reusable agent skills for iOS app development workflows.

Skills that improve common Apple-platform engineering tasks such as localization, RTL review, release preparation, testing, and product copy.

Compatible with [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Cursor](https://cursor.sh), [Codex](https://openai.com/codex), and [40+ other coding agents](https://skills.sh) via [skills.sh](https://skills.sh).

## Included Skills

### `apple-arabic-localization`

Use this skill when localizing Apple-platform apps between Arabic and English, reviewing RTL and LTR behavior, running EN/AR simulator audits, extracting visible strings into localization resources, wiring in-app language switching, or preparing Arabic App Store copy for Xcode-based apps.

Included references:

- `references/apple-localization-checklist.md` — end-to-end implementation checklist
- `references/rtl-review.md` — Arabic/LTR visual audit and remediation flow
- `references/apple-rtl-principles.md` — Apple-authored RTL rules and mirroring guidance
- `references/copy-guidelines.md` — Arabic/English product copy and store copy rules

### `tvos-focus`

Use this skill when building or debugging tvOS focus navigation in SwiftUI apps, including Siri Remote movement, `focusSection`, `FocusState`, focus traps, custom focus chrome, overlay dismissal, ScrollView focus behavior, and Apple TV button styles.

Included references:

- `references/full-guide.md` — complete tvOS focus guide with gotchas, patterns, and code examples

### `app-store-review-preflight`

Use this skill before submitting an Apple-platform app to App Review, auditing release readiness, checking metadata, privacy policy links, permission purpose strings, StoreKit or subscription copy, in-app purchase review risk, placeholders, debug UI, and reviewer access.

Included references:

- `references/review-checklist.md` — App Review readiness checklist
- `references/privacy-strings.md` — privacy, permissions, and purpose string checks
- `references/storekit-paywall-review.md` — StoreKit, paywall, and subscription review checks

## Install

### Via skills.sh (recommended)

Install all skills to your current project:

```bash
npx skills add Abdo-codes/iOS-development-agent-skills
```

Install only the Arabic localization skill:

```bash
npx skills add Abdo-codes/iOS-development-agent-skills --skill apple-arabic-localization
```

Install only the tvOS focus skill:

```bash
npx skills add Abdo-codes/iOS-development-agent-skills --skill tvos-focus
```

Install only the App Store review preflight skill:

```bash
npx skills add Abdo-codes/iOS-development-agent-skills --skill app-store-review-preflight
```

Install globally (available in all projects):

```bash
npx skills add Abdo-codes/iOS-development-agent-skills -g
```

### Manual

Copy one or more skill folders into your agent's skills directory:

```bash
# Claude Code
cp -R apple-arabic-localization .claude/skills/
cp -R tvos-focus .claude/skills/
cp -R app-store-review-preflight .claude/skills/

# Cursor / Codex / other agents
cp -R apple-arabic-localization .agents/skills/
cp -R tvos-focus .agents/skills/
cp -R app-store-review-preflight .agents/skills/
```

## Repository Layout

```text
iOS-development-agent-skills/
  apple-arabic-localization/
    SKILL.md                          # Skill definition (frontmatter + instructions)
    scripts/
      audit-localization.sh           # Localization audit helper
    references/
      apple-localization-checklist.md # Implementation checklist
      rtl-review.md                   # RTL visual review guide
      apple-rtl-principles.md         # Apple RTL rules and mirroring guidance
      copy-guidelines.md              # Arabic/English copy rules
  tvos-focus/
    SKILL.md                          # tvOS focus gotchas and patterns
    references/
      full-guide.md                   # Complete tvOS focus guide
  app-store-review-preflight/
    SKILL.md                          # App Review preflight workflow
    scripts/
      audit-app-store-preflight.sh    # Static preflight audit helper
    references/
      review-checklist.md             # App Review readiness checklist
      privacy-strings.md              # Privacy and permission checks
      storekit-paywall-review.md      # StoreKit and paywall checks
```

## Trigger Examples

Arabic localization:

- "Localize this SwiftUI app to Arabic and English."
- "Review all RTL issues in this iOS app."
- "Run an English and Arabic RTL audit on this SwiftUI app."
- "Add in-app language switching for this Xcode project."
- "Move all visible app strings into localization files."
- "Prepare Arabic App Store copy for this app."

tvOS focus:

- "Fix tvOS focus navigation in this SwiftUI app."
- "Debug Siri Remote focus traps."
- "Remove the default white focus bubble."
- "Make this Apple TV overlay restore focus after dismissal."
- "Review focusSection and FocusState usage in this tvOS screen."

App Store review:

- "Run an App Store review preflight on this iOS app."
- "Check this app for App Review rejection risks."
- "Audit Info.plist permission strings before release."
- "Review this StoreKit paywall before App Store submission."

## Scope

These skills are intended for Apple-platform projects, especially SwiftUI and UIKit apps managed in Xcode. The `tvos-focus` skill is tvOS-only.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for skill quality guidelines, PR expectations, and the `skill-template/` starter.
