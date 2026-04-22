# RTL Review

Arabic localization must be reviewed as an RTL product state, not just translated text.

## Review Order

1. Run the static audit first with `scripts/audit-localization.sh <repo-path>`.
2. Perform a live English pass and a live Arabic pass.
3. Group findings into shared primitives, navigation affordances, screen-specific layout bugs, and formatting/bidi bugs.
4. Fix shared primitives before patching repeated issues screen by screen.
5. Re-run the live pass and snapshot coverage after fixes.

## Live Pass

Use the best available tooling in this order:

- existing Maestro flows, if they run in the environment
- XcodeBuildMCP or simulator automation
- manual simulator review as a fallback

Capture screenshots or accessibility snapshots for both locales. Do not rely on code search alone for visual RTL work.

## Layout

- Prefer `leading` and `trailing` over `left` and `right`
- Check list rows, settings rows, cards, sheets, and tab bars in both Arabic and English
- Make sure sheet and modal headers anchor correctly in Arabic
- Ensure text fields and labels feel intentional, not centered by accident
- Review custom rows that combine text, `Spacer()`, badges, and disclosure icons. These are the most common false positives where code looks "semantic" but still renders wrong in one direction.

## Icons And Directional Affordances

- Use semantic directional SF Symbols when possible:
  - `chevron.forward`
  - `chevron.backward`
- Avoid baking in “left means back” assumptions
- Recheck any custom back/next buttons, disclosure rows, and carousel controls in both locales
- Review progress bars, carousels, swipe actions, and transitions separately. These often need an explicit decision about whether they mirror or stay fixed.

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
- Review date fields and custom picker chrome carefully. These often pin icons or text to one side even when the rest of the form flips.

## Visual Pass

Perform at least one pass in Arabic and one in English for:

- onboarding
- main navigation
- empty states
- sheets/modals
- settings
- key detail screens
- any feature touched by cached or derived localized content

Prioritize these custom surfaces:

- design-system fields and rows
- home/dashboard cards
- schedule or timeline screens
- progress indicators
- disclosure rows
- add/edit forms
- settings and preference lists

Do not ship after an Arabic-only pass. Many RTL fixes quietly regress English.

## Verification

- Add or expand snapshot coverage in both locales for shared primitives and highest-traffic screens.
- Re-run the same simulator flow after fixes instead of validating only on fresh app launch.
- If one automation tool is unavailable, continue with the next-best option instead of blocking the audit.
