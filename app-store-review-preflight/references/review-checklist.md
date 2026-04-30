# App Review Preflight Checklist

Use this checklist before upload or when triaging a likely App Review rejection.

Primary Apple references:

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- App Store Connect app privacy help: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy

## Completeness

- App launches cleanly on supported OS versions and devices.
- Core user flows are complete, not hidden behind unfinished flags or empty states.
- Placeholder copy, lorem ipsum, fake buttons, test screens, and debug controls are removed.
- All URLs in the app and metadata are functional.
- Login-gated apps include demo credentials or an approved demo mode in review notes.
- Server-backed features have production or review-ready backend data.
- Hardware, entitlement, region, or account requirements are documented for reviewers.

## Metadata Accuracy

- App name, subtitle, screenshots, previews, description, and keywords describe the actual shipped experience.
- Screenshots do not show features missing from the binary.
- "What's New" accurately describes user-visible changes.
- Age rating, content warnings, and App Store category match the product.
- Support URL, marketing URL, and privacy policy URL are live and public.

## Review Notes

Include concise notes for:

- Demo account username and password.
- Steps to reach paid, gated, hardware, region, or sample-data features.
- StoreKit product availability or sandbox setup details.
- Any feature that depends on background processing, notifications, location, Bluetooth, camera, microphone, or external services.

Do not use review notes to excuse an incomplete or non-functional flow.

## High-Risk Code Signals

Search for and manually review:

- `TODO`, `FIXME`, `DEBUG`, `mock`, `stub`, `beta`, `test`, `staging`.
- Hidden menus, debug gestures, internal build banners, and environment switchers.
- Web links for account creation, payment, support, privacy, terms, and external content.
- Feature flags that hide core advertised functionality from reviewers.
