# MafiFlow Mobile 1.0 — Beta 2 💚

Flutter application for Android and iOS. Development beta; test before publishing.

## Beta 2 changes
- Fixed transaction and recurring-payment dialog opening (Navigator context)
- Welcome wizard on fresh installs: language, currency, monthly income, starting balance, savings goal, recurring expenses
- Calculator in the top bar
- Five languages: Spanish, English, French, German, Bengali
- Responsive navigation rail in landscape / bottom bar in portrait
- Official MafiFlow icon generation for Android and iOS
- Local financial data kept across updates with the same Android application ID
- Fixed available balance calculation: starting balance + recorded income − recorded expenses (savings goal is a goal, not a charge)

## Build Android
Upload the project files **inside** the ZIP to the existing `MafiFlow-Mobile` repository (replace changed files). GitHub Actions → Android APK → latest green run → Artifacts → `MafiFlow-Mobile-1.0-Beta2-Android`.

## Build iOS
Use the iOS Build Check workflow. A signed IPA / App Store release requires Apple signing and an Apple Developer account.

## Notes
- This package is Flutter source, **not** a compiled APK/IPA.
- The code has not been run on an actual Android or iOS device in this environment. Test all forms and backups before publishing.
- Back up financial data before updating. Do not uninstall the old beta if you want to keep local data.
- No API keys or personal financial records should be committed to GitHub.
- Existing installations that already completed setup are not prompted again; to test onboarding use a fresh install or clear app data **only after making a backup**.
- Android debug build is for testing, not for Play Store release.

License: MIT © Mafistudio.


## Beta 3 (icon + bottom navigation)

- Navigation bar stays at the bottom in portrait and landscape (no side rail).
- Launcher icon is generated from `assets/app_icon.png` and checked during Android CI.
- Android launcher label is `MafiFlow` (rather than `mafiflow_mobile`).
- Build number incremented to `1.0.0+3`.
- Planned for later: preset categories and comprehensive settings translations.

To find the icon step in GitHub: Actions → Android APK → latest run → android job → Generate official app icon / Verify icon resources.

Do not uninstall the existing app if you want to keep locally stored data.


## Beta 4 improvements
- Launcher icon has transparent outside corners while keeping the original MafiFlow emblem.
- Built-in, localized expense categories; add/remove personal categories and hide/restore defaults.
- Charts: income/expense donut, category percentages, six-month bar/line comparison and month-over-month percentages.
- Translated opening balance, currency, category management and chart labels in ES/EN/FR/DE/BN.
- Saved data continues using `mafiflow_data` in SharedPreferences; update without uninstalling.
- Android workflow generates only Android icons; iOS icons should be generated in the separate iOS build from the same `assets/app_icon.png`.


## 1.0.9 beta 20
- CUP available in currency settings and onboarding.
- Calculator expression and live result scale to available width; keypad adapts to viewport size.
- Existing Android launcher icon preserved.
