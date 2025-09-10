# Transport Tracker (Flutter)

An offline-first mobile app to track who traveled with you, when (morning/afternoon/both), and what they owe based on **monthly plans** or **daily per-trip** rates.

## Features

- Add passengers with plan type:
  - Monthly (Full / Morning-only / Afternoon-only) → fixed monthly rate
  - Daily → per session rate (morning = 1, afternoon = 1)
- Log daily trips
- **Voice logging** (e.g., “Raylene came with me this morning”)
- Weekly/Monthly **reports** per passenger

## Tech

- Flutter, Riverpod, Hive (local DB), speech_to_text, uuid, intl

## Setup

```bash
flutter pub get
flutter run
```

## Folder Structure

See `lib/` organized by `models/`, `providers/`, `services/`, `screens/`, `widgets/`, `utils/`.

## How Billing Works

- Monthly plans: show fixed monthly price in reports; trips logged for history only.
- Daily plan: total = perTripRate × number of sessions in the selected period.

## Voice Usage

- Tap **Voice Log** on the Log Trip screen and say:
  - “Raylene came with me this morning”
  - “Log Raylene both today”
  - “Zaid afternoon yesterday”
- If uncertain, the app falls back to a reasonable default (morning) or asks for clarification.

## Contributing

- Create a feature branch:
```bash
git checkout -b feat/<short-name>
```
- Commit with conventional messages:
```bash
git add .
git commit -m "feat(trips): log both sessions"
git push -u origin feat/<short-name>
```
- Open a PR on GitHub.

## Next Steps (Scaling)

- Cloud sync: Firebase Auth + Firestore (mirror Hive data; resolve conflicts with timestamps).
- Backups: cloud export/import JSON.
- Notifications: local reminders to log morning/afternoon.
- Analytics: charts (weekly usage, revenue).
- Data export: CSV/PDF monthly statements per passenger.
- Roles & privacy: biometric app lock, per-passenger notes.