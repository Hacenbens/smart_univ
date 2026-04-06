# SmartCampus Companion

A Flutter application for university students, providing a smart campus experience with features such as schedules, campus navigation, notifications, and more.

## Tech Stack

- **Flutter 3.x / Dart 3** — null safety by default
- **go_router** — declarative navigation
- **flutter_bloc** — state management (BLoC pattern)
- **get_it** — dependency injection (service locator)
- **equatable** — value equality for BLoC states/events

## Project Structure

```
lib/
├── core/           # Shared utilities, constants, theme, errors
├── features/       # Feature modules (each self-contained)
├── data/           # Repository implementations, data sources, models
├── domain/         # Entities, repository interfaces, use cases
└── presentation/   # Screens, widgets, BLoC (UI layer)
```

## Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Protected — stable releases, merged weekly |
| `dev`  | Active development branch |

## Getting Started

```bash
flutter pub get
flutter run
```
