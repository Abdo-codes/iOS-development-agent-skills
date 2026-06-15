---
name: apple-arabic-localization
description: Use when localizing Apple-platform apps between Arabic and English, reviewing Arabic RTL/LTR behavior, extracting visible strings into Localizable.strings or .xcstrings, wiring in-app language switching, preparing Arabic App Store copy, or when the user mentions "RTL", "Arabic layout", "localize", "xcstrings", or "language switch" for SwiftUI/UIKit Xcode-based apps.
---

# Apple Arabic Localization

## Overview

Use this skill for Apple app localization work that goes beyond translating strings. The goal is a coherent Arabic/English app: strings, locale, layout direction, digits, dates, notifications, seeded content, and store copy must all agree.

This skill is for Xcode-based Apple apps only: SwiftUI, UIKit, app extensions, and App Store metadata for iOS/iPadOS/macOS apps.

## Available Resources

- `scripts/audit-localization.sh <repo-path>` — run first to find hard-coded locales, raw strings, notification copy, custom formatters, and RTL/LTR direction hotspots. Produces a structured report.
- `scripts/check-localization-parity.py <repo-path>` — run after resource changes to compare English and Arabic `.strings`, `.stringsdict`, and `.xcstrings` keys, placeholders, empty values, untranslated values, and bidi risks.
- `references/apple-localization-checklist.md` — end-to-end implementation checklist
- `references/rtl-review.md` — Arabic/LTR visual audit, prioritization, and verification flow
- `references/apple-rtl-principles.md` — Apple-authored RTL rules and what should or should not mirror
- `references/copy-guidelines.md` — Arabic/English product copy and store copy rules
- `references/parity-checker-examples.md` — examples of parity checker findings and how to interpret them

## When To Use

- Adding Arabic and English support to an Apple app
- Reviewing an app that is translated but still feels broken in RTL or English
- Introducing an in-app language switch
- Moving visible strings out of Swift/UI code into localization resources
- Localizing notifications, seeded content, onboarding text, paywalls, empty states, or App Store copy
- Auditing an Arabic app for mixed locale bugs: Arabic strings with English layout, or English strings with Arabic digits/dates

Do not use this skill for Android-only or web-only localization work.

## Core Workflow

1. **Audit first.**
   Run `scripts/audit-localization.sh <repo-path>` to get a structured report of issues. Then search for anything the script missed: seeded data in reducers, cached summaries, tab labels built at startup, and custom layout code that "looks semantic" but still bakes in one direction.

2. **Pick a single source of truth for language.**
   One persisted app-language model drives bundle lookup, `Locale`, `layoutDirection`, date formatting, number formatting, and any language-specific alignment. Avoid partial solutions where strings use one source and formatting uses another.

3. **Run a live EN/LTR and AR/RTL pass.**
   Use the best available tooling in this order: Maestro flows if they exist and run cleanly, XcodeBuildMCP simulator interaction if available, then a manual simulator sweep. Review Arabic and English as separate product states, not as mirror images of one another. Capture screenshots or accessibility snapshots for onboarding, home, settings, forms, lists, detail rows, progress/timeline surfaces, and any custom navigation or disclosure UI.

4. **Extract visible strings.**
   Move production-facing strings into the existing localization system (usually `Localizable.strings` or `.xcstrings`). Include views, reducers, notifications, seeded copy, errors, settings rows, and paywall/store messaging.

5. **Check localization resource parity.**
   Run `scripts/check-localization-parity.py <repo-path>` after changing localization resources. Fix missing keys and placeholder mismatches before visual review. Review warnings for untranslated Arabic, Arabic text in English resources, and Arabic strings that start with placeholders.

6. **Wire the app root correctly.**
   Inject the active `Locale`, `Calendar`, and `layoutDirection` from the chosen language source. The root must react immediately to in-app language switches without requiring relaunch.

7. **Refresh derived localized data on language change.**
   Anything computed before the switch may need reload. Common misses: chart labels, seeded schedules, reminder text, cached summaries, tab labels created before the language changed.

8. **Classify findings before fixing.**
   Split issues into:
   - shared primitives and design-system components
   - navigation and row affordances
   - screen-specific layout bugs
   - formatting and bidi text bugs
   - test coverage gaps
   Fix shared primitives first. Do not patch the same alignment bug independently across five screens if one shared row or field component is responsible.

9. **Verify with focused tests and visual checks.**
   Add tests for formatting helpers, persistence, reducer actions, and reload behavior. Expand snapshot or visual coverage for both locales on the highest-traffic screens. Do final passes in both locales for navigation, sheets, forms, lists, tabs, progress bars, swipe actions, and dates/numbers.

## Gotchas

These are the failure modes that keep recurring. Check every one before shipping.

**Forcing Arabic globally breaks English.**
The most common mistake: setting `Locale("ar")` or `.rightToLeft` at the app root to "fix Arabic." This makes Arabic work but silently breaks English — English numbers become Hindi digits, dates become Hijri, and LTR layout is gone. Always derive locale behavior from the user's active language choice, never hard-code it.

**Language switch updates strings but not locale behavior.**
Strings change to English, but `DateFormatter` still uses Arabic digits, or the calendar stays Hijri. The source of truth must drive both string lookup AND formatting locale. One without the other creates a half-translated app.

**Stale cached content after language switch.**
Tab labels, chart month names, seeded tips, scheduled notification text — anything computed at startup stays in the old language after switching. Each of these must re-derive from the new locale. This is the hardest bug to find because it only appears after a switch, not on a fresh launch.

**RTL fixes regress English.**
Flipping icons, swapping padding, or changing alignment to fix Arabic often breaks the same screen in English. Every RTL change needs a matching LTR check. Common victims: custom back buttons, disclosure indicators, sign placement in financial amounts, and carousel/swipe controls.

**Raw `.leading` and `.trailing` are not automatically safe.**
They are better than `.left` and `.right`, but they can still encode the wrong behavior when used in custom rows, progress bars, swipe actions, or asymmetric layouts. Treat any fixed start/end alignment as a review point when the component should mirror semantically.

**Progress bars, timelines, and swipe edges need explicit classification.**
Some surfaces should mirror with language direction, while others represent absolute chronology or physical direction and should remain fixed. Decide this intentionally per component instead of assuming all bars and edges should flip or should stay put.

**`.environment(\.layoutDirection, .rightToLeft)` applied at the wrong level.**
Applied at the root, this force-flips everything including system controls that already handle RTL correctly, causing double-flipping. Apply it only where actually needed, or better, let the system derive it from the active locale.

**Notification and reminder copy is never localized.**
Engineers localize views but forget `UNMutableNotificationContent` titles and bodies, reminder strings in reducers, and widget timeline entries. These are user-facing strings that need localization resources too.

**`DateFormatter()` without explicit locale inherits the system locale, not the app locale.**
If the user sets their device to English but uses the app in Arabic (or vice versa), `DateFormatter()` will format dates in the wrong language. Always set `.locale` on formatters to match the app's active language.

**Bidirectional text breaks when a localized string starts with a variable.**
If a string like `"\(userName) liked your post"` starts with a variable, the entire string inherits the variable's text direction. An English name in an Arabic string will flip the whole line to LTR. Fix: insert a Right-to-Left Mark (`\u{200F}`) before the variable for Arabic strings, or a Left-to-Right Mark (`\u{200E}`) for English strings. Same applies to phone numbers and numeric IDs embedded in Arabic text — wrap them with LRE (`\u{202A}`) and PDF (`\u{202C}`) to preserve their LTR display.

**Images and custom icons don't auto-flip for RTL.**
SF Symbols with semantic names (`chevron.forward`) flip automatically, but custom images, asset catalog icons, and any `UIImage` do not. You must explicitly set `imageFlipsForRightToLeftLayoutDirection = true` on UIKit images, or apply `.flipsForRightToLeftLayoutDirection` in SwiftUI, but only for directional images (arrows, progress indicators) — not for logos or photos.

**Using `chevron.left` or `chevron.right` for navigation bakes in a locale assumption.**
Use semantic symbols such as `chevron.forward` and `chevron.backward` for navigation and disclosure affordances. Reserve `left` and `right` only for absolute spatial meaning.

**Arabic digits (٠١٢٣) vs. Western digits (0123) cause silent data bugs.**
When the device or app locale is Arabic, `NumberFormatter` may output Hindi-Arabic numerals (٠١٢٣٤). If these are sent to a server or used in calculations, they silently break parsing. Always use `Locale(identifier: "en")` for any formatter whose output feeds into APIs, storage, or arithmetic — and the app's active locale only for display.

## Non-Negotiable Rules

- Never hard-code Arabic locale or RTL at the app root.
- "English" means full English conventions: LTR, English numerals, and English date formatting — unless explicitly stated otherwise.
- Translating strings alone is not enough; cached localized content must refresh after language changes.
- Use Apple guidance as the baseline for what should mirror, what should stay fixed, and how directional icons should behave. Community blogs are secondary.
- Default to fixing shared primitives before screen-level patching when the same issue repeats.
- Localize notifications and seeded user-facing data, not just views.
- Preserve stable accessibility identifiers across locales.

## Deliverables

Adapt to what the task actually requires — not every task needs all of these:

- Updated localization resources for Arabic and English
- A single active-language source of truth wired into the app
- A concrete RTL/LTR findings list grouped by shared primitives vs screen-specific bugs
- A phased remediation plan for the app surfaces that matter most
- Localized formatting behavior for digits, dates, and currency
- A short list of remaining localization debt, if any
- Verification commands or test results showing both locales work
