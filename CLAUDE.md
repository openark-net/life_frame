# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Life Frame is a Flutter application for daily photo journaling - "A picture of your life, one day at a time". The app encourages users to capture one photo daily to build a visual timeline of their life.

### Core Features
- **Daily reminders**: Push notifications to remind users to take their daily photo
- **Dual-camera capture**: Captures photos from both front and back cameras
- **Photo stitching**: Combines front and back camera photos into a single composite image
- **Metadata overlay**: Adds date and location text overlay to photos
- **Location tracking**: Stores user location data locally to build a timeline of photo locations
- **Cupertino UI**: Uses iOS-style interface components
- **Theme support**: Supports system color scheme with light/dark mode adaptation


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

- **Entry point**: `lib/main.dart` contains the standard Flutter app structure with MyApp and MyHomePage widgets
- **Flutter SDK**: Uses Dart SDK ^3.8.0
- **Linting**: Uses `flutter_lints` package with standard Flutter linting rules configured in `analysis_options.yaml`
- **Testing**: Uses `flutter_test` framework for widget and unit tests
- **Platform support**: Configured for both Android and iOS with standard Flutter project structure

## Key Dependencies

Current dependencies:
- `cupertino_icons: ^1.0.8` - iOS style icons
- `flutter_lints: ^5.0.0` - Code linting rules

Future dependencies will likely include:
- Camera plugin for dual-camera capture
- Image processing library for photo stitching
- Location services plugin for GPS tracking
- Local storage solution for photo and location data
- Push notifications plugin for daily reminders

## Implementation Notes

- Use Cupertino widgets (CupertinoApp, CupertinoPageScaffold, etc.) for iOS-style UI
- Implement system theme detection for light/dark mode support
- Store location data and photos locally (consider using sqflite for structured data)
- Photo stitching will require custom image processing logic
- Daily reminder system needs background task scheduling

The project currently contains the default Flutter counter app template and is ready for implementing the daily photo journaling features.

## Debug Screen Structure

The app includes a comprehensive debug screen system for development and testing:

### Adding a New Debug Screen

1. **Create the debug widget**:
   - Place debug widgets in `lib/widgets/debug/`
   - Use CupertinoPageScaffold for consistent UI
   - Import necessary dependencies

2. **Add to debug navigation**:
   - Import your widget in `lib/screens/debug_screen.dart`
   - Add the widget to the `_screens` list
   - Add the tab title to the `_tabTitles` list
   - Add the corresponding tab to the `CupertinoSlidingSegmentedControl`

3. **Example structure**:
   ```dart
   // lib/widgets/debug/my_debug_widget.dart
   import 'package:flutter/cupertino.dart';
   
   class MyDebugWidget extends StatelessWidget {
     const MyDebugWidget({super.key});
   
     @override
     Widget build(BuildContext context) {
       return CupertinoPageScaffold(
         navigationBar: const CupertinoNavigationBar(
           middle: Text('My Debug Feature'),
         ),
         child: SafeArea(
           child: // Your debug content here
         ),
       );
     }
   }
   ```
# Expectations for Code Quality

All the following are expected in a response, most of these are not
hard requirements but are expected to be present in a good solution.

- Readability
- Good names
- Good error handling
- DRY principles
- SOLID principles
- Separation of concerns  
- Testability
- Maintainability
- Scalability
- Do not use comments unless strictly necessary
- Ensure we use theme colors so we can support dark mode

Write me some top tier code. The best code. 
Write me some code that will last a thousand years.

If you have to refactor some surrounding logic
in order to accomplish a better solution, feel free to
do this.

Follow existing patterns in the codebase.


## Logging

We use the Talker library for logging, be sure to have frequent logging at the appropriate level. 

You can get the Talker instance with:
```dart 
Talker talker = Get.find<Talker>();
```

Handle exceptions with
```dart 
} catch (e, st) {
_talker.handle(e, st, 'ahhhh a problem!');
```

There is no talker.good function.
