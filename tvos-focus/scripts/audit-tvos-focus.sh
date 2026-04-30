#!/bin/bash
# Audit a SwiftUI tvOS app for common focus navigation risk areas.
# Usage: audit-tvos-focus.sh [path-to-repo]
# Outputs a structured report of findings grouped by category.

set -o pipefail

REPO="${1:-.}"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required for this audit" >&2
  exit 1
fi

echo "=== tvOS Focus Audit: $REPO ==="
echo ""

echo "## 1. Focus APIs In Use"
rg -n 'FocusState|@FocusState|\.focused\(|\.focusSection\(|\.prefersDefaultFocus|\.defaultFocus|\.focusScope|\.focusEffect|\.focusable\(' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 2. Button Styles And Default Focus Chrome Hotspots"
rg -n 'ButtonStyle|\.buttonStyle\(\.plain\)|\.buttonStyle\(|@Environment\(\\\.isFocused\)|isFocused' \
  --type swift "$REPO" 2>/dev/null | head -120 || echo "  (none found)"
echo ""

echo "## 3. Invisible Or Clear Interactive Views"
rg -n 'Button\s*\{|Color\.clear|\.opacity\(0\)|\.hidden\(\)|\.frame\(width:\s*1|\.frame\(.*height:\s*1' \
  --type swift "$REPO" 2>/dev/null | head -120 || echo "  (none found)"
echo ""

echo "## 4. Spacer Gaps That May Break Spatial Navigation"
rg -n 'Spacer\(\)' --type swift "$REPO" 2>/dev/null | head -80 || echo "  (none found)"
echo ""

echo "## 5. ScrollViews That May Trap Directional Input"
rg -n 'ScrollView\(|LazyHStack|LazyVStack|\.scrollTarget|\.scrollPosition' \
  --type swift "$REPO" 2>/dev/null | head -120 || echo "  (none found)"
echo ""

echo "## 6. Directional Command Handlers"
rg -n '\.onMoveCommand|\.onExitCommand|\.onPlayPauseCommand|MoveCommandDirection|pressesBegan|UIPress' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 7. Overlay And Modal Focus Capture"
rg -n 'ZStack|overlay\(|fullScreenCover|sheet\(|popover\(|\.disabled\(|isPresented|isOverlay|showOverlay|dismiss' \
  --type swift "$REPO" 2>/dev/null | head -160 || echo "  (none found)"
echo ""

echo "## 8. Focus Restore After State Changes"
rg -n '\.onChange\(of:|DispatchQueue\.main\.async|Task\s*\{|focused[A-Za-z0-9_]*\s*=' \
  --type swift "$REPO" 2>/dev/null | head -120 || echo "  (none found)"
echo ""

echo "## 9. tvOS-Specific Files And Targets"
TVOS_FILES="$(find "$REPO" \( -name '*tvOS*' -o -name '*.xcodeproj' -o -name 'Package.swift' \) \
  -not -path '*/.*' 2>/dev/null)"
if [ -n "$TVOS_FILES" ]; then
  echo "$TVOS_FILES"
else
  echo "  (none found)"
fi
echo ""

echo "=== End Audit ==="
