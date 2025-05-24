# Life Frame

> ⚠️ **Warning**: This project was 85% vibe coded. Proceed with appropriate expectations.

**A picture of your life, one day at a time**

Life Frame is a Flutter application for daily photo journaling that encourages users to capture one photo daily to build a visual timeline of their life.

## Features

- **Daily reminders**: Push notifications to remind users to take their daily photo
- **Dual-camera capture**: Simultaneously captures photos from both front and back cameras
- **Photo stitching**: Combines front and back camera photos into a single composite image
- **Metadata overlay**: Adds date and location text overlay to photos
- **Location tracking**: Stores user location data locally to build a timeline of photo locations
- **Cupertino UI**: iOS-style interface components
- **Theme support**: System color scheme with light/dark mode adaptation

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK ^3.8.0
- iOS/Android development environment

### Installation

1. Clone the repository
```bash
git clone https://github.com/your-username/life_frame.git
cd life_frame
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Development Commands

- **Run the app**: `flutter run`
- **Build for Android**: `flutter build apk`
- **Build for iOS**: `flutter build ios`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format .`
- **Install dependencies**: `flutter pub get`
- **Upgrade dependencies**: `flutter pub upgrade`

## Architecture

- **Entry point**: `lib/main.dart` - Standard Flutter app structure
- **Controllers**: Navigation and photo journal state management
- **Models**: Data structures for daily entries
- **Screens**: UI screens for different app sections
- **Services**: Camera, storage, notifications, and photo processing
- **Widgets**: Reusable UI components

## Key Dependencies

Current:
- `cupertino_icons: ^1.0.8` - iOS style icons
- `flutter_lints: ^5.0.0` - Code linting rules

Future dependencies will likely include:
- Camera plugin for dual-camera capture
- Image processing library for photo stitching
- Location services plugin for GPS tracking
- Local storage solution for photo and location data
- Push notifications plugin for daily reminders

## Contributing

This is an open source project. Contributions are welcome! Please feel free to submit issues and pull requests.

## License

[Add your license here]

---

*Remember: Life happens one photo at a time. 📸*