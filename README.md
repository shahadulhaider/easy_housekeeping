# EasyHousekeeping

A household inventory management app built with Flutter, designed for Bangladeshi families. Track groceries, manage bazar purchases, monitor consumption, manage household staff salaries, and generate reports — all offline-first with a local SQLite database.

## Features

- **Inventory Management** — Track consumable and durable items with stock levels, minimum thresholds, and low-stock alerts
- **Bazar Log** — Record grocery purchases with line items, receipt photos, and market details
- **Consumption Prediction** — EMA-based algorithm estimates when items will run out, adjusted for household headcount
- **Household Management** — Family members and staff with salary tracking and payment history
- **Barcode Scanner** — Scan product barcodes and look up details via Open Food Facts API
- **Reports** — Monthly spend breakdown with charts, PDF export, and WhatsApp/email sharing
- **Bilingual** — Full English and Bangla (বাংলা) localization with language selection on first launch
- **Dark Mode** — Material 3 theming with light, dark, and system modes
- **Offline-First** — All data stored locally in SQLite via Drift

## Screenshots

_Coming soon_

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.38+ / Dart 3.10+ |
| State Management | Riverpod |
| Database | Drift (SQLite) |
| Navigation | GoRouter |
| Charts | fl_chart |
| PDF | pdf + printing |
| Barcode | mobile_scanner |
| Sharing | share_plus + url_launcher |
| Localization | Flutter gen-l10n (ARB files) |

## Getting Started

### Prerequisites

- Flutter SDK 3.38+
- Android Studio (for Android emulator) or Xcode (for iOS simulator)
- A connected device or emulator

### Setup

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/easy_housekeeping.git
cd easy_housekeeping

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n

# Set up your household members (required)
cp lib/data/services/seed_members.example.dart lib/data/services/seed_members.dart
# Edit seed_members.dart with your family details

# Run
flutter run
```

### Seed Data Configuration

The app seeds initial data on first launch (categories, locations, household members). Personal member data is kept separate for privacy:

- `seed_members.example.dart` — Template with placeholder names (committed)
- `seed_members.dart` — Your actual family data (gitignored, never pushed)

Copy the example file and fill in your details:

```dart
const List<SeedMember> seedMembers = [
  SeedMember(name: 'Your Name', role: 'admin'),
  SeedMember(name: 'Spouse', role: 'admin'),
  SeedMember(name: 'Child', role: 'family'),
  SeedMember(name: 'Cook', role: 'staff', staffRole: 'cook', monthlySalary: 8000),
];
```

Roles: `admin`, `family`, `staff`
Staff roles: `cook`, `caregiver`, `assistant`

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app_router.dart                    # GoRouter with 5-tab navigation
├── app_providers.dart                 # Global Riverpod providers
├── core/
│   ├── constants/app_constants.dart
│   ├── theme/                         # Material 3 light/dark themes
│   ├── utils/                         # Currency (BDT), date formatting
│   ├── widgets/                       # Reusable widgets
│   └── extensions/                    # BuildContext extensions
├── data/
│   ├── models/enums.dart              # ItemType, MemberRole, StaffRole, etc.
│   ├── database/
│   │   ├── tables/tables.dart         # 14 Drift table definitions
│   │   ├── database.dart              # AppDatabase with CRUD methods
│   │   └── database.g.dart            # Generated (gitignored)
│   └── services/
│       ├── seed_data_service.dart      # First-launch data seeder
│       ├── seed_members.dart           # Personal member data (gitignored)
│       ├── seed_members.example.dart   # Template for seed_members.dart
│       ├── barcode_service.dart        # Open Food Facts API
│       ├── consumption_service.dart    # EMA prediction engine
│       ├── pdf_report_service.dart     # Monthly report PDF generation
│       └── share_service.dart          # PDF/WhatsApp/email sharing
├── features/
│   ├── dashboard/                     # Home screen with stats
│   ├── inventory/                     # Consumables, durables, locations
│   ├── bazar/                         # Purchase logging
│   ├── reports/                       # Charts and export
│   ├── household/                     # Family and staff management
│   ├── notifications/                 # Alerts center
│   ├── scanner/                       # Barcode scanning
│   ├── settings/                      # Theme, language, data management
│   └── onboarding/                    # Language selection
└── l10n/
    ├── app_en.arb                     # English strings
    ├── app_bn.arb                     # Bangla strings
    └── generated/                     # Generated (gitignored)
```

## Database Schema

14 tables covering the full household inventory domain:

| Table | Purpose |
|-------|---------|
| ItemCategories | Bangladeshi grocery categories with Bangla names |
| Items | Consumable and durable inventory items |
| Locations | Storage locations (kitchen, store room, etc.) |
| HouseholdMembers | Family and staff with roles and salaries |
| PurchaseEntries | Bazar trip records |
| PurchaseLineItems | Individual items per purchase |
| ConsumptionLogs | Daily consumption tracking |
| DailyHeadcounts | People at home (affects consumption predictions) |
| StaffPayments | Salary and advance payments |
| Reminders | Low stock, warranty, salary alerts |
| ItemPhotos | Item images |
| ServiceHistoryEntries | Repair/maintenance records for durables |
| BarcodeCache | Cached Open Food Facts lookups |
| BazarTemplates | Saved shopping lists |

## Pre-Seeded Categories

**Consumables:** Rice (চাল), Lentils (ডাল), Spices (মশলা), Cooking Oil (তেল), Fish (মাছ), Meat (মাংস), Vegetables (শাক-সবজি), Fruits (ফল), Dairy (দুধ-দই), Beverages (পানীয়), Cleaning Supplies, Toiletries, Baby Supplies

**Durables:** Kitchen Equipment (রান্নাঘরের সরঞ্জাম), Electronics (ইলেকট্রনিক্স), Furniture (আসবাবপত্র)

**Locations:** Kitchen (রান্নাঘর), Bedroom (শোবার ঘর), Bathroom (বাথরুম), Living Room (বসার ঘর), Store Room (ভাঁড়ার ঘর), Balcony (বারান্দা)

## Consumption Prediction

Uses Exponential Moving Average (EMA) to predict when items will run out:

```
EMA_today = α × actual_consumption + (1 - α) × EMA_yesterday    (α = 0.3)
days_remaining = current_stock / EMA_rate
adjusted = days_remaining × (baseline_headcount / current_headcount)
```

## Contributing

1. Fork the repo
2. Create your feature branch (`git checkout -b feat/amazing-feature`)
3. Copy `seed_members.example.dart` to `seed_members.dart` with your test data
4. Run `dart run build_runner build` and `flutter gen-l10n`
5. Commit your changes
6. Push and open a PR

## License

MIT
