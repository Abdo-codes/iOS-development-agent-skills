# Apple Localization Checklist

Use this checklist when implementing or reviewing Arabic/English localization in an Apple app.

## 1. Audit

Search for these patterns first:

- `Locale(identifier: "ar")`
- `Locale(identifier: "ar_SA")`
- `.rightToLeft`
- `.leftToRight`
- raw visible strings in Swift files
- notification title/body text
- seeded user-facing content
- custom number/date formatting helpers

Good search starters:

```bash
rg -n 'Locale\\(|rightToLeft|leftToRight|Text\\("|TextField\\("|navigationTitle\\("' <repo>
rg -n 'UNMutableNotificationContent|scheduleNotification|reminder|seed' <repo>
```

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
