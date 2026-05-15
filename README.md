# WE Packages Manager

A local, offline, iPhone-first Flutter app for telecom resellers who manage **WE** internet/mobile package groups. Built with Flutter, Hive, and Provider. Fully bilingual (Arabic / English) with RTL support.

---

## ✨ Features

- **3 fixed package groups** (cannot be created or deleted, only edited).
- **Up to 6 customers per group** with full add / edit / delete / mark paid-unpaid.
- **Per-group monthly cycle** — renewal day is either **1** or **16** of each month.
- **Automatic monthly reset** at startup, with a full snapshot of the closed cycle saved to history.
- **Dashboard** with collected / pending / expected sales / company cost / net profit / paid + unpaid counts, plus a card per group.
- **History** screen with per-group filter and full per-customer snapshot.
- **Arabic (default, RTL) + English (LTR)** with in-app language switch (Settings).
- **100% offline** — no backend, no login, no internet required. All data lives in Hive on the device.
- **Production-friendly structure** — models, services, providers, screens, widgets, utils, l10n.

---

## 📁 Project Structure

```
lib/
  main.dart
  app.dart                                  # Bottom navigation shell
  models/
    group_model.dart                        # + manual Hive adapter
    customer_model.dart                     # + manual Hive adapter
    monthly_history_model.dart              # + manual Hive adapter
    customer_snapshot_model.dart            # + manual Hive adapter
  screens/
    splash_screen.dart
    dashboard_screen.dart
    groups_screen.dart
    group_details_screen.dart
    add_edit_customer_screen.dart
    edit_group_screen.dart
    history_screen.dart
    history_details_screen.dart
    settings_screen.dart
  services/
    local_database_service.dart             # Hive boxes + seed
    cycle_service.dart                      # Monthly reset logic
    history_service.dart
    settings_service.dart                   # SharedPreferences for language
  providers/
    app_provider.dart                       # Groups, customers, calculations
    language_provider.dart
  widgets/
    summary_card.dart
    group_card.dart
    customer_card.dart
    empty_state.dart
  utils/
    date_utils.dart                         # Cycle math (renewal day 1 / 16)
    currency_utils.dart
    validators.dart
  l10n/
    app_en.arb
    app_ar.arb
    app_localizations.dart                  # Hand-written, works without gen-l10n
test/
  cycle_date_utils_test.dart
ios/Runner/Info.plist                       # Includes CFBundleLocalizations en, ar
pubspec.yaml
l10n.yaml
```

---

## 🚀 Setup

### Prerequisites

- macOS with Xcode 15+
- Flutter **stable** ≥ 3.27 (3.41 recommended, current at time of writing)
- CocoaPods (`sudo gem install cocoapods` if not installed)

### First run

```bash
# 1. Move into the project root
cd we_packages_manager

# 2. Bootstrap the iOS project files (creates ios/Runner.xcworkspace,
#    ios/Podfile, default launch screen, app icons, etc.)
flutter create --platforms=ios .

# 3. Re-apply the supplied Info.plist (flutter create overwrites it).
#    The version in this repo already declares Arabic + English.

# 4. Install Dart packages
flutter pub get

# 5. (Optional) regenerate the localizations from .arb files.
#    The project already ships with a hand-written app_localizations.dart, so
#    this is not required — but if you change the .arb files, run:
flutter gen-l10n

# 6. Install iOS pods
cd ios && pod install && cd ..

# 7. Run on a simulator
open -a Simulator
flutter run

# Or run on a connected iPhone
flutter devices
flutter run -d <device-id>
```

### Run unit tests

```bash
flutter test
```

(The included tests cover the cycle math for renewalDay 1 and renewalDay 16, including year boundaries.)

---

## 📱 Running on a real iPhone

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` target → **Signing & Capabilities** → choose your **Team**.
3. Change **Bundle Identifier** to something unique (e.g. `com.yourname.wepackages`).
4. Plug in your iPhone and trust the computer on the device.
5. In Xcode, select your device from the device list and press **Run** (or `flutter run -d <id>` from the command line).
6. On the iPhone, trust the developer profile under **Settings → General → VPN & Device Management**.

---

## 🛠 Customisation

### Change the app name

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>WE Packages</string>     <!-- ← change this -->
```

Also update the in-app title via the `appTitle` key in both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` (and the matching getter in `lib/l10n/app_localizations.dart` if you keep using the hand-written file).

### Change the app icon

1. Generate icons with [appicon.co](https://appicon.co/) or `flutter_launcher_icons`.
2. Replace the contents of `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

Or with `flutter_launcher_icons`:

```yaml
# Add to dev_dependencies in pubspec.yaml:
flutter_launcher_icons: ^0.13.1

# Then add at the bottom of pubspec.yaml:
flutter_launcher_icons:
  ios: true
  image_path: "assets/icon.png"   # 1024x1024 PNG
```

```bash
dart run flutter_launcher_icons
```

### Change the seed/primary colour

In `lib/main.dart`, edit:

```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4), // ← change here (blue / purple / etc.)
  brightness: Brightness.light,
);
```

---

## 🔁 How the monthly reset works

Every group has two date fields:

- `currentCycleStartDate` — the start of the cycle currently shown to the user.
- `lastResetCycleStartDate` — the cycle start we last reset the customers for.

On every app startup, `CycleService.checkAndResetCycles()`:

1. Walks every group.
2. Computes the **calendar-correct current cycle start** for that group's `renewalDay` (1 or 16) given today's date.
3. If that date matches `lastResetCycleStartDate` → still in the same cycle → **no-op**.
4. Otherwise: snapshot the *previous* cycle to history, reset every active customer (`isPaid = false`, `lastPaidDate = null`), and bump both date fields to the new cycle start.

Because step 4 advances `lastResetCycleStartDate`, opening the app multiple times in the same cycle will only trigger one reset — exactly as required.

The cycle math is in `lib/utils/date_utils.dart` and is fully covered by `test/cycle_date_utils_test.dart`.

---

## 🌐 Language switching

- Default language is **Arabic** (RTL).
- Toggle from **Settings → Language**.
- Flutter switches the `Directionality` automatically based on the active `Locale`.
- All UI strings come from `lib/l10n/app_localizations.dart` (no hardcoded strings in widgets).

If you regenerate with `flutter gen-l10n`, delete the hand-written `app_localizations.dart` first — otherwise both files will define `AppLocalizations`.

---

## 📦 Packages used

| Package | Purpose |
|---|---|
| `provider` | State management |
| `hive`, `hive_flutter` | Local offline storage |
| `shared_preferences` | Tiny key-value store (first-launch flag, selected language) |
| `uuid` | Unique IDs for groups/customers/history rows |
| `intl` | Date and number formatting |
| `flutter_localizations` | Built-in localization plumbing |

All packages support iOS. No Android-only or remote/Firebase packages are used.

---

## 🧪 Manual test checklist

- [ ] First launch creates exactly 3 groups with demo customers.
- [ ] Trying to add a 7th customer shows the localised "group full" alert.
- [ ] Marking paid / unpaid updates the dashboard immediately.
- [ ] Editing price or company cost updates totals immediately.
- [ ] Setting a group's renewal day to 1 vs 16 changes the cycle dates correctly.
- [ ] Closing and reopening the app preserves all data.
- [ ] Switching language between Arabic and English flips the layout direction.
- [ ] Resetting demo data from Settings recreates the 3 groups + demo customers.

---

## License

Internal / unspecified. Adjust to your needs.
# we
