# RTL Review

Arabic localization must be reviewed as an RTL product state, not just translated text.

## Layout

- Prefer `leading` and `trailing` over `left` and `right`
- Check list rows, settings rows, cards, sheets, and tab bars in both Arabic and English
- Make sure sheet and modal headers anchor correctly in Arabic
- Ensure text fields and labels feel intentional, not centered by accident

## Icons And Directional Affordances

- Use semantic directional SF Symbols when possible:
  - `chevron.forward`
  - `chevron.backward`
- Avoid baking in “left means back” assumptions
- Recheck any custom back/next buttons, disclosure rows, and carousel controls in both locales

## Mixed Content And Bidirectional Text

- Check sign placement, units, and short values with real data
- Negative amounts, percentages, and compact summaries should read naturally in each locale
- Dates and times should follow the active language conventions consistently
- When a localized string starts with a variable (e.g., a user name), insert `\u{200F}` (RLM) before the variable in Arabic strings or `\u{200E}` (LRM) in English strings to prevent direction inheritance
- Wrap phone numbers and numeric IDs in Arabic text with `\u{202A}` (LRE) and `\u{202C}` (PDF) to preserve LTR display
- Arabic digits (٠١٢) will break server-side parsing — use `Locale(identifier: "en")` for any formatter feeding APIs or storage

## Forms

- Input labels, placeholders, and entered values must still read clearly when the app switches language
- Review keyboard types and alignment for numeric fields
- Check segmented controls and pickers in Arabic and English

## Visual Pass

Perform at least one pass in Arabic and one in English for:

- onboarding
- main navigation
- empty states
- sheets/modals
- settings
- key detail screens
- any feature touched by cached or derived localized content

Do not ship after an Arabic-only pass. Many RTL fixes quietly regress English.
