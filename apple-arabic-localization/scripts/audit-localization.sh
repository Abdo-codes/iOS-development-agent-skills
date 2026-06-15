#!/bin/bash
# Audit an Apple app for common Arabic/English localization issues.
# Usage: audit-localization.sh [path-to-repo]
# Outputs a structured report of findings grouped by category.

set -o pipefail

REPO="${1:-.}"

echo "=== Localization Audit: $REPO ==="
echo ""

echo "## 1. Hard-coded Locale / Layout Direction"
rg -n 'Locale\(identifier:|\.rightToLeft|\.leftToRight|layoutDirection\s*=|semanticContentAttribute|UISemanticContentAttribute' \
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

echo "## 5. Active Language Source / In-App Switch Hotspots"
rg -n '@AppStorage|UserDefaults|Bundle\.main|Bundle\(path:|Locale\.current|Locale\.autoupdatingCurrent|AppleLanguages|languageCode|selectedLanguage|appLanguage|currentLanguage|setLanguage|changeLanguage' \
  --type swift "$REPO" 2>/dev/null | head -120 || echo "  (none found)"
echo ""

echo "## 6. RTL/LTR Direction Hotspots To Review (not always bugs)"
rg -n '\.(leading|trailing)\b|alignment:\s*\.(leading|trailing)|edge:\s*\.(leading|trailing)|move\(edge:\s*\.(leading|trailing)|swipeActions\(edge:\s*\.(leading|trailing)|chevron\.(forward|backward|left|right)' \
  --type swift "$REPO" 2>/dev/null | head -120 || echo "  (none found)"
echo ""

echo "## 7. Physical Left/Right Hardcoding"
rg -n '\.frame.*alignment:\s*\.(left|right)|HStack.*alignment:\s*\.(left|right)|padding\(\.(left|right)|chevron\.(left|right)' \
  --type swift "$REPO" 2>/dev/null || echo "  (none found)"
echo ""

echo "## 8. Seeded / Hardcoded User-Facing Data"
rg -n 'seed|defaultData|sampleData|placeholder.*=.*"[A-Z]' \
  --type swift "$REPO" 2>/dev/null | head -20 || echo "  (none found)"
echo ""

echo "## 9. String Interpolation in Localized Strings (bidi risk)"
rg -n '\\(.*\)|%@|%d|%f' --type swift "$REPO" 2>/dev/null \
  | rg -v 'print\(|log\.|Log\.|debug\(|#if' | head -20 || echo "  (none found)"
echo ""

echo "## 10. Custom Images That May Need RTL Flipping"
rg -n 'UIImage\(named:|Image\("|\.renderingMode|flipsForRightToLeftLayoutDirection|imageFlipsForRightToLeftLayoutDirection' --type swift "$REPO" 2>/dev/null \
  | rg -v 'SF|systemName|symbol' | head -20 || echo "  (none found)"
echo ""

echo "## 11. Localization Files Found"
LOCALIZATION_FILES="$(find "$REPO" \( -name '*.strings' -o -name '*.xcstrings' -o -name '*.stringsdict' \) \
  -not -path '*/.*' 2>/dev/null)"
if [ -n "$LOCALIZATION_FILES" ]; then
  echo "$LOCALIZATION_FILES"
else
  echo "  (none found)"
fi
echo ""

echo "=== End Audit ==="
