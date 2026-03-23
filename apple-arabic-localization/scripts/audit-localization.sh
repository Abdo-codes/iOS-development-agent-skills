#!/bin/bash
# Audit an Apple app for common Arabic/English localization issues.
# Usage: audit-localization.sh [path-to-repo]
# Outputs a structured report of findings grouped by category.

REPO="${1:-.}"

echo "=== Localization Audit: $REPO ==="
echo ""

echo "## 1. Hard-coded Locale / Layout Direction"
rg -n 'Locale\(identifier:|\.rightToLeft|\.leftToRight|layoutDirection\s*=' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 2. Raw UI Strings in Swift (not localized)"
rg -n 'Text\("[A-Z]|navigationTitle\("[A-Z]|\.alert\("[A-Z]|Label\("[A-Z]' \
  --type swift "$REPO" 2>/dev/null | grep -v '\.strings' | head -40 || echo "  (none found)"
echo ""

echo "## 3. Notification / Reminder Copy"
rg -n 'UNMutableNotificationContent|\.title\s*=\s*"|\.body\s*=\s*"|scheduleNotification|reminderText' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 4. Custom Date/Number Formatters (may ignore active locale)"
rg -n 'DateFormatter\(\)|NumberFormatter\(\)|\.dateFormat\s*=|\.numberStyle\s*=' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 5. Directional Hardcoding (left/right instead of leading/trailing)"
rg -n '\.frame.*alignment:\s*\.(left|right)|HStack.*alignment:\s*\.(left|right)|padding\(\.(left|right)' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 6. Seeded / Hardcoded User-Facing Data"
rg -n 'seed|defaultData|sampleData|placeholder.*=.*"[A-Z]' \
  --type swift "$REPO" 2>/dev/null | head -20 || echo "  (none found)"
echo ""

echo "## 7. String Interpolation in Localized Strings (bidi risk)"
rg -n '\\(.*\)|%@|%d|%f' --type swift "$REPO" 2>/dev/null \
  | rg -v 'print\(|log\.|Log\.|debug\(|#if' | head -20 || echo "  (none found)"
echo ""

echo "## 8. Custom Images That May Need RTL Flipping"
rg -n 'UIImage\(named:|Image\("|\.renderingMode' --type swift "$REPO" 2>/dev/null \
  | rg -v 'SF|systemName|symbol' | head -20 || echo "  (none found)"
echo ""

echo "## 9. Localization Files Found"
find "$REPO" \( -name '*.strings' -o -name '*.xcstrings' -o -name '*.stringsdict' \) \
  -not -path '*/.*' 2>/dev/null || echo "  (none found)"
echo ""

echo "=== End Audit ==="
