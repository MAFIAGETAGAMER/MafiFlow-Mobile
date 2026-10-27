# MafiFlow Mobile — Android 1.0.10 (versionCode 21)

## Source changes

- Independent local financial profiles: create, rename, switch, and delete with confirmation. Every profile has its own balance, transactions, scheduled payments, income, savings, categories, language, theme, currency, AI configuration and conversation.
- The **existing data** in `mafiflow_data` is migrated into an initial profile in the new `mafiflow_profiles_v1` archive. The old key is not deleted or rewritten. Corrupt archives are not overwritten.
- Backups now export **all** profiles in a versioned JSON document and exclude API keys from every profile. Import supports this format and legacy one-profile backups.
- Fixed the AI's cash-context formula: starting balance + all-time recorded income − all-time recorded expenses − reserved savings. Current-month flows are reported separately; the currency is specified explicitly. The AI is limited to the selected profile.
- Improved period statistics using a shared finance calculation module and ISO/SQLite-style date parsing. Past daily, weekly, monthly and annual periods are browsable; displayed date range is explicit. Current available balance and total reserved savings are cumulative, while flows remain period-specific.
- Scheduled items and statistics refresh when the app resumes and when the local calendar day changes while the app stays open. Saving settings applies the new income schedule without requiring app restart.
- Added an optional **Local summary (no AI)** provider, with no network, API key or region requirements. It is a deterministic financial report, not a generative AI.
- Better translated HTTP 401, 403 and 429 provider errors; prevent displaying raw HTML error pages. Regional restrictions imposed by an external provider cannot be removed by app code.
- Added translations for new UI in Spanish, English, French, German and Bengali; display-currency changes do **not** exchange or convert existing values.

## Upgrade safeguards

1. **Keep the Google Play application ID and signing key unchanged.** This repository's Android GitHub Action creates the app with `--org com.mafistudio` and project name `mafiflow_mobile`. Verify its application ID against the current Google Play release before uploading.
2. **Never uninstall or clear app storage as an update procedure.** Back up the data first using MafiFlow Settings > Export, and verify the copied JSON somewhere private. Clipboard backups contain sensitive financial information, excluding API keys.
3. After updating the existing installation, verify that the original balance, transactions, recurring bills, savings, currency and AI chat still appear under `Perfil 1`.
4. Create a second profile with a different currency and test that spending, savings, chats and settings do not affect profile 1. Switch back and forth and restart the app.
5. Test daily/weekly/monthly/yearly statistics with current and historical transactions, crossing midnight, app pause/resume and existing legacy savings records.
6. Verify local provider without internet, verify 403/401/429 messaging with a test provider or mock, and confirm that an authorized remote provider receives the correct starting balance and profile-only data.
7. Verify backup/restore for both legacy and versioned archives. Do not delete the last profile. Deleting another profile is irreversible except via backup.
8. Validate Android release signing and `versionCode` in Google Play Console; bump past **the actually published** version code if necessary.

## Home-screen widget (evaluated, not bundled)

The uploaded source contains no checked-in `android/` native project; GitHub Actions generates it on each run. A home-screen widget needs a native Android AppWidget provider, update scheduling, and careful consideration of financial-data privacy on visible launchers/lock screens. It is **not implemented** in this update. Recommended for a separate opt-in release with an option to hide amounts and select the visible profile. Do not advertise the widget as an included feature.

## Validation

Unit tests under `test/` are wired into the GitHub Android workflow (`flutter test`). The source was prepared without a local Flutter SDK or Android signing credentials; **a successful Flutter test/build on GitHub and hands-on Android regression testing are still required before distributing this build**.

**Deletion and legacy copy:** The initial pre-update snapshot remains stored under `mafiflow_data` to prevent upgrade loss. Deleting the migrated first profile removes it from the new archive, not from this original legacy snapshot or user-created copies. Full-data erasure needs a separate, explicitly confirmed privacy flow in a future release.
