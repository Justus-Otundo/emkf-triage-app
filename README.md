# EMKF Paramedic Triage Intake App

A Flutter app for paramedics to log patient triage data quickly, even when there's no network. Saves locally first, syncs when connectivity comes back — zero data loss.

## Project Structure

```
lib/
├── core/                    # Stuff shared across the app
│   ├── constants/           # Endpoints, timeouts, box names
│   ├── errors/              # Failures and exceptions
│   ├── network/             # HTTP client + connectivity checks
│   ├── theme/               # Colors, typography, component styles
│   └── utils/               # Result type, typedefs
├── features/
│   ├── triage/              # The main feature — triage intake
│   │   ├── data/            # Hive storage + mock API
│   │   ├── domain/          # TriageRecord model + repository interface
│   │   └── presentation/    # BLoC, form page, input widgets
│   └── sync/                # Offline sync engine
│       ├── data/            # Queue datasource (same Hive box as triage)
│       ├── domain/          # SyncQueueManager + SyncService
│       └── presentation/    # Sync status indicator
├── injection/               # GetIt wiring
├── app.dart                 # Root widget with BLoC provider
└── main.dart                # Entry point — init Hive, DI, start sync
```

### Why these choices

| What | Why |
|---|---|
| BLoC | Unidirectional data flow, clean separation, widely used in Flutter shops around East Africa |
| Hive | Lightweight, no native dependencies, fast, perfect for offline queues on a single device |
| GetIt | Simple DI, no code generation, keeps things explicit |
| connectivity_plus | Cross-platform, stream-based, just works |
| Dio | Interceptors, timeout config, clean error handling |
| Feature-first Clean Architecture | Each feature is self-contained, testable, and swappable |

## How the Offline Sync Works

This is the heart of the app.

1. **Save first, ask questions later** — When the paramedic taps submit, the record goes to Hive immediately. Then we try the remote call.

2. **Flag system** — Every record has a `synced` boolean. If the device is offline when submitted, that flag stays `false`.

3. **Connectivity watcher** — `SyncQueueManager` listens to connectivity changes. When the device goes from offline → online, it kicks off queue processing.

4. **Batch upload** — It grabs all records where `synced == false`, submits each one to the mock API, and flips the flag to `true` in-place. If one fails, it stops and waits for the next retry.

5. **Safety net** — A 30-second timer periodically checks the queue, just in case the connectivity event gets missed.

6. **UI feedback** — After sync completes, a stream notifies the form page to refresh the pending list and show a green toast.

### Flow

```
Submit → save to Hive → online? → yes → POST /api/v1/triage → mark synced → green toast
                            ↓ no
                      saved offline (synced=false) → amber toast
                            ↓
               Wifi comes back? → SyncQueueManager processes queue
                            ↓ yes
                   upload pending → mark synced → green toast + UI refresh
```

## Getting Started

### Prerequisites

- Flutter SDK 3.11+ ([install](https://docs.flutter.dev/get-started/install))
- Dart 3.11+
- A device or emulator

### Setup

```bash
git clone https://github.com/Justus-Otundo/emkf-triage-app.git
cd emkf-triage-app
flutter pub get
flutter run
```

### Tests

```bash
flutter test
```

20 unit tests covering entities, repository (online/offline/error), and BLoC (validation, submission, errors). Uses mocktail for mocking.

### Building

```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS (needs macOS)
```

## Testing the Offline Sync Yourself

1. Open the app on your device
2. Turn on Airplane Mode
3. Fill the form and tap Submit — you'll see an amber toast "Saved offline — will sync when connected"
4. Notice the sync badge in the app bar showing the count
5. Turn off Airplane Mode — the engine auto-syncs
6. Green toast "Pending records synced to server" appears and the badge goes away

The mock API simulates a 2-second delay and always succeeds when you're online, so the demo is predictable.

## What's Missing (On Purpose)

- A real backend — the assessment doesn't require one. The mock handles it.
- CI/CD — easy to add GitHub Actions later
- Crash reporting — Sentry or Firebase Crashlytics for production
- The demo video — you'll record a 60s clip showing offline save + sync

## Built With

- [Flutter](https://flutter.dev)
- [BLoC](https://bloclibrary.dev)
- [Hive](https://docs.hivedb.dev)
- [get_it](https://pub.dev/packages/get_it)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- [Dio](https://pub.dev/packages/dio)
- [mocktail](https://pub.dev/packages/mocktail)
