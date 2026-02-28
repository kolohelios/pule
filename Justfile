# Pule - Prayer List App

# Run all validation checks
validate: format-check analyze test

# Format code
format:
    dart format lib/ test/

# Check formatting without changes
format-check:
    dart format --set-exit-if-changed lib/ test/

# Run static analysis
analyze:
    flutter analyze

# Run tests
test:
    flutter test

# Run code generation (freezed, json_serializable)
generate:
    dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
watch:
    dart run build_runner watch --delete-conflicting-outputs

# Run the app
run:
    flutter run

# Build for iOS
build-ios:
    flutter build ios

# Build for Android
build-android:
    flutter build apk

# Clean build artifacts
clean:
    flutter clean

# Get dependencies
deps:
    flutter pub get
