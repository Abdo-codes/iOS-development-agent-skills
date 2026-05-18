# StoreKit And Paywall Review

Use this reference when the app has in-app purchases, subscriptions, premium unlocks, StoreKit views, or custom paywalls.

Primary Apple references:

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines - In-app purchase: https://developer.apple.com/design/human-interface-guidelines/in-app-purchase

## StoreKit Checklist

- Products configured in App Store Connect are complete, active for review, and match the identifiers used by the app.
- Review notes explain anything App Review needs to access or test configured products.
- Purchases, restore purchases, entitlement refresh, and failed purchase paths work.
- The app does not hide reviewable IAP products behind unreachable remote config.
- Family sharing, trials, introductory offers, and promotional offers match product setup when used.

## Paywall Copy

Review paywall text for:

- Subscription duration and renewal behavior.
- Trial length and what happens after the trial.
- Price, currency, and product title matching StoreKit output.
- Clear distinction between one-time purchases, consumables, non-consumables, and subscriptions.
- Restore purchase entry point.
- Terms and privacy links where the product flow expects them.

Avoid hard-coded prices or trial claims unless they are intentionally synchronized with App Store Connect.

## Common Rejection Risks

- Users cannot reach paid content after purchase.
- Restore purchases is missing or broken.
- The paywall advertises benefits not delivered by the entitlement.
- Product identifiers exist in code but are not available for review.
- Subscription copy is ambiguous about renewal, duration, or trial behavior.
- The app asks users to perform extra tasks before accessing paid content they already purchased.
