# Flutter Starter Template

Production-ready starter with MVC architecture, ads, IAP, multi-language support,
Firebase analytics, push notifications, **home screen widgets**, **in-app review**,
and **share / viral loops**.

---

## Quick Setup (5 steps)

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (creates firebase_options.dart automatically)
flutterfire configure
```

### 3. Replace placeholder IDs

| File | What to replace |
|------|----------------|
| `lib/config/ads_service.dart` | Your AdMob Ad Unit IDs |
| `lib/config/notification_service.dart` | Your OneSignal App ID |
| `lib/core/config/engagement_config.dart` | App Store ID, package name, share URLs, iOS App Group |
| `lib/core/utils/purchase_service.dart` | Your IAP product IDs |

### 4. Generate localization files
```bash
flutter gen-l10n
```

### 5. Run
```bash
flutter run
```

---

## Folder Structure (MVC)

```text
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + providers
│
├── config/                      # Global services (singleton)
│   ├── ads_service.dart         # Banner, Interstitial, Rewarded, App Open
│   ├── firebase_service.dart    # Analytics + Crashlytics
│   └── notification_service.dart # FCM + OneSignal
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart       # Light & Dark ThemeData
│   │   └── theme_provider.dart  # Theme state management
│   ├── utils/
│   │   ├── locale_provider.dart  # 11-language support
│   │   ├── purchase_service.dart # In-App Purchase
│   │   ├── review_service.dart   # In-App Review (smart + success moments)
│   │   ├── share_service.dart    # share_plus viral loop
│   │   └── home_widget_service.dart # home_widget bridge
│   ├── config/
│   │   └── engagement_config.dart # store IDs, thresholds, share copy
│   └── widgets/
│       └── banner_ad_widget.dart
│
├── src/                         # UI Screens
│   ├── home_screen.dart
│   └── settings.dart
│
└── l10n/                        # ARB files for all 11 languages
    ├── app_en.arb
    ├── app_es.arb  (Spanish)
    ├── app_hi.arb  (Hindi)
    ├── app_zh.arb  (Chinese Simplified)
    ├── app_ar.arb  (Arabic)
    ├── app_fr.arb  (French)
    ├── app_pt.arb  (Portuguese)
    ├── app_ru.arb  (Russian)
    ├── app_de.arb  (German)
    ├── app_id.arb  (Indonesian)
    └── app_ja.arb  (Japanese)
```

---

## Features Checklist

- [x] **MVC Architecture** — clean separation of config/core/features
- [x] **Ads** — Banner, Interstitial, Rewarded, App Open (Google Mobile Ads)
- [x] **In-App Purchase** — consumable, non-consumable, subscription
- [x] **Language Support** — 11 languages (en, es, hi, zh, ar, fr, pt, ru, de, id, ja)
- [x] **Firebase Analytics** — screen tracking, events, user properties
- [x] **Firebase Crashlytics** — crash & error reporting
- [x] **Push Notifications** — FCM (topic-based) + OneSignal (segmented)
- [x] **In-App Review** — session-based + positive-moment triggers (`in_app_review`)
- [x] **Home Screen Widget** — Android sample widget (`home_widget`); iOS extension guide in `docs/`
- [x] **Share / Viral Loop** — invite friends, achievement shares (`share_plus`)
- [x] **Dark/Light/System Theme** — persisted via SharedPreferences
- [x] **Locale Persistence** — saved across sessions

---

## Engagement (Widgets, Review, Share)

### Configure once

Edit `lib/core/config/engagement_config.dart`:

- `iosAppStoreId`, `androidPackageName`, `appDisplayName`
- `iosAppGroupId` (iOS widgets; requires paid Apple Developer account)
- Review thresholds (`reviewMinLaunches`, `reviewMinDaysBetween`)
- Share prompt thresholds (`sharePromptMinLaunches`, …)

### Home screen widget

**Android** is ready: long-press home screen → Widgets → your app. Native files:

- `android/.../StarterAppWidgetProvider.kt`
- `android/.../res/layout/starter_app_widget.xml`

Update widget data from your features:

```dart
await HomeWidgetService.instance.syncFromApp(
  title: '3 tasks left',
  subtitle: 'Updated just now',
);
```

**iOS** requires a Widget Extension in Xcode. See `docs/ios_home_widget_example.swift`.

### In-app review

- Automatic: `ReviewService.instance.trackSessionAndPromptIfEligible()` (runs on home load).
- After wins: `ReviewService.instance.trackPositiveMomentAndPromptIfEligible()`.
- Manual: Settings → Rate the app, or `ReviewService.instance.requestReviewNow()` (native sheet, no pre-dialog).

### Share / viral loop

```dart
await ShareService.instance.shareApp();
await ShareService.instance.shareAchievement('I just hit a 7-day streak!');
```

Periodic invite prompt runs from `runEngagementSessionHooks` when the user has not shared yet.

---

## Android Notes (In-App Review)

The Google Play In-App Review API works on **Android 5.0+ (API 21+)**.
Google throttles the prompt — guaranteed to show only in test mode.

To test on emulator:
1. Sign in with a Google account on the emulator
2. Install via Play Store (or use internal testing track)
3. The dialog appears on real devices / internal testing track

---

## Customization Commands

Use these commands to fully customize this starter for your project:

### 1. Change Package Name (Bundle ID)
```bash
flutter pub run change_app_package_name:main com.yourdomain.appname
```

### 2. Update App Icons
Make sure you have updated `assets/images/app_icon.png` and then run:
```bash
flutter pub run flutter_launcher_icons
```

### 3. Generate Splash Screens
Configure the background color and image in `pubspec.yaml` under `flutter_native_splash`, then run:
```bash
flutter pub run flutter_native_splash:create
```

### 4. Rename App Title
```bash
# To rename the application display name
flutter pub run rename setAppName --value "Your App Name"
```