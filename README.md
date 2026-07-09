# EMKF Paramedic Triage Intake App

A Flutter-based mobile application for emergency paramedics to log critical patient triage data under pressure, with an offline-first architecture that guarantees zero data loss when network connectivity is unstable or unavailable.

## Architecture Overview

```
lib/
├── core/                       # Shared infrastructure
│   ├── constants/              # App-wide constants (endpoints, timeouts)
│   ├── errors/                 # Failure & exception types
│   ├── network/                # Dio HTTP client, connectivity monitoring
│   ├── theme/                  # Material3 theme, priority hazard colors
│   └── utils/                  # Result type, typedefs
├── features/
│   ├── triage/                 # Triage intake feature (bounded context)
│   │   ├── data/               # Local (Hive) + remote (mock) datasources
│   │   ├── domain/             # TriageRecord entity + repository contract
│   │   └── presentation/       # BLoC, form page, form widgets
│   └── sync/                   # Sync engine feature (cross-cutting)
│       ├── data/               # Sync queue datasource
│       ├── domain/             # SyncQueueManager, SyncService
│       └── presentation/       # Sync status indicator widget
├── injection/                  # GetIt dependency injection
├── app.dart                    # MaterialApp root with BLoC provider
└── main.dart                   # Entry point — Hive init, DI, sync start
```

### Architectural Decisions

| Concern | Choice | Rationale |
|---|---|---|
| State management | BLoC | Production-grade, widely used in Flutter shops across East Africa; enforces unidirectional data flow and clean separation |
| Local storage | Hive | Lightweight, no native deps, fast read/write, perfect for single-device offline queues |
| DI | GetIt | Simple, fast, no code generation; keeps the DI layer explicit |
| Network monitoring | connectivity_plus | Cross-platform, stream-based API, stable |
| HTTP client | Dio | Interceptors, timeout config, clean error mapping |
| Architecture | Clean Architecture (feature-first) | Separates UI from business logic from data; each feature is independently testable and swappable |

## Offline-First Sync Engine

This is the most critical piece of the system.

### How It Works

1. **Interception**: When the paramedic taps "Submit", the repository saves the record to Hive *first*, then attempts a remote POST.

2. **Local persistence**: Every record is persisted in a Hive box (`triage_records`) with a `synced` boolean flag. If the device is offline when submission happens, the flag stays `false`.

3. **Connectivity listener**: The `SyncQueueManager` subscribes to `connectivity_plus` stream events. When connectivity transitions from disconnected → connected, the manager triggers `_processQueue()`.

4. **Queue processing**: `_processQueue()` fetches all records where `synced == false` from the sync queue, iterates through them, submits each to the mock API, and removes successfully synced records from the queue. If a record fails, processing stops and retries on the next connectivity event or periodic timer.

5. **Periodic retry**: A 30-second `Timer.periodic` ensures the queue eventually drains even if connectivity events are missed.

6. **Lifecycle safety**: `startListening()` and `stopListening()` manage the connectivity subscription. The manager can be safely started in `main()` and does not freeze the UI during sync.

### Sync Flow Diagram

```
[Submit] → save to Hive → online? → yes → POST /api/v1/triage → mark synced
                           ↓ no
                     saved offline (synced=false)
                           ↓
              connectivity restored? → SyncQueueManager._processQueue()
                           ↓ yes
                  batch upload pending records → mark synced
```

## Getting Started

### Prerequisites

- Flutter SDK 3.11+ ([install](https://docs.flutter.dev/get-started/install))
- Dart 3.11+
- An Android emulator / iOS simulator or physical device

### Setup

```bash
# Clone the repository
git clone https://github.com/your-username/emkf-triage-app.git
cd emkf-triage-app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

### Building for Release

```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS (requires macOS)
```

## Testing the Offline Sync

1. Launch the app on a device or emulator
2. Enable Airplane Mode
3. Fill in the triage form and tap "Submit" — you should see an amber snackbar: "Record saved offline — will sync when connected"
4. Disable Airplane Mode — the sync engine will automatically upload the pending record
5. You should see a green snackbar: "Record submitted and synced"

The mock remote datasource (`TriageRemoteDatasourceMock`) introduces a random 50% failure rate, so you may need a few attempts to observe a successful online submission.

## Testing Strategy

- **Unit tests**: 20 tests covering entities, repository (online/offline/error paths), BLoC (validation, submission, error states)
- **Mocking**: mocktail for all dependency mocking
- **Test structure**: mirrors the `lib/` layout — one test file per source file

## What's Not Included

- A real backend server — the assessment specifies this is not required. The mock remote datasource simulates 2-second delay + random failures
- CI/CD pipeline — add GitHub Actions or GitLab CI for automated testing
- Crash reporting / analytics — integrate Sentry or Firebase Crashlytics for production
- The demo video — please record a 60-second clip showing offline save + auto-sync

## Built With

- [Flutter](https://flutter.dev) — UI toolkit
- [BLoC](https://bloclibrary.dev) — State management
- [Hive](https://docs.hivedb.dev) — Local storage
- [get_it](https://pub.dev/packages/get_it) — Dependency injection
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) — Network monitoring
- [Dio](https://pub.dev/packages/dio) — HTTP client
- [mocktail](https://pub.dev/packages/mocktail) — Testing mocks
