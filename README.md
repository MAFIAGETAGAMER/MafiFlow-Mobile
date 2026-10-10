# MafiFlow Mobile 1.0 — Flutter

An Android/iOS Flutter port of MafiFlow. **Initial functional beta, not a production release.**

## Implemented
- Local transactions, edit/delete, categories, monthly income, recurring payments, savings goal.
- Automatic monthly entries applied once per month (on app open, not via background service).
- Overview and pie-chart statistics (zero and negative balances handled).
- Optional OpenAI-compatible AI advisor with streamed responses and immediate waiting indicator.
- Spanish/English UI, light/dark mode.
- Import/export of compatible Windows `datos.json` via clipboard. No automatic cross-device sync.

## Still to finish before claiming Windows feature parity
- Complete French, German and Bengali translations.
- Advanced statistics, custom category editor, rich financial breakdowns.
- Secure API key storage: current beta uses local preferences, **not an encrypted keychain**. Avoid storing production API keys on shared devices.
- File-based import/export, background monthly processing, full device/UI tests.
- iOS signing, provisioning, App Store/TestFlight distribution.

## Build locally
Install Flutter and Android Studio / Xcode. From this folder:

```bash
flutter create --platforms=android,ios --project-name mafiflow_mobile --org com.mafistudio .
flutter pub get
flutter run
```

## GitHub Actions
Upload all files (including `.github`). **Android APK** produces a debug APK under Artifacts. Debug APK is for testing; for public distribution use a signed release build. **iOS unsigned build check** checks compilation on macOS, but does not create a distributable signed iOS app.

## Data compatibility
Windows stores `datos.json` under `%APPDATA%/MafiFlow/`. Back it up first. Use Settings → Export JSON (copies text) on mobile or copy Windows JSON to clipboard, then Settings → Import JSON on mobile. This is a manual migration, not synchronization. Imported data replaces local mobile data after confirmation. **API keys are omitted from export by default.**

MIT license. Developed by Mafistudio.
