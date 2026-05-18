#!/bin/bash
# Audit an Apple app repo for App Store review preflight risk areas.
# Usage: audit-app-store-preflight.sh [path-to-repo]
# Outputs a structured report of findings grouped by category.

set -o pipefail

REPO="${1:-.}"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required for this audit" >&2
  exit 1
fi

print_findings() {
  local title="$1"
  local pattern="$2"
  local limit="${3:-120}"

  echo "## $title"
  rg -n "$pattern" "$REPO" \
    --glob '!**/.git/**' \
    --glob '!**/DerivedData/**' \
    --glob '!**/Pods/**' \
    --glob '!**/.build/**' \
    2>/dev/null | head -"$limit" || echo "  (none found)"
  echo ""
}

print_files() {
  local title="$1"
  shift

  echo "## $title"
  local files
  files="$(find "$REPO" "$@" -not -path '*/.*' 2>/dev/null)"
  if [ -n "$files" ]; then
    echo "$files"
  else
    echo "  (none found)"
  fi
  echo ""
}

echo "=== App Store Review Preflight Audit: $REPO ==="
echo ""

print_findings "1. Placeholder, Debug, Test, Or Internal Build Signals" \
  'TODO|FIXME|lorem|placeholder|DEBUG|debugOnly|staging|mock|stub|beta|TestFlight|internal|sample account|test account' 160

print_findings "2. Permission Purpose Strings And Privacy Keys" \
  'NS[A-Za-z]+UsageDescription|NSUserTrackingUsageDescription|PrivacyInfo\.xcprivacy|ATTrackingManager|requestTrackingAuthorization|requestWhenInUseAuthorization|requestAlwaysAuthorization|requestAccess|AVCaptureDevice|PHPhotoLibrary|CNContactStore|CLLocationManager|CBPeripheralManager|CMMotionActivityManager|HKHealthStore|SFSpeechRecognizer|LAContext|LocalAuthentication' 180

print_findings "3. Privacy Policy, Terms, Support, And Data Deletion Links" \
  'privacy|Privacy Policy|terms|Terms of Use|support|delete account|account deletion|data deletion|User Privacy Choices|mailto:|https?://' 180

print_findings "4. StoreKit, IAP, Subscription, And Paywall Code" \
  'StoreKit|Product\.products|Transaction|AppStore\.sync|restore|purchase\(|subscription|auto-renew|trial|introductory|paywall|entitlement|SKProduct|SKPaymentQueue|RevenueCat|Purchases\.|SwiftyStoreKit' 180

print_findings "5. Login, Demo Account, Or Reviewer Access Gates" \
  'sign in|signin|login|log in|authentication|Auth|demo account|demo mode|reviewer|invite|waitlist|region locked|unsupported region|feature flag|remote config' 140

print_findings "6. External Purchase, Web, Or Account Management Links" \
  'SFSafariViewController|WKWebView|openURL|UIApplication\.shared\.open|Link\(|external link|web checkout|manage subscription|billing|checkout|payment|Stripe|PayPal' 140

print_files "7. App Store Metadata And Fastlane Files" \
  \( -path '*/fastlane/*' -o -path '*/metadata/*' -o -name 'Deliverfile' -o -name 'Appfile' -o -name 'metadata.xml' -o -name '*.strings' -o -name '*.xcstrings' \)

print_files "8. Xcode Projects, Plists, Privacy Manifests, And StoreKit Configs" \
  \( -name '*.xcodeproj' -o -name '*.xcworkspace' -o -name 'Info.plist' -o -name '*.entitlements' -o -name 'PrivacyInfo.xcprivacy' -o -name '*.storekit' \)

echo "=== End Audit ==="
