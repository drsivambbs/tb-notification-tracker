# TB Notification Tracker

A Progressive Web Application (PWA) for managing tuberculosis case notifications, built with Flutter Web.

## Overview

The TB Notification Tracker enables Public Health Centers (PHC) and Senior Treatment Supervisors (STS) to manage TB case notifications. The system provides role-based access control for three user types:
- **Admin Users**: Manage users and view analytics across all PHCs
- **STS Users**: Update case status and Nikshay IDs
- **PHC Users**: Enter new TB case information

## Technology Stack

- **Framework**: Flutter Web (Dart)
- **UI**: Material Design 3
- **Backend**: Firebase (Firestore, Authentication)
- **State Management**: Provider
- **Routing**: go_router
- **PWA**: Service Worker, Web Manifest

## Project Structure

```
lib/
├── models/          # Data models (UserModel, CaseModel)
├── repositories/    # Data access layer (Firebase operations)
├── providers/       # State management (Provider pattern)
├── screens/         # Screen/page widgets
├── widgets/         # Reusable UI components
└── main.dart        # Application entry point
```

## Dependencies

- `firebase_core`: ^3.8.1
- `cloud_firestore`: ^5.5.2
- `firebase_auth`: ^5.3.4
- `provider`: ^6.1.2
- `go_router`: ^14.6.2

## Getting Started

### Prerequisites

- Flutter SDK (3.35.6 or higher)
- Dart SDK (3.9.2 or higher)
- A Firebase project (for backend services)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d chrome
   ```

### Running Tests

```bash
flutter test
```

### Building for Production

```bash
flutter build web --release
```

## PWA Configuration

The application is configured as a Progressive Web App with:
- Web manifest (`web/manifest.json`)
- Service worker for offline caching
- Installable on mobile and desktop devices
- Responsive design for all screen sizes

## Development Status

✅ Project structure initialized
✅ Dependencies configured
✅ Material Design 3 theme setup
✅ PWA manifest configured
⏳ Feature implementation in progress

## License

This project is for healthcare management purposes.
