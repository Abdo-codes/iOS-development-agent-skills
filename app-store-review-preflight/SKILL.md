---
name: app-store-review-preflight
description: Use when preparing an Apple-platform app for App Store review, auditing release readiness, checking App Store metadata, privacy policy links, permission purpose strings, StoreKit or subscription copy, in-app purchase review risk, demo account readiness, placeholders, debug UI, or when the user mentions "App Review", "App Store submission", "review rejection", "release preflight", "privacy nutrition labels", "Info.plist permissions", "StoreKit", or "paywall review" for Xcode-based apps.
---

# App Store Review Preflight

## Overview

Use this skill before submitting an iOS, iPadOS, macOS, tvOS, watchOS, or visionOS app to App Review. The goal is not to guarantee approval; it is to find avoidable rejection risks before upload: incomplete app behavior, inaccurate metadata, missing privacy details, vague permission prompts, broken paywalls, and reviewer-blocking login flows.

Use current Apple App Review Guidelines and App Store Connect guidance as the source of truth. Treat this skill as a preflight workflow, not legal advice.

## Available Resources

- `scripts/audit-app-store-preflight.sh <repo-path>` - run first to find permission strings, StoreKit/paywall code, privacy manifests, placeholders, debug flags, external links, login/demo hints, and metadata files.
- `references/review-checklist.md` - release and App Review readiness checklist.
- `references/privacy-strings.md` - permission purpose strings and privacy manifest review guidance.
- `references/storekit-paywall-review.md` - StoreKit, paywall, subscription, restore, and purchase-copy checks.

## Core Workflow

1. **Audit first.**
   Run `scripts/audit-app-store-preflight.sh <repo-path>` and classify the output into likely blockers, review notes, metadata follow-up, and acceptable findings.

2. **Check app completeness.**
   Look for placeholders, debug UI, incomplete flows, empty URLs, beta labels, test copy, feature flags, and crash-prone startup paths. If the app requires login, confirm reviewer credentials or demo mode are documented outside the binary.

3. **Check metadata alignment.**
   Confirm App Store screenshots, descriptions, previews, privacy details, age rating, and "What's New" text match the actual app behavior. Metadata should not overpromise or describe features hidden from users or reviewers.

4. **Check privacy and permissions.**
   Review `Info.plist` purpose strings, `PrivacyInfo.xcprivacy`, SDK privacy manifests, analytics/ad/tracking code, and privacy policy links. Purpose strings should clearly explain why the app needs access in user-facing terms.

5. **Check purchases and subscriptions.**
   For StoreKit or paywalls, verify products are visible and reviewable, restore purchases works, entitlement state refreshes, subscription terms are clear, and pricing/trial copy is not misleading.

6. **Prepare review notes.**
   List anything App Review needs to operate the app: demo credentials, test environment constraints, hardware requirements, account setup steps, sample data, IAP review notes, or region-specific behavior.

7. **Verify before submission.**
   Use focused tests, simulator/device walkthroughs, StoreKit configuration tests, and metadata review. If a risk cannot be fixed before submission, document it in review notes only when it is legitimate and not a workaround for an incomplete app.

## Gotchas

**A passing build is not a review-ready app.**
App Review also evaluates completeness, metadata accuracy, privacy disclosures, business model, login accessibility, and functional purchase flows.

**Permission strings are product copy.**
Vague strings like "Need access" or "Required for app functionality" are weak. Explain the concrete user benefit and match the actual feature that triggers the permission.

**Privacy details must include third-party SDK behavior.**
Analytics, ads, crash reporting, attribution, support chat, and embedded web SDKs can affect privacy answers even when the app code does not directly collect the data.

**Paywall copy and StoreKit behavior must agree.**
Subscription duration, trial wording, restore behavior, entitlement access, and App Store Connect product setup should all match what the user sees in the app.

**Reviewers need a path through gated apps.**
If login, subscription, region, hardware, invite, or server state blocks the core experience, provide a demo account, demo mode, sample data, and concise review notes.

## Deliverables

Adapt to the task. Common outputs include:

- A prioritized preflight findings list grouped by blocking vs non-blocking risk.
- Updated permission strings, privacy manifests, paywall copy, or review notes.
- StoreKit and restore-purchase verification results.
- Metadata follow-up items for App Store Connect.
- Remaining risks that require product, legal, or account-holder decisions.
