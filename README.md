# Flutter Starter Template

Production-ready starter with MVC architecture, ads, IAP, multi-language support,
Firebase analytics, push notifications, and in-app review.

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
| `lib/core/utils/review_service.dart` | Your App Store ID |
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

```
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
│   │   └── app_theme_provider.dart
│   ├── utils/
│   │   ├── locale_provider.dart  # 11-language support
│   │   ├── purchase_service.dart # In-App Purchase
│   │   └── review_service.dart   # In-App Review
│   └── widgets/
│       └── banner_ad_widget.dart
│
├── features/
│   ├── home/
│   │   └── home_screen.dart
│   └── settings/
│       └── settings_screen.dart
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
- [x] **In-App Review** — smart trigger (Android API 11–15+, iOS)
- [x] **Dark/Light/System Theme** — persisted via SharedPreferences
- [x] **Locale Persistence** — saved across sessions

---

## Android Notes (In-App Review)

The Google Play In-App Review API works on **Android 5.0+ (API 21+)**.
Google throttles the prompt — guaranteed to show only in test mode.

To test on emulator:
1. Sign in with a Google account on the emulator
2. Install via Play Store (or use internal testing track)
3. The dialog appears on real devices / internal testing track