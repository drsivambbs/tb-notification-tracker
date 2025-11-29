# Setup Guide

## Initial Setup Complete ✅

The following has been configured:

### 1. Flutter Web Project
- ✅ Flutter Web project initialized with Material Design 3
- ✅ Project structure created with organized folders
- ✅ Dependencies added and installed

### 2. Dependencies Installed
- ✅ firebase_core: ^3.8.1
- ✅ cloud_firestore: ^5.5.2
- ✅ firebase_auth: ^5.3.4
- ✅ provider: ^6.1.2
- ✅ go_router: ^14.6.2

### 3. Project Structure
```
lib/
├── models/          ✅ Created (ready for data models)
├── repositories/    ✅ Created (ready for Firebase operations)
├── providers/       ✅ Created (ready for state management)
├── screens/         ✅ Created (ready for UI screens)
├── widgets/         ✅ Created (ready for reusable components)
├── main.dart        ✅ Configured with Material Design 3
└── firebase_options.dart ✅ Placeholder created
```

### 4. PWA Configuration
- ✅ Web manifest configured (`web/manifest.json`)
- ✅ Service worker placeholder created
- ✅ Meta tags added to index.html
- ✅ Theme colors configured

## Next Steps

### Firebase Configuration (Required before Task 3)

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one
   - Enable Firebase Authentication (Email/Password)
   - Create Firestore database

2. **Configure Firebase for Web**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   
   This will:
   - Generate proper `firebase_options.dart` with your project credentials
   - Configure Firebase for your Flutter Web app

3. **Update Security Rules**
   - Security rules will be implemented in Task 12
   - For now, use test mode in Firestore (temporary)

### Running the Application

```bash
# Run in Chrome
flutter run -d chrome

# Run tests
flutter test

# Analyze code
flutter analyze

# Build for production
flutter build web --release
```

### Development Workflow

1. Implement features according to tasks in `.kiro/specs/tb-notification-tracker/tasks.md`
2. Run tests after each implementation
3. Use `flutter analyze` to check for issues
4. Commit changes regularly

## Verification

Run these commands to verify setup:

```bash
# Check Flutter installation
flutter doctor

# Verify dependencies
flutter pub get

# Run analysis
flutter analyze

# Run tests
flutter test
```

All commands should complete successfully! ✅

## Troubleshooting

### Firebase Configuration Issues
- Ensure you've run `flutterfire configure`
- Check that Firebase project is created in console
- Verify API keys are correct in `firebase_options.dart`

### Build Issues
- Run `flutter clean` and `flutter pub get`
- Check Flutter version: `flutter --version`
- Ensure all dependencies are compatible

### PWA Issues
- Test in Chrome/Edge for best PWA support
- Use HTTPS for production deployment
- Check manifest.json is properly linked in index.html
