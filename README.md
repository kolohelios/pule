# Pule

A cross-platform prayer list app built with Flutter. "Pule" is Hawaiian for prayer.

Daily-reset checklist with tagging, share sheet, and cloud sync.

## Features

- Add, complete, pause, and delete prayer items
- Tag prayers with colored labels for organization
- Filter prayer list by tags
- Share your prayer list as formatted text
- Daily reset to uncheck all completed items
- Cloud sync: iCloud on iOS, Firebase on Android

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell activation)

### Setup

```sh
# Clone the repository
git clone https://github.com/kolohelios/pule.git
cd pule

# Enter the development shell (provides Flutter and just)
direnv allow    # if using direnv
# or
nix develop     # manual shell entry

# Install dependencies
just deps

# Run code generation (freezed models)
just generate
```

### Development

```sh
# Run the app
just run

# Run all checks (format + analyze + test)
just validate

# Format code
just format

# Run static analysis
just analyze

# Run tests
just test

# Watch for model changes and regenerate
just watch
```

### Building

```sh
# iOS
just build-ios

# Android (requires google-services.json)
just build-android
```

## Architecture

- **Models** (`lib/models/`) - Immutable data models using freezed
- **Repositories** (`lib/repositories/`) - Abstract data layer with platform-specific implementations
  - iCloud via `NSUbiquitousKeyValueStore` on iOS
  - Firebase Firestore on Android
- **Providers** (`lib/providers/`) - Riverpod state management
- **Screens** (`lib/screens/`) - Full-page UI screens
- **Widgets** (`lib/widgets/`) - Reusable components
- **Services** (`lib/services/`) - Share service

## License

MIT
