# EMKF Paramedic Triage Intake App

A Flutter app for paramedics to log patient triage data quickly, even when there's no network. Saves locally first, syncs when connectivity comes back — zero data loss.

Built for the EMKF full-stack developer technical assessment.

---

## Requirements Compliance

| Requirement | How the app meets it |
|---|---|
| **A. Triage Form** — Patient name, condition, priority 1–5, status (Pending/In-Transit) | Single-screen form, vertical priority radio selector with clinical descriptions, pill-toggle status selector |
| **A. Intuitive validation** — Priority must be selected, fields cannot be blank | BLoC validates all fields before submission; inline error messages below each field |
| **A. Critical cases stand out** — Priority 1 & 2 with hazard color-coding | Red/orange severity badges, warning banner component, color-coded priority tiles |
| **B. Offline interception** — No generic error when offline | Save to Hive first → check connectivity → amber toast "Saved offline" — zero data loss |
| **B. Local persistence** — Lightweight local storage | Hive (NoSQL, no native dependencies, fast on-device reads/writes) |
| **B. Background sync queue** — Auto-upload on reconnect | `connectivity_plus` stream + 30s periodic retry timer; processes all unsynced records in batch on reconnect |
| **B. Configurable mock failure rate** — Random network failures to prove retry logic | Mock fails ~30% of the time by default (adjustable via `AppConstants.mockFailureProbability`) |
| **C. Production state management** | BLoC (flutter_bloc) — unidirectional data flow, testable, widely adopted |
| **C. Separation of concerns** | Feature-first Clean Architecture: presentation → domain → data layers; UI never touches Hive or HTTP directly |
| **C. Device lifecycle** — Sync worker behaves when app is minimized and restored | `AppLifecycleListener` in `main.dart` triggers `processNow()` on `onResume` |
| **D. Unit tests** | 20 unit tests across entities, repository (online/offline/error), and BLoC (validation, submission, errors) |
| **D. Git discipline** | Public GitHub repo with clean commit history |

---

## Architecture

```
lib/
├── core/                    # Shared utilities
│   ├── constants/           # Endpoints, timeouts, box names, mock config
│   ├── errors/              # Failures and exceptions
│   ├── network/             # Dio HTTP client + connectivity_plus wrapper
│   ├── theme/               # Colors, typography, component styles
│   └── utils/               # Result type, typedefs
├── features/
│   ├── triage/              # Main feature — triage intake
│   │   ├── data/            # Hive storage + mock/real remote datasource
│   │   ├── domain/          # TriageRecord entity + repository interface
│   │   └── presentation/    # BLoC, form page, input widgets, records page
│   └── sync/                # Offline sync engine
│       ├── data/            # Queue datasource (same Hive box as triage)
│       ├── domain/          # SyncQueueManager + SyncService
│       └── presentation/    # Sync status indicator
├── injection/               # GetIt dependency wiring
├── app.dart                 # Root MaterialApp with BLoC provider
└── main.dart                # Entry point — init Hive, DI, start sync + lifecycle listener
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

---

## How the Offline Sync Works

This is the heart of the app.

1. **Save first, ask questions later** — When the paramedic taps submit, the record goes to Hive immediately. Then we try the remote call.

2. **Flag system** — Every record has a `synced` boolean. If the device is offline when submitted, that flag stays `false`.

3. **Connectivity watcher** — `SyncQueueManager` listens to `connectivity_plus` changes. When the device goes from offline → online, it kicks off queue processing.

4. **Batch upload** — It grabs all records where `synced == false`, submits each one to the mock API, and flips the flag to `true` in-place. If one fails, it stops and waits for the next retry.

5. **Safety net** — A 30-second timer periodically checks the queue, just in case the connectivity event gets missed.

6. **App lifecycle** — When the app returns to the foreground, `AppLifecycleListener.onResume` triggers an immediate sync attempt.

7. **UI feedback** — After sync completes, a stream notifies the form page to refresh the pending list and show a green toast.

### Flow

```
Submit → validate → save to Hive (synced=false) → online?
    ├─ yes → POST /api/v1/triage → mark synced=true → green toast
    └─ no  → amber toast "Saved offline — will sync when connected"

           ┌─ connectivity restored? ─┐
           │                          │
     30s timer ◄── SyncQueueManager   │
           │                          │
           └──→ processQueue(): fetch unsynced → submit each → mark synced
                                  ↓ fail? stop, retry later
                                  ↓ all done? emit syncComplete → green toast + UI refresh

App foregrounded → AppLifecycleListener.onResume → processNow() → same flow
```

---

## Mock Failure Simulation

The `TriageRemoteDatasourceMock` implements the email's requirement for "random network failure toggles to prove your sync queue works":

- **2-second artificial delay** — simulates network latency
- **~30% random failure rate** — `ServerException` is thrown randomly; the sync queue retries on the next cycle
- **Configurable** — set `failureProbability` to `0` for a predictable demo, or higher to stress-test retry logic

To override for a demo video, swap to zero-failure mode in `injection_container.dart`:
```dart
sl.registerLazySingleton<TriageRemoteDatasource>(
  () => TriageRemoteDatasourceMock(failureProbability: 0),
);
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.11+
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

---

## Testing the Offline Sync Yourself

1. Open the app on your device
2. Turn on **Airplane Mode**
3. Fill the form and tap Submit — amber toast "Saved offline — will sync when connected"
4. Notice the sync badge in the app bar showing the count
5. Turn off **Airplane Mode** — the engine auto-syncs
6. Green toast "Pending records synced to server" appears and the badge goes away

The mock API simulates a 2-second delay and randomly fails ~30% of the time by default, so you can see the sync queue retry logic in action.

---

## What's Missing (On Purpose)

- **A real backend** — the assessment doesn't require one. The mock handles it.
- **CI/CD** — easy to add GitHub Actions later
- **Crash reporting** — Sentry or Firebase Crashlytics for production
- **The demo video** — you'll record a 60s clip showing offline save + sync

---

## Built With

- [Flutter](https://flutter.dev)
- [BLoC](https://bloclibrary.dev)
- [Hive](https://docs.hivedb.dev)
- [get_it](https://pub.dev/packages/get_it)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- [Dio](https://pub.dev/packages/dio)
- [mocktail](https://pub.dev/packages/mocktail)
