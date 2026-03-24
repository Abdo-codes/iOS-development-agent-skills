# tvOS Focus System: Comprehensive Guide for SwiftUI

> A practical reference for building tvOS apps with correct, predictable focus behavior.
> Written from real-world experience building Tally (a tvOS scoreboard app) and distilled
> from Apple's documentation, WWDC sessions, and community lessons.

---

## Table of Contents

1. [How the Focus Engine Works](#1-how-the-focus-engine-works)
2. [Key SwiftUI Modifiers](#2-key-swiftui-modifiers)
3. [Common Pitfalls](#3-common-pitfalls)
4. [Best Practices](#4-best-practices)
5. [Patterns for Specific UI Types](#5-patterns-for-specific-ui-types)
6. [Testing Focus](#6-testing-focus)

---

## 1. How the Focus Engine Works

### The Fundamental Difference

tvOS has no touch screen, no cursor, and no tap targets. The **only** way a user
interacts with your UI is through **focus** -- a single highlighted element at any
given time, moved by swiping on the Siri Remote's touch surface or pressing its
directional ring.

The Focus Engine is the system component that decides **which element gets focus
next** when the user swipes in a direction. You do not manually move focus in
response to swipes -- the engine does it for you based on geometry.

### Spatial Navigation Model

The Focus Engine uses a **geometric ray-casting** approach:

1. It takes an internal snapshot of all visible focusable rectangles on screen.
2. When the user swipes (e.g., right), it projects a ray from the currently focused
   element's rectangle in that direction.
3. It finds all focusable rectangles that intersect or are "close to" that ray.
4. It picks the **closest** candidate based on distance and alignment.

```
    ┌──────────┐
    │ Focused  │ ──── swipe right ────►  ┌──────────┐
    │  Button  │                          │  Next    │
    └──────────┘                          │  Button  │
                                          └──────────┘
```

This means:
- Elements that are **spatially aligned** are easy to navigate between.
- Elements with **large vertical or horizontal gaps** may be unreachable.
- The engine does **not** follow your view hierarchy -- it only sees rectangles.

### What Counts as "Focusable"

By default, these SwiftUI elements are focusable:
- `Button` (always focusable)
- `NavigationLink` (always focusable)
- `Toggle`, `Picker` (standard controls)
- Any view with `.focusable()` applied

Non-interactive views (`Text`, `Image`, `VStack`) are **not** focusable unless you
explicitly make them so.

### The Focus Chain (Preferred Focus)

When a new screen appears, the Focus Engine needs to determine which element gets
**initial focus**. It follows a chain:

1. The window asks its root view controller for its `preferredFocusEnvironments`.
2. That view controller points to a child view or a specific element.
3. The chain continues until it reaches an actual focusable element.

In SwiftUI, you control this with:
- `@FocusState` + `.onAppear { focusedItem = .someValue }`
- `.prefersDefaultFocus(in:)` for declarative default focus

### Focus Updates

Focus changes happen through a **focus update** cycle:

1. User swipes in a direction.
2. Focus Engine finds the next candidate.
3. `shouldUpdateFocus(in:)` is called (UIKit) -- you can deny the move.
4. `didUpdateFocus(in:with:)` fires on both the losing and gaining elements.
5. The system animates the transition.

In SwiftUI, you observe focus changes through `@FocusState` bindings and
`.onChange(of:)`.

---

## 2. Key SwiftUI Modifiers

### `.focusable()`

Makes a non-interactive view participate in the focus system.

**When to use:** When you need a `Text`, `Image`, or custom view to receive focus
without being a `Button`.

```swift
Text("Focusable label")
    .focusable()
    .onMoveCommand { direction in
        // Handle directional input while this view is focused
    }
```

**Caveat:** On tvOS, `.focusable()` alone gives you a default focus appearance
(the white "halo"). If you want custom focus styling, use a `Button` with a
custom `ButtonStyle` instead -- it gives you more control.

### `.focused($binding, equals:)`

Binds a specific view to a `@FocusState` property, letting you both **read** and
**write** the current focus programmatically.

**When to use:** Whenever you need to track which element is focused or set focus
programmatically (e.g., on appear, after an overlay dismisses).

```swift
enum GameButton: Hashable {
    case newGame, changeSport
}

@FocusState private var focusedButton: GameButton?

var body: some View {
    HStack {
        Button("New Game") { /* ... */ }
            .focused($focusedButton, equals: .newGame)

        Button("Change Sport") { /* ... */ }
            .focused($focusedButton, equals: .changeSport)
    }
    .onAppear {
        focusedButton = .newGame  // Set initial focus
    }
}
```

**Important:** The `@FocusState` value is `nil` when none of your tracked elements
have focus (e.g., focus is on a system alert or outside your tracked set). Setting
it to `nil` releases your programmatic focus claim, and the Focus Engine picks the
next element.

### `.focusSection()`

Creates a logical focus group. The entire container's frame becomes a "target zone"
for the Focus Engine, which then routes focus to the first focusable child inside.

**When to use:** When elements in different sections are not spatially aligned and
the Focus Engine skips over a group entirely.

```swift
VStack(spacing: 40) {
    // Score buttons section
    HStack {
        Button("+1") { }
        Button("+2") { }
        Button("+3") { }
    }
    .focusSection()  // This entire HStack is a single focus target

    // Action buttons section
    HStack {
        Button("Undo") { }
        Button("End Game") { }
    }
    .focusSection()  // Separate section -- down from score buttons lands here
}
```

**How it works internally:** Without `.focusSection()`, the Focus Engine looks at
individual button rectangles. A large gap between sections might cause the engine
to miss elements that are not directly aligned. With `.focusSection()`, the
container's **full frame** becomes the hit zone, so a downward swipe from any
button in the top section will land somewhere in the bottom section.

**Real-world example from Tally's ControlsOverlay:**

```swift
// Score buttons (per-player) in a horizontal ScrollView
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 12) {
        ForEach(players) { player in
            // Per-player score buttons
        }
    }
}
.focusSection()  // Groups all score buttons together

// Action buttons below
HStack(spacing: 12) {
    Button("Undo Score") { }
    Button("End Game") { }
}
.focusSection()  // Separate section for actions
```

### `.onMoveCommand(perform:)`

Intercepts directional swipes on the Siri Remote while the view (or its children)
has focus. The closure receives a `MoveCommandDirection` (.up, .down, .left, .right).

**When to use:** When you need custom navigation behavior that the Focus Engine
cannot provide (e.g., page advancement in onboarding, carousel wrapping).

```swift
.onMoveCommand { direction in
    switch direction {
    case .right, .down:
        advanceToNextPage()
    case .left, .up:
        goToPreviousPage()
    @unknown default:
        break
    }
}
```

**Caveat:** If a child view consumes the move command (e.g., a `ScrollView` scrolling
its content), your `.onMoveCommand` will not fire. The event is consumed by the
innermost handler first.

### `.onExitCommand(perform:)`

Fires when the user presses the **Menu** button on the Siri Remote while the view
has focus. This is tvOS's "back" gesture.

**When to use:** To dismiss overlays, navigate back, or show a confirmation before
leaving.

```swift
.onExitCommand {
    if isOverlayVisible {
        dismissOverlay()
    }
    // If you do nothing, the system's default behavior (pop navigation) happens
}
```

**Real-world example from Tally's GameView:**

```swift
.onExitCommand {
    if suppressNextMenuExit {
        // A long-press just fired; swallow this Menu release
        suppressNextMenuExit = false
    } else {
        store.send(.menuPressed)  // Toggle controls overlay
    }
}
```

### `.onPlayPauseCommand(perform:)`

Fires when the user presses the **Play/Pause** button on the Siri Remote.

**When to use:** For media controls, timer toggle, or as a secondary action.

```swift
.onPlayPauseCommand {
    store.send(.toggleTimer)
}
```

### `.prefersDefaultFocus(_:in:)`

Declaratively marks a view as the preferred initial focus target within a namespace.

**When to use:** When you want a specific button to receive focus when a screen appears,
without using `@FocusState` + `.onAppear`.

```swift
@Namespace private var screenNamespace

var body: some View {
    VStack {
        Button("Secondary") { }

        Button("Primary") { }
            .prefersDefaultFocus(true, in: screenNamespace)
    }
    .focusScope(screenNamespace)
}
```

### `.focusScope(_:)`

Limits the scope of `.prefersDefaultFocus()` to a specific view subtree.

**When to use:** Always pair with `.prefersDefaultFocus()`. Without a scope, the
preference applies globally, which can conflict with other screens.

```swift
@Namespace private var loginNamespace

VStack {
    TextField("Username", text: $username)
        .prefersDefaultFocus(username.isEmpty, in: loginNamespace)

    SecureField("Password", text: $password)

    Button("Login") { }
        .prefersDefaultFocus(!username.isEmpty, in: loginNamespace)
}
.focusScope(loginNamespace)
```

### `.disabled()` and Focus

A disabled view **cannot receive focus**. The Focus Engine skips it entirely.

**When to use:** To prevent interaction with elements during loading states, but
be aware that this changes focus flow.

```swift
Button("Start Game") { }
    .disabled(!hasLoadedPreferences)  // Cannot be focused until ready
```

**Gotcha:** If the currently focused element becomes disabled, focus jumps to the
nearest available element. This can be jarring if you are not careful.

**Pattern -- disable without losing focus position:**

```swift
// Instead of .disabled(), reduce opacity and ignore taps:
Button {
    guard isReady else { return }  // No-op when not ready
    startGame()
} label: {
    Text("Start Game")
        .opacity(isReady ? 1.0 : 0.4)
}
// The button stays focusable, preserving the user's position
```

---

## 3. Common Pitfalls

### Pitfall 1: The White Bubble (Default Focus Chrome)

**Problem:** Every `Button` on tvOS gets a default focus appearance -- a white/gray
rounded rectangle "bubble" behind it. If your button's label is transparent or has
custom styling, you get an ugly white blob behind your design.

**Solution:** Use a custom `ButtonStyle` that suppresses the default chrome:

```swift
struct TallyButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Custom scale effect replaces the default chrome
            .scaleEffect(configuration.isPressed ? 0.95 : isFocused ? 1.03 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
```

Then use `@Environment(\.isFocused)` in the button's **label view** for custom
focus styling:

```swift
struct FocusAwarePrimaryButton: View {
    let title: String
    @Environment(\.isFocused) var isFocused

    var body: some View {
        Text(title)
            .foregroundStyle(isFocused ? .white : Color.accentColor)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(isFocused ? Color.accentColor : Color.accentColor.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.accentColor : Color.accentColor.opacity(0.22), lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

// Usage:
Button(action: { }) {
    FocusAwarePrimaryButton(title: "Start Game")
}
.buttonStyle(.tally)  // Suppresses default chrome
```

**Key insight:** `@Environment(\.isFocused)` only works inside the button's label
view, not on the `Button` itself. Put your focus-aware styling in a separate view
used as the label.

### Pitfall 2: Focus Traps in ScrollView

**Problem:** A `ScrollView` with focusable children consumes all directional input
to scroll its content. Users cannot "escape" the scroll view by swiping down -- the
scroll view just scrolls more.

**Solution:** Use `.focusSection()` on the ScrollView or its content, so the Focus
Engine treats it as a bounded group. Also, ensure there are focusable elements
outside the scroll view for focus to escape to:

```swift
VStack(spacing: 20) {
    // Scrollable content
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
            ForEach(items) { item in
                Button(item.name) { }
            }
        }
    }
    .focusSection()  // Bounds focus within this section

    // Buttons below -- focus can escape here
    HStack {
        Button("Action A") { }
        Button("Action B") { }
    }
    .focusSection()
}
```

### Pitfall 3: Spatial Gaps Breaking Navigation

**Problem:** Large `Spacer()` or padding between sections causes the Focus Engine
to fail to find the next element, because the ray-cast misses distant targets.

```
    ┌──────┐
    │ Btn1 │
    └──────┘

         200pt gap (Spacer)

                     ┌──────┐
                     │ Btn2 │  <-- Not aligned, Focus Engine misses it
                     └──────┘
```

**Solution:** Use `.focusSection()` to expand the hit zone. The section's entire
frame becomes targetable:

```swift
VStack(spacing: 0) {
    HStack {
        Button("Top Left") { }
        Spacer()
    }
    .focusSection()

    Spacer()

    HStack {
        Spacer()
        Button("Bottom Right") { }
    }
    .focusSection()
}
```

### Pitfall 4: Focus Not Restoring After Overlay Dismissal

**Problem:** You show an overlay/sheet, then dismiss it. Focus does not return to
the element that was focused before the overlay appeared.

**Solution:** Save the focus state before showing the overlay, restore it after:

```swift
@FocusState private var focusedSide: Team?

.onChange(of: store.isOverlayVisible) { _, isVisible in
    if isVisible {
        // Release focus so overlay can receive it
        focusedSide = nil
    } else {
        // Restore focus to the team that was active before
        focusedSide = store.focusedTeam
    }
}
```

This pattern is critical for games where the user toggles a controls panel and
expects to return to exactly where they were.

### Pitfall 5: @FocusState Not Syncing with View State

**Problem:** You set `@FocusState` in `.onAppear`, but focus does not move. Or
you set it during an animation, and it gets ignored.

**Causes:**
- The target view is not yet in the view hierarchy when you set focus.
- The view is `.disabled()`, so it cannot receive focus.
- You are setting focus during a state update that also changes the view tree.

**Solution:** Delay focus assignment slightly if needed:

```swift
.onAppear {
    // Sometimes the view tree needs a layout pass first
    DispatchQueue.main.async {
        focusedButton = .newGame
    }
}
```

Or use `.task` which runs after the view appears:

```swift
.task {
    focusedButton = .newGame
}
```

### Pitfall 6: Mixing Focus Systems

**Problem:** Using both `@FocusState` (SwiftUI) and UIKit's `UIFocusSystem` in
the same view hierarchy creates conflicts. The system recognizes only the last
operation's focus as the "real" one, and you can end up with two highlighted
elements simultaneously.

**Solution:** Pick one system per screen. If you are in SwiftUI, use `@FocusState`.
If you need UIKit's focus system (e.g., for `UICollectionView`), wrap it in
`UIViewRepresentable` and manage focus entirely within that UIKit view.

### Pitfall 7: ButtonStyle Breaking ScrollView Behavior

**Problem:** Custom `ButtonStyle` implementations that apply transforms or padding
changes can interfere with ScrollView's focus-based scrolling. Items may be hidden
behind pinned headers or the scroll position may jump unexpectedly.

**Solution:** Keep your ButtonStyle transforms minimal. Use `scaleEffect` and
`opacity` only -- avoid changing `frame`, `padding`, or `offset` in the ButtonStyle:

```swift
struct SafeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            // Do NOT change frame, padding, or offset here
    }
}
```

---

## 4. Best Practices

### 4.1 Group Related Elements with focusSection

Every distinct "zone" in your UI should be a focus section. This ensures
predictable navigation between zones:

```swift
VStack(spacing: 32) {
    // Zone 1: Team names
    HStack {
        teamNameButton(for: .team1)
        Text("vs")
        teamNameButton(for: .team2)
    }
    .focusSection()

    Divider()

    // Zone 2: Sport options (steppers, pickers)
    VStack {
        stepperRow(label: "Quarter Length", ...)
    }
    .focusSection()

    Divider()

    // Zone 3: Action buttons
    HStack {
        Button("Back") { }
        Button("Start Game") { }
    }
    .focusSection()
}
```

### 4.2 Handle Overlays and Modals

When showing an overlay, you must:
1. Release focus from the underlying content
2. Set focus to the overlay's first element
3. Trap focus within the overlay (prevent it from escaping to content behind)
4. Restore focus when the overlay dismisses

**Complete overlay focus pattern:**

```swift
struct GameView: View {
    @FocusState private var focusedSide: Team?
    @Bindable var store: StoreOf<GameFeature>

    var body: some View {
        ZStack {
            // Game content
            HStack {
                teamButton(.team1)
                    .focused($focusedSide, equals: .team1)
                    .disabled(store.isOverlayVisible)  // Prevent focus on content

                teamButton(.team2)
                    .focused($focusedSide, equals: .team2)
                    .disabled(store.isOverlayVisible)
            }
            .focusSection()
            .opacity(store.isOverlayVisible ? 0.3 : 1.0)

            // Overlay
            if store.isOverlayVisible {
                ControlsOverlay(store: store)
                // Overlay manages its own @FocusState internally
            }
        }
        .onChange(of: store.isOverlayVisible) { _, isVisible in
            if isVisible {
                focusedSide = nil  // Release focus to overlay
            } else {
                focusedSide = store.focusedTeam  // Restore
            }
        }
        .onExitCommand {
            store.send(.menuPressed)  // Toggle overlay
        }
    }
}
```

**Inside the overlay**, set initial focus on appear:

```swift
struct ControlsOverlay: View {
    @FocusState private var focusedAction: ActionButton?

    var body: some View {
        VStack {
            // ... overlay content ...
            Button("Undo") { }
                .focused($focusedAction, equals: .undo)
        }
        .onAppear {
            focusedAction = .undo  // First button gets focus
        }
    }
}
```

### 4.3 Restore Focus After Navigation Transitions

When navigating between screens (e.g., sport picker -> setup -> game), remember
the user's last focused element:

```swift
struct SportPickerView: View {
    @FocusState private var focusedSport: SportType?
    var store: StoreOf<SportPickerFeature>

    var body: some View {
        // Sport grid ...
        .onAppear {
            // Restore focus to the last-used sport
            focusedSport = store.selectedSport
        }
        .onChange(of: store.selectedSport) { _, newSport in
            focusedSport = newSport
        }
    }
}
```

### 4.4 Create Custom Focus Indicators

Instead of relying on the default white chrome, build your own focus indicators
using `@Environment(\.isFocused)` in label views:

**Pattern: Focus-aware card with colored border and glow:**

```swift
struct SportCard: View {
    let sport: SportType
    @Environment(\.isFocused) var isFocused

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: sport.iconName)
                .foregroundStyle(isFocused ? Color.accentColor : Color.secondary)

            Text(sport.displayName)
                .foregroundStyle(isFocused ? Color.primary : Color.primary.opacity(0.78))
        }
        .frame(width: 190, height: 190)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isFocused ? Color.accentColor : Color(.separator),
                    lineWidth: isFocused ? 3 : 0.5
                )
        )
        .shadow(
            color: isFocused ? .black.opacity(0.10) : .black.opacity(0.04),
            radius: isFocused ? 26 : 14,
            y: isFocused ? 14 : 8
        )
        .brightness(isFocused ? 0.05 : 0)
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
```

### 4.5 Handle Horizontal Scrolling Content

For horizontally scrolling shelves (like Netflix-style rows):

```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: 16) {
        ForEach(items) { item in
            Button { select(item) } label: {
                ItemCard(item: item)
            }
            .buttonStyle(.card)
        }
    }
    .padding(.horizontal, 48)
}
.focusSection()
```

**Tips:**
- Use `LazyHStack` for performance with many items.
- Add `.padding(.horizontal)` so the first/last items are not flush against the edge.
- Always apply `.focusSection()` so the row acts as a single navigation target from
  rows above/below.

### 4.6 Handle Two-Column Layouts

For side-by-side content (like a scoreboard with Team 1 and Team 2):

```swift
HStack(spacing: 0) {
    Button {
        score(.team1)
    } label: {
        TeamColumn(team: .team1, isFocused: focusedSide == .team1)
    }
    .buttonStyle(.tally)
    .focused($focusedSide, equals: .team1)

    CenterDivider()

    Button {
        score(.team2)
    } label: {
        TeamColumn(team: .team2, isFocused: focusedSide == .team2)
    }
    .buttonStyle(.tally)
    .focused($focusedSide, equals: .team2)
}
.focusSection()
```

The `.focusSection()` on the `HStack` ensures the two sides are treated as one
navigation group, and left/right swipes move between them predictably.

### 4.7 Prevent Focus from Escaping a Modal

When presenting a modal overlay, disable all focusable elements behind it:

```swift
ZStack {
    // Background content
    MainContent()
        .disabled(isModalShowing)  // Removes from focus system entirely

    // Modal
    if isModalShowing {
        ModalContent()
    }
}
```

If `.disabled()` is too aggressive (e.g., it resets scroll position), use a
transparent overlay that captures focus:

```swift
ZStack {
    MainContent()
        .opacity(isModalShowing ? 0.3 : 1.0)

    if isModalShowing {
        // Invisible focus barrier
        Color.clear
            .contentShape(Rectangle())
            .focusable()

        // Actual modal
        ModalContent()
    }
}
```

### 4.8 Make Action Buttons Full-Width for Focus Reachability

A common issue: narrow buttons at the bottom of a form are hard to reach from
wide content above because they are not spatially aligned.

**Fix:** Make action buttons span the full width:

```swift
// Instead of:
HStack {
    Button("Back") { }  // Narrow, left-aligned
    Button("Start") { }  // Narrow, right-aligned
}

// Use:
HStack(spacing: 0) {
    Button { goBack() } label: {
        SecondaryButton(title: "Back")
            .frame(maxWidth: .infinity)  // Full width of half
    }
    .buttonStyle(.tally)

    Button { startGame() } label: {
        PrimaryButton(title: "Start Game")
            .frame(maxWidth: .infinity)  // Full width of half
    }
    .buttonStyle(.tally)
}
```

This ensures the Focus Engine always finds a target when swiping down from
any position in the content above.

---

## 5. Patterns for Specific UI Types

### 5.1 Onboarding Pages (Advancing Without Visible Buttons)

For swipe-to-advance onboarding where the user does not need visible next/back buttons:

```swift
struct OnboardingView: View {
    @State private var currentPage = 0
    @FocusState private var focusedItem: FocusItem?

    private enum FocusItem: Hashable {
        case continueButton
    }

    var body: some View {
        TabView(selection: $currentPage) {
            WelcomePage().tag(0)
            FeaturesPage().tag(1)
            PaywallPage().tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onMoveCommand { direction in
            if direction == .right || direction == .down {
                advancePage()
            }
        }
        .onPlayPauseCommand {
            advancePage()
        }
        .onChange(of: currentPage) { _, newPage in
            // Reset focus for each page
            if newPage < 2 {
                focusedItem = .continueButton
            }
        }
    }

    // An invisible-but-focusable button anchors focus on each page
    private var pageAdvanceButton: some View {
        Button(action: advancePage) {
            FocusAwareSecondaryButton(title: "Continue")
        }
        .buttonStyle(.tally)
        .focused($focusedItem, equals: .continueButton)
    }

    private func advancePage() {
        if currentPage < 2 {
            currentPage += 1
        }
    }
}
```

**Key insight:** Even though you want "invisible" navigation, you still need a
focusable element on each page. Without one, the Focus Engine has nothing to
attach to, and remote input is lost. Use a subtle "Continue" button at the bottom
of each page.

### 5.2 Paywall (Package Cards + Action Buttons)

A paywall has two focus zones: package selection cards and action buttons below.

```swift
struct PaywallView: View {
    @Bindable var store: StoreOf<SubscriptionFeature>

    var body: some View {
        VStack(spacing: 26) {
            // Header (non-focusable)
            PaywallHeader()

            // Package cards -- each is a Button with CardButtonStyle
            HStack(spacing: 18) {
                ForEach(store.packages) { package in
                    Button {
                        store.send(.packageSelected(package.id))
                    } label: {
                        PackageCard(
                            package: package,
                            isSelected: store.selectedPackageID == package.id
                        )
                    }
                    .buttonStyle(.tallyCard)
                }
            }
            // No .focusSection() needed -- the HStack has no gap issues

            // Action buttons
            VStack(spacing: 14) {
                Button("Subscribe") { store.send(.purchaseTapped) }
                    .disabled(store.selectedPackageID == nil)

                Button("Restore Purchases") { store.send(.restoreTapped) }

                Button("Maybe Later") { onSkip() }
            }
        }
    }
}
```

**Focus-select pattern for cards:** When a package card receives focus, also
select it -- this way the user only needs to swipe to a card, not swipe then click:

```swift
struct PackageCard: View {
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        // ... card content ...
        .onChange(of: isFocused) { _, newValue in
            if newValue {
                onFocusChanged(true)
                // Optionally auto-select on focus
            }
        }
    }
}
```

### 5.3 Settings Screens (Grouped Rows with Steppers)

tvOS has no `Slider`, so settings use button-based steppers. Each row is a
label + minus button + value + plus button:

```swift
struct SettingsView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Section 1
            VStack {
                stepperRow("Quarter Length", value: $quarterMinutes, range: 4...20, unit: "min")
            }
            .focusSection()

            Divider()

            // Section 2
            VStack {
                choicePicker("Best of", options: [3, 5, 7], value: $bestOf)
            }
            .focusSection()

            Divider()

            // Section 3: Action buttons
            HStack(spacing: 16) {
                Button("Back") { }
                Button("Start") { }
            }
            .focusSection()
        }
    }

    private func stepperRow(
        _ label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {
        HStack {
            Text(label)
            Spacer()

            Button { if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 } }
            label: { StepperButton(icon: "minus") }
            .buttonStyle(.tally)

            Text("\(value.wrappedValue) \(unit)")
                .frame(minWidth: 80)
                .monospacedDigit()

            Button { if value.wrappedValue < range.upperBound { value.wrappedValue += 1 } }
            label: { StepperButton(icon: "plus") }
            .buttonStyle(.tally)
        }
    }
}
```

**Focus-aware stepper button:**

```swift
struct StepperButton: View {
    let icon: String
    @Environment(\.isFocused) var isFocused

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(isFocused ? .white : .secondary)
            .frame(width: 44, height: 44)
            .background(isFocused ? Color.accentColor : Color(.systemGray5))
            .clipShape(Circle())
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
```

### 5.4 Game Grids (2D Navigation in Player Cells)

For a multi-player grid where each cell is a focusable button:

```swift
struct PartyGridView: View {
    @FocusState private var focusedPlayer: Int?

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < players.count {
                            Button {
                                scorePlayer(index)
                            } label: {
                                PlayerCell(
                                    player: players[index],
                                    isFocused: focusedPlayer == index
                                )
                            }
                            .buttonStyle(.tally)
                            .focused($focusedPlayer, equals: index)
                            .disabled(isOverlayVisible)
                        } else {
                            EmptyCell()  // Placeholder for odd player counts
                        }
                    }
                }
            }
        }
        .focusSection()
        .onAppear {
            focusedPlayer = 0  // Focus first player on appear
        }
    }
}
```

**Grid navigation works naturally** because cells are spatially aligned. The Focus
Engine handles up/down/left/right movement between grid cells without any custom
`onMoveCommand` logic.

### 5.5 Overlays (Controls Panel That Captures Focus)

A controls overlay needs to:
1. Appear with a specific element focused
2. Prevent focus from leaking to the game behind it
3. Dismiss on Menu press
4. Restore game focus after dismissal

```swift
struct ControlsOverlay: View {
    @FocusState private var focusedAction: ActionButton?

    private enum ActionButton: Hashable {
        case undo, timer, endGame
    }

    var body: some View {
        VStack(spacing: 16) {
            // Score section
            HStack {
                ForEach(players) { player in
                    ForEach(pointValues, id: \.self) { value in
                        Button("+\(value)") { score(player, value) }
                    }
                }
            }
            .focusSection()

            // Action section
            HStack {
                Button("Undo") { undo() }
                    .focused($focusedAction, equals: .undo)
                Button("Timer") { toggleTimer() }
                    .focused($focusedAction, equals: .timer)
                Button("End Game") { endGame() }
                    .focused($focusedAction, equals: .endGame)
            }
            .focusSection()
        }
        .onAppear {
            focusedAction = .undo  // Always start on Undo
        }
    }
}
```

---

## 6. Testing Focus

### 6.1 Simulator Testing

The tvOS Simulator accepts keyboard input mapped to the Siri Remote:

| Keyboard Key     | Siri Remote Action     |
|-----------------|------------------------|
| Arrow keys       | Directional swipes     |
| Return / Enter   | Select (click)         |
| Escape           | Menu (back)            |
| Space            | Play/Pause             |

**Tips:**
- Watch for the focus indicator (your custom highlight) moving between elements.
- Test all four directions from every focusable element.
- Verify that focus does not get "trapped" in ScrollViews or sections.
- Test overlay show/dismiss cycles to verify focus restoration.

### 6.2 UI Testing with XCUIRemote

XCUITest provides `XCUIRemote.shared` for programmatic remote control input:

```swift
import XCTest

final class FocusTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Basic Remote Commands

    func testBasicNavigation() {
        let remote = XCUIRemote.shared

        remote.press(.right)      // Swipe right
        remote.press(.left)       // Swipe left
        remote.press(.up)         // Swipe up
        remote.press(.down)       // Swipe down
        remote.press(.select)     // Click (select)
        remote.press(.menu)       // Menu (back)
        remote.press(.playPause)  // Play/Pause

        // Long press (e.g., for rewinding)
        remote.press(.select, forDuration: 2.0)
    }

    // MARK: - Checking Focus

    func testElementHasFocus() {
        let startButton = app.buttons["Start Game"]
        XCTAssertTrue(startButton.hasFocus, "Start button should have initial focus")
    }

    // MARK: - Navigating to a Specific Element

    func testNavigateToEndGame() {
        let endGameButton = app.buttons["End Game"]

        // Navigate down to action buttons, then right to End Game
        for _ in 0..<5 {
            if endGameButton.hasFocus { break }
            XCUIRemote.shared.press(.down)
            usleep(400_000)  // Small delay for focus animation
        }

        for _ in 0..<3 {
            if endGameButton.hasFocus { break }
            XCUIRemote.shared.press(.right)
            usleep(400_000)
        }

        XCTAssertTrue(endGameButton.hasFocus)
    }
}
```

### 6.3 Common Focus Test Patterns

**Pattern 1: Grid Navigation Test**

Verify that a 2D grid can be fully navigated:

```swift
func testGridNavigation() {
    let grid = PartyGridPage(app: app)

    // Verify initial focus
    XCTAssertTrue(grid.focusedPlayerLabel()?.contains("Player 1") == true)

    // Navigate the full grid: right -> down -> left -> up
    grid.navigateRight()
    XCTAssertTrue(grid.focusedPlayerLabel()?.contains("Player 2") == true)

    grid.navigateDown()
    XCTAssertTrue(grid.focusedPlayerLabel()?.contains("Player 4") == true)

    grid.navigateLeft()
    XCTAssertTrue(grid.focusedPlayerLabel()?.contains("Player 3") == true)

    grid.navigateUp()
    XCTAssertTrue(grid.focusedPlayerLabel()?.contains("Player 1") == true)
}
```

**Pattern 2: Overlay Focus Capture and Release**

Verify that focus is captured by the overlay and restored after dismissal:

```swift
func testOverlayFocusCycle() {
    let grid = PartyGridPage(app: app)

    // Score Player 1
    grid.scoreCurrentPlayer()
    XCTAssertTrue(grid.focusedPlayerLabel()?.contains("Player 1") == true)

    // Open overlay
    let overlay = grid.openControls()
    XCTAssertTrue(overlay.isVisible)

    // Verify overlay has focus (grid buttons should not have focus)
    // The overlay's first action button should be focused

    // Dismiss overlay
    let gridAfter = overlay.dismiss()
    XCTAssertTrue(overlay.isDismissed)

    // Focus should restore to Player 1
    XCTAssertTrue(gridAfter.focusedPlayerLabel()?.contains("Player 1") == true)
}
```

**Pattern 3: Focus Flow Through Sections**

Verify that focus can traverse all sections of a setup screen:

```swift
func testSetupFocusFlow() {
    let setup = PartySetupPage(app: app)

    // Start at player count stepper
    XCTAssertTrue(setup.playersLabel.exists)

    // Navigate down through all sections
    XCUIRemote.shared.press(.down)
    sleep(1)
    // Should be in player cards section

    XCUIRemote.shared.press(.down)
    sleep(1)
    // Should be in options section

    XCUIRemote.shared.press(.down)
    sleep(1)
    // Should be in action buttons

    XCTAssertTrue(
        setup.startGameButton.hasFocus || setup.backButton.hasFocus,
        "Focus should reach action buttons"
    )
}
```

**Pattern 4: Alert Focus Navigation**

tvOS alerts have their own focus system. Navigate to specific alert buttons:

```swift
func testAlertFocusNavigation() {
    // Trigger an alert (e.g., End Game confirmation)
    XCUIRemote.shared.press(.select)
    sleep(1)

    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 3))

    let destructiveButton = alert.buttons["End Game"]
    let cancelButton = alert.buttons["Cancel"]

    // Alert focus can land on either button -- navigate to the one we want
    if !destructiveButton.hasFocus {
        // Try all directions to find the right button
        for direction: XCUIRemoteButton in [.left, .right, .up, .down] {
            XCUIRemote.shared.press(direction)
            usleep(400_000)
            if destructiveButton.hasFocus { break }
        }
    }

    XCTAssertTrue(destructiveButton.hasFocus)
    XCUIRemote.shared.press(.select)
}
```

**Pattern 5: Page Object Model for Focus Testing**

Encapsulate focus navigation logic in page objects:

```swift
final class PartyGridPage {
    let app: XCUIApplication

    func scoreCurrentPlayer() {
        XCUIRemote.shared.press(.select)
        sleep(1)
    }

    func navigateRight() {
        XCUIRemote.shared.press(.right)
        sleep(1)
    }

    func focusedPlayerLabel() -> String? {
        app.buttons.allElementsBoundByIndex
            .first(where: { $0.hasFocus })?
            .label
    }

    @discardableResult
    func openControls() -> ControlsOverlayPage {
        XCUIRemote.shared.press(.menu)
        sleep(1)
        return ControlsOverlayPage(app: app)
    }
}
```

### 6.4 Focus Testing Checklist

For every screen in your tvOS app, verify:

- [ ] **Initial focus:** Correct element is focused on appear.
- [ ] **All directions:** Every focusable element can be reached via directional navigation.
- [ ] **No dead ends:** No element exists where all four directions lead nowhere.
- [ ] **No traps:** Focus can always escape ScrollViews and sections.
- [ ] **Overlay cycle:** Overlay captures focus, dismissal restores it.
- [ ] **Disabled state:** Disabled elements are skipped; focus jumps correctly.
- [ ] **Alert handling:** Alert buttons can be navigated and selected.
- [ ] **Edge cases:** Odd player counts, empty states, loading states.

---

## Quick Reference Card

| Task | Modifier / API |
|------|---------------|
| Make a view focusable | `.focusable()` or use `Button` |
| Track/set focus | `@FocusState` + `.focused($binding, equals:)` |
| Group elements for navigation | `.focusSection()` |
| Set initial focus declaratively | `.prefersDefaultFocus(true, in: namespace)` |
| Limit focus scope | `.focusScope(namespace)` |
| Handle directional input | `.onMoveCommand { direction in }` |
| Handle Menu button | `.onExitCommand { }` |
| Handle Play/Pause button | `.onPlayPauseCommand { }` |
| Suppress default focus chrome | Custom `ButtonStyle` |
| Read focus state in label | `@Environment(\.isFocused)` |
| Test focus in UI tests | `XCUIRemote.shared.press(.direction)` |
| Check focus in UI tests | `element.hasFocus` |

---

## Sources

- [Apple: About Focus Interactions for Apple TV](https://developer.apple.com/documentation/uikit/focus-based_navigation/about_focus_interactions_for_apple_tv)
- [Apple: FocusState Documentation](https://developer.apple.com/documentation/swiftui/focusstate)
- [Apple: focusSection() Documentation](https://developer.apple.com/documentation/swiftui/view/focussection())
- [Apple: prefersDefaultFocus(_:in:) Documentation](https://developer.apple.com/documentation/swiftui/view/prefersdefaultfocus(_:in:))
- [Apple: onExitCommand(perform:) Documentation](https://developer.apple.com/documentation/swiftui/view/onexitcommand(perform:))
- [Apple: Focus and Selection HIG](https://developer.apple.com/design/human-interface-guidelines/focus-and-selection)
- [Apple: Build SwiftUI apps for tvOS (WWDC20)](https://developer.apple.com/videos/play/wwdc2020/10042/)
- [Apple: Direct and reflect focus in SwiftUI (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10023/)
- [Apple: The SwiftUI cookbook for focus (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10162/)
- [Airbnb Engineering: Mastering the tvOS Focus Engine](https://medium.com/airbnb-engineering/mastering-the-tvos-focus-engine-f8a13b371083)
- [Surviving tvOS - An Engineering Log of an Atypical Media Player](https://fatbobman.com/en/posts/surviving-tvos/)
- [SwiftUI focusSection - UIFocusGuide Alternative](https://developerinsider.co/swiftui-focussection-uifocusguide-alternative-for-swiftui/)
- [Handling Focus in Apple TV Apps with SwiftUI](https://www.tothenew.com/blog/how-to-control-focus-in-swiftui-for-apple-tv-apps/)
- [Focus Management in SwiftUI (Swift with Majid)](https://swiftwithmajid.com/2020/12/02/focus-management-in-swiftui/)
- [Automating Apple TV Apps (XCUIRemote)](https://alexilyenko.github.io/apple-tv-automated-tests/)
