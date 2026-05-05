# SmartCampus Companion

A Flutter application for university students, providing a smart campus experience with features such as schedules, announcements, events, and more.

## Tech Stack

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC pattern) |
| `go_router` | Declarative navigation with shell routes |
| `get_it` | Dependency injection (service locator) |
| `equatable` | Value equality for entities and BLoC states |
| `dio` | HTTP client with interceptor chain |
| `auth0_flutter` | Auth0 identity provider / token management |
| `json_serializable` + `build_runner` | DTO code generation |
| `path_provider` | Debug log file storage |
| `mocktail` | Mocking in unit tests |
| `local_auth` | Biometric authentication (fingerprint / face) |
| `flutter_secure_storage` | Encrypted token and credential storage |
| `shared_preferences` | User settings persistence |
| `workmanager` | Background task scheduling |
| `flutter_local_notifications` | Local push notifications |

## Architecture

Clean Architecture with strict layer separation enforced by folder convention:

```
lib/
├── core/
│   ├── constants/       # AppConstants (base URL, Auth0 credentials)
│   ├── di/              # GetIt injection container
│   ├── either.dart      # Custom Either<L,R> — replaces fpdart
│   ├── error/           # AppException sealed class
│   ├── network/         # DioClient + interceptors (Auth, Logging, Error)
│   ├── router/          # GoRouter, AuthState, debug observer
│   ├── theme/           # AppTheme (light/dark)
│   ├── usecases/        # UseCase<Type,Params> base interface
│   └── widgets/         # LoadingWidget, AppErrorWidget, EmptyStateWidget
├── data/
│   ├── datasources/     # Remote data sources + Auth0TokenProvider
│   ├── models/          # DTOs with json_serializable + toDomain()
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Pure Dart value objects (Equatable)
│   ├── repositories/    # Abstract interfaces
│   └── usecases/        # Use case classes
└── features/
    ├── announcements/   # AnnouncementsBloc + AnnouncementsPage (category filters)
    ├── auth/            # AuthBloc (email + biometric login)
    ├── events/          # EventsBloc + EventsPage
    ├── settings/        # SettingsBloc (theme, language, biometric toggle)
    └── timetable/       # (planned)
```

### Key Design Decisions

**Either / error handling** — All repository methods and use cases return `Future<Either<AppException, T>>`. Never throw across layer boundaries — wrap in `Left(SomeException(...))`.

**AppException** — Sealed class with four subtypes: `NetworkException`, `AuthException`, `CacheException`, `PermissionException`. Use `switch` for exhaustive handling.

**Dio interceptor chain** — Registration order: `Error → Auth → Logging`. Error interceptor uses `handler.reject()` (not `throw`) so AppException is not re-wrapped by Dio.

**Auth0** — `Auth0TokenProvider` injects `CredentialsManager` directly. `getToken()` reads from secure storage; `refreshToken()` calls `renewCredentials()`.

**Navigation** — Tab routes wrapped in `ShellRoute` with `ScaffoldWithNavBar`. `/login` sits outside the shell. `GoRouter` redirect uses `AuthState` as `refreshListenable`.

**Debug logging** — `LoggingInterceptor` writes structured request/response/error logs to `dio_logs.txt` via `path_provider`. Falls back to console-only in test environments. All log calls are gated behind `kDebugMode` so nothing leaks into release builds.

**Biometric authentication** — `BiometricService` wraps `local_auth`. On first sign-in, credentials are saved to `flutter_secure_storage`. The biometric flow reads the stored profile and calls `restoreSession()` rather than re-sending credentials. The toggle in Settings verifies biometric availability and requires a successful prompt before persisting the preference. Sign-out preserves the stored profile/credentials so biometric re-auth works on the next launch.

**Announcement filters** — `AnnouncementFilter` enum lives in `AnnouncementsState`. The active filter is part of bloc state; filter chip taps dispatch `AnnouncementFilterChanged`. `AnnouncementsPage` is a `StatelessWidget` — no local `setState` for filter selection.

**Screen security** — `FLAG_SECURE` is applied on Android to the auth screen so the content is excluded from recent-apps thumbnails and screen recordings. Release builds use `--obfuscate` and `--split-debug-info` (see `scripts/build_release.sh`).

## Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Protected — stable releases, merged weekly |
| `dev`  | Active development branch |
| `feat/*` | Feature branches, merged into `dev` via PR |

## Getting Started

```bash
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
flutter analyze
```

Run a single test file:

```bash
flutter test test/core/either_test.dart
```
