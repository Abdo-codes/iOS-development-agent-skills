# Privacy, Permissions, And Purpose Strings

Apple expects privacy details and permission prompts to match the app's actual behavior. Review both code and App Store Connect answers.

Primary Apple references:

- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- App Store Connect app privacy help: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

## Purpose Strings

Review `Info.plist` and generated plist files for usage descriptions:

- Camera: `NSCameraUsageDescription`
- Microphone: `NSMicrophoneUsageDescription`
- Photo library: `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`
- Location: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription`
- Contacts: `NSContactsUsageDescription`
- Calendars and reminders: `NSCalendarsUsageDescription`, `NSRemindersUsageDescription`
- Bluetooth: `NSBluetoothAlwaysUsageDescription`, `NSBluetoothPeripheralUsageDescription`
- Motion, health, speech, face ID, local network, tracking, and nearby interaction purpose strings when used.

Good purpose strings are specific, user-facing, and tied to the feature that triggers the prompt. Weak strings only say that access is required.

## Privacy Manifest And SDK Review

Look for:

- `PrivacyInfo.xcprivacy`
- analytics, ads, attribution, crash reporting, support chat, social login, payments, maps, messaging, and web SDKs
- tracking prompts and `NSUserTrackingUsageDescription`
- data deletion or account deletion flows if the app creates accounts

App privacy answers should include data collected by the app and third-party partners. If code or SDK usage changed, App Store Connect privacy answers may need an update even when no app code in the current PR mentions privacy directly.

## In-App Privacy Access

Confirm the app exposes:

- Privacy policy access from the app when applicable.
- Account deletion or data deletion path for account-based apps.
- Consent withdrawal path for optional analytics, tracking, or marketing data.
- Clear copy around permissions that are optional versus required.
