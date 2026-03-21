---
name: apple-arabic-localization
description: Use when localizing Apple-platform apps between Arabic and English, reviewing RTL/LTR behavior, extracting visible strings into localization files, wiring in-app language switching, or preparing Arabic App Store copy for Xcode-based apps.
---

# Apple Arabic Localization

## Overview

Use this skill for Apple app localization work that goes beyond translating strings. The goal is a coherent Arabic/English app: strings, locale, layout direction, digits, dates, notifications, seeded content, and store copy must all agree.

This skill is for Xcode-based Apple apps only: SwiftUI, UIKit, app extensions, and App Store metadata for iOS/iPadOS/macOS apps.

Read only the reference file you need:

- `references/apple-localization-checklist.md` for the end-to-end implementation checklist
- `references/rtl-review.md` for Arabic/LTR visual and semantic review
- `references/copy-guidelines.md` for Arabic/English product copy and store copy rules

## When To Use

- Adding Arabic and English support to an Apple app
- Reviewing an app that is translated but still feels broken in RTL or English
- Introducing an in-app language switch
- Moving visible strings out of Swift/UI code into localization resources
- Localizing notifications, seeded content, onboarding text, paywalls, empty states, or App Store copy
- Auditing an Arabic app for mixed locale bugs: Arabic strings with English layout, or English strings with Arabic digits/dates

Do not use this skill for Android-only or web-only localization work.

## Core Workflow

1. Audit the current localization architecture.
   Search for hard-coded locale, layout direction, raw UI strings, custom formatters, notification copy, seeded user-facing data, and App Store text.

2. Pick a single source of truth for language.
   Use one persisted app-language model to drive bundle lookup, `Locale`, `layoutDirection`, date formatting, number formatting, and any language-specific alignment behavior.

3. Extract visible strings.
   Move production-facing strings into the existing localization system. In Apple apps this is usually `Localizable.strings` or `.xcstrings`. Include views, reducers, notifications, seeded copy, errors, settings rows, and paywall/store messaging.

4. Wire the app root correctly.
   Inject the active `Locale`, `Calendar`, and `layoutDirection` from the chosen language source. Prefer semantic layout and icons over hard-coded left/right behavior.

5. Refresh derived localized data on language change.
   Anything computed before the switch may need reload or recomputation. Common misses are chart labels, seeded schedules, reminder text, cached summaries, and tab labels created before the language changed.

6. Review Arabic and English as separate UX states.
   Arabic needs a clean RTL pass. English needs a clean LTR pass. Fix both. Do not assume that making Arabic work preserves English.

7. Verify with focused tests and visual checks.
   Add tests for formatting helpers, persistence, reducer actions, and reload behavior. Then do visual passes in Arabic and English for navigation, sheets, forms, lists, tabs, and dates/numbers.

## Non-Negotiable Rules

- Never hard-code Arabic locale or RTL at the app root.
- If the product says “English,” that means full English conventions unless explicitly stated otherwise: LTR, English numerals, and English date formatting.
- Translating strings alone is not enough; cached localized content must refresh after language changes.
- Localize notifications and seeded user-facing data, not just SwiftUI/UIKit views.
- Prefer semantic APIs like `leading`/`trailing` and `chevron.forward`/`chevron.backward` over `left`/`right`.
- Preserve stable accessibility identifiers across locales.

## Apple-Specific Checks

- Use the repo’s existing localization format rather than introducing a new one unless required.
- Check app entry points for forced `.locale`, `.layoutDirection`, or custom formatters that ignore the active language.
- Review reducers and seed data, not just views. Apple apps often generate user-facing text outside UI files.
- If the repo has a long-running preview renderer or snapshot host test, do not treat plain `xcodebuild test` as the only verification path. Use focused test commands when needed.

## Required Deliverables

- Updated localization resources for Arabic and English
- A single active-language source of truth wired into the app
- Localized formatting behavior for digits, dates, and currency where appropriate
- A short list of remaining localization debt, if any
- Exact verification commands used

## Lessons To Preserve

- Today’s common failure mode: fixing Arabic by forcing Arabic globally. That breaks English later.
- Another common failure mode: switching strings without switching locale behavior.
- Another common failure mode: language switch works for chrome but stale summaries, reminders, or seeded content stay in the old language.
- Another common failure mode: RTL fixes regress English because arrows, sign placement, and alignment were not reviewed in LTR.
