---
name: tvos-focus
description: This skill should be used when the user asks about "tvOS focus", "Apple TV navigation", "Siri Remote focus", "focusSection", "FocusState", "focus issues on tvOS", "focus chrome", "white bubble tvOS", "onMoveCommand", "onExitCommand", "focus trap", "tvOS button style", or mentions focus navigation problems on Apple TV. Provides tvOS focus system expertise with SwiftUI gotchas and patterns. NOT for iOS/iPadOS focus — tvOS only.
---

# tvOS Focus System

tvOS focus is spatial — the engine casts a ray from the focused element and picks the nearest focusable rectangle in the swipe direction. This is the ONLY interaction model on Apple TV. No touch, no cursor.

## Gotchas (the stuff Claude gets wrong)

These are real failures from production tvOS apps. Check these FIRST before writing focus code.

### 1. The White Bubble
ANY focusable element shows tvOS default focus chrome — even `Color.clear` with `.buttonStyle(.plain)`. The ONLY fix: a custom `ButtonStyle` that does zero visual changes. The card component must handle focus via `@Environment(\.isFocused)` itself.

### 2. Spacer() Kills Focus Navigation
A `Spacer()` between a card and buttons creates a non-focusable gap the engine cannot cross. Fix: use fixed `.padding()` or move buttons inside the card container.

### 3. Right-Aligned Buttons Skip Left-Aligned Content
When a stepper (right-aligned) is above name cards (left-aligned), pressing down skips the cards because no card rectangle intersects the downward ray from the stepper's position. Fix: wrap both in `.focusSection()`.

### 4. ScrollView Traps Focus
A horizontal `ScrollView` consumes ALL directional input. Down-swipe from inside it never reaches buttons below. Fix: `.focusSection()` on the ScrollView.

### 5. Focus Not Restored After Overlay
When an overlay closes, focus stays on nothing. Fix: save `focusedPlayerIndex` before overlay opens, restore via `.onChange(of: isOverlayVisible)`.

### 6. `.onMoveCommand` Doesn't Work on Buttons
Buttons consume move events internally. Place `.onMoveCommand` on a parent container, not on the button itself.

### 7. Invisible Buttons Still Get Focus
Even a 1x1px `Color.clear` button gets focus and shows chrome. To capture Select presses without a visible button, use `.onPlayPauseCommand` or `.onMoveCommand` on the page container instead.

## Key Modifiers (quick reference)

| Modifier | What It Does | Gotcha |
|----------|-------------|--------|
| `.focusSection()` | Groups elements — exhaust all before escape | Must be on a container, not on individual items |
| `.focused($binding, equals:)` | Programmatic focus tracking | Binding must match a focusable element or focus is nil |
| `.onMoveCommand { dir in }` | Intercepts directional input | Doesn't fire on Buttons — put on parent |
| `.onExitCommand { }` | Menu button handler | Only fires on the focused view's ancestor chain |
| `.disabled(true)` | Removes from focus chain | Use on background when overlay is open |
| `.buttonStyle(.plain)` | Minimal chrome | Still shows focus indicator — use custom style |

## Patterns That Work

### Onboarding page advance (no visible button)
Use `.onPlayPauseCommand` on the page container. Do NOT use an invisible Button.

### Paywall package cards + action buttons
Make action buttons FULL WIDTH so they're spatially below ALL package cards. Group cards with `.focusSection()`.

### Game grid (2D navigation)
Use `VStack { HStack { ForEach } }` with `.focused($binding, equals: index)`. The focus engine handles 2D navigation automatically from the grid geometry.

### Overlay capture/release
`.disabled(true)` on background content. `.onExitCommand` on the ZStack for Menu dismissal. Restore focus via `.onChange(of: isOverlayVisible)`.

## Before Shipping Checklist

- [ ] No default focus chrome visible (custom ButtonStyle on all interactive elements)
- [ ] Related controls grouped with `.focusSection()`
- [ ] Overlay captures focus (background `.disabled()`)
- [ ] Focus restores on overlay dismiss
- [ ] No `Spacer()` between interactive sections
- [ ] Test with arrow keys in tvOS simulator

## Additional Resources

For the complete 1,400-line guide with all code examples and detailed explanations:
- **`references/full-guide.md`** — Covers: spatial ray-casting model, all 9 SwiftUI focus modifiers, 7 pitfalls with solutions, 8 best practices, 5 UI-type patterns, testing approaches
