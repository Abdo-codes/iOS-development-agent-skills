# Apple Localization Checklist

Use this checklist when implementing or reviewing Arabic/English localization in an Apple app.

## 1. Audit

Run `scripts/audit-localization.sh <repo-path>` first. It searches for:

- Hard-coded `Locale(identifier:)` and `layoutDirection` assignments
- Raw visible strings in Swift files (not localized)
- Notification and reminder copy
- Custom date/number formatters that may ignore the active locale
- Directional hardcoding (`.left`/`.right` instead of `.leading`/`.trailing`)
- Seeded or placeholder user-facing data
- Existing localization files

Review the audit output before proceeding. Then manually check for anything the script misses: reducer-generated text, cached summaries, and tab labels built at startup.

Run `scripts/check-localization-parity.py <repo-path>` after editing localization resources. It checks English/Arabic resource parity for:

- missing keys between English and Arabic
- placeholder mismatches like `%@`, `%d`, `%f`, and `{name}`
- empty Arabic values
- Arabic values that still match English
- English-looking Arabic values
- Arabic text accidentally present in English resources
- Arabic strings that start with placeholders and may need bidi isolation marks

## 2. Source Of Truth

Create or reuse one language model that can answer:

- current language key
- bundle or localization lookup
- `Locale`
- `Calendar`
- `layoutDirection`
- language-sensitive alignment if needed
- symbols or suffixes affected by locale, such as percent or currency short forms

Avoid partial solutions where strings use one source and formatting uses another.

## 3. Localization Resources

Prefer the app’s existing localization format:

- `Localizable.strings`
- `.xcstrings`

Do not leave production-facing UI text in Swift unless it is truly dynamic and built from localized components.

Include:

- onboarding
- settings
- dashboards and empty states
- errors
- modal and sheet labels
- paywalls
- notifications
- seeded tips/help text
- App Store listing copy if it lives in-repo

## 4. Root Wiring

At the app root, inject the active language into:

- `\.locale`
- `\.calendar` when date behavior is language-driven
- `\.layoutDirection`

If the app supports in-app switching, the root must react immediately without requiring relaunch unless the product explicitly accepts that trade-off.

## 5. Derived Data Refresh

After language changes, reload or recompute:

- cached summaries
- chart labels
- month labels
- notification content scheduled from old strings
- seeded content loaded at startup
- tab labels or screen models built once

If user-facing text is computed in reducers or seed builders, treat that as localization surface area.

## 6. RTL And LTR Review

Use `rtl-review.md`.

## 7. Tests

Minimum regression coverage:

- language resolution defaults correctly
- persisted language rehydrates correctly
- numbers/dates/currency format correctly in Arabic and English
- changing language dispatches the expected app refresh path
- localized bundle lookup returns expected strings

If the repo includes long-running renderer tests or preview-host loops, use focused `xcodebuild` invocations. Do not wait on a known host loop and call that verification.
