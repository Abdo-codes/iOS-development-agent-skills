# Apple RTL Principles

Use Apple guidance as the primary source of truth for RTL behavior in iOS, iPadOS, and macOS apps.

## Core Rules

- Build semantically, not physically.
  Use start/end concepts such as `leading` and `trailing`, natural text alignment, and native navigation/list controls where possible. Avoid rebuilding directional behavior when the system already handles it.

- Do not assume everything should mirror.
  Some surfaces represent absolute or physical direction and often stay fixed: clocks, video timelines, many charts, maps, and non-directional brand imagery.

- Use semantic SF Symbols for navigation.
  Prefer `chevron.forward` and `chevron.backward` when the meaning is navigation or disclosure. Use `left` and `right` only when the meaning is truly spatial.

- Let standard controls do their job.
  UIKit and SwiftUI controls generally mirror correctly when locale and layout direction are configured properly. Extra flipping on top of system behavior often causes double inversions.

- Treat bidirectional text as a product surface.
  Arabic strings mixed with Latin names, phone numbers, IDs, percentages, and currency need deliberate checks. Rely on system bidi handling first, then add direction marks only for real edge cases.

- Test both a real locale and a stress locale.
  Review at least one real Arabic state and one English state. When possible, also use Apple pseudolanguages for RTL and string expansion.

## Practical Review Rules

- Review English and Arabic as separate UX states.
- Flag custom rows, cards, progress indicators, and swipe actions for manual review even if they use `leading` and `trailing`.
- Prefer native back buttons and list rows over hand-built directional affordances.
- Do not flip logos, product artwork, or other non-directional assets.

## Apple Sources

- Supporting Right-to-Left Languages
  https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/SupportingRight-To-LeftLanguages/SupportingRight-To-LeftLanguages.html
- Get it right (to left) - WWDC22
  https://developer.apple.com/videos/play/wwdc2022/10107/
- Design for Arabic - WWDC22
  https://developer.apple.com/videos/play/wwdc2022/110441/
- Build localization-friendly layouts using Xcode - WWDC20
  https://developer.apple.com/videos/play/wwdc2020/10219/
- Previewing localizations
  https://developer.apple.com/documentation/xcode/previewing-localizations/
- UIImage.flipsForRightToLeftLayoutDirection
  https://developer.apple.com/documentation/uikit/uiimage/flipsforrighttoleftlayoutdirection
