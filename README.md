# Caller - Custom Android Dialer App

A feature-rich Android dialer application built with Flutter that provides enhanced customization options, ringtone settings, and can be set as the default phone app on your device.

## Features

### Core Functionality
- **Full Dialer Interface**: Complete numeric keypad with call functionality
- **Contact Integration**: Access and display all device contacts
- **Call History**: Track and manage call history with timestamps
- **Default Dialer Support**: Can be set as the default phone app in Android settings

### Customization Options
- **Multi-language Support**: English and Turkish language options
- **Custom Ringtones**: Change default ringtone and calling sounds
- **Vibration Settings**: Customizable vibration feedback
- **Theme Options**: Modern Material Design 3 interface

### Advanced Features
- **Permission Management**: Automatic handling of phone, contacts, and microphone permissions
- **Search Functionality**: Search through contacts easily
- **Persistent Settings**: All preferences saved locally using SharedPreferences
- **Responsive Design**: Works on all Android screen sizes

## Screenshots

The app features a clean, modern interface with four main tabs:
1. **Dialer**: Numeric keypad for entering phone numbers
2. **Contacts**: Browse and search through device contacts
3. **History**: View recent call history
4. **Settings**: Customize app preferences and sounds

## Requirements

### Development Environment
- Flutter SDK 3.22.2 or later
- Dart SDK 3.4.3 or later
- Android Studio or VS Code with Flutter extensions
- Android SDK with minimum API level 21 (Android 5.0)

### Device Requirements
- Android 5.0 (API level 21) or higher
- Phone and contacts permissions
- Microphone permission (for call functionality)

## Installation & Setup

### 1. Clone or Download the Project
```bash
# If using git
git clone <repository-url>
cd caller

# Or download and extract the project files
```

### 2. Install Flutter Dependencies
```bash
# Navigate to the project directory
cd caller

# Get Flutter packages
flutter pub get
```

### 3. Configure Android Permissions
The app requires several permissions that are already configured in `android/app/src/main/AndroidManifest.xml`:

- `CALL_PHONE` - Make phone calls
- `READ_CONTACTS` - Access device contacts
- `WRITE_CONTACTS` - Modify contacts (if needed)
- `READ_PHONE_STATE` - Read phone state information
- `RECORD_AUDIO` - Access microphone during calls
- `VIBRATE` - Provide haptic feedback
- `MODIFY_AUDIO_SETTINGS` - Adjust audio settings
- `ANSWER_PHONE_CALLS` - Answer incoming calls
- `MANAGE_OWN_CALLS` - Manage call states

### 4. Build and Install

#### For Development/Testing
```bash
# Connect your Android device or start an emulator
# Enable USB debugging on your device

# Check connected devices
flutter devices

# Run the app in debug mode
flutter run
```

#### For Production Release
```bash
# Build APK for distribution
flutter build apk --release

# The APK will be generated at:
# build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle for Google Play Store
flutter build appbundle --release

# The bundle will be generated at:
# build/app/outputs/bundle/release/app-release.aab
```

## Setting as Default Dialer

To set Caller as your default phone app:

1. Install the app on your Android device
2. Go to **Settings** > **Apps** > **Default Apps** (or **Default Applications**)
3. Find **Phone app** or **Dialer app** option
4. Select **Caller** from the list
5. Confirm your selection

Alternatively:
1. Open **Settings** > **Apps & notifications**
2. Tap **Advanced** > **Default apps**
3. Tap **Phone app**
4. Select **Caller**

## Project Structure

```
caller/
├── lib/
│   └── main.dart                 # Complete app implementation (single file)
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml  # Permissions and intent filters
├── pubspec.yaml                  # Dependencies and project configuration
└── README.md                     # This file
```

## Dependencies

The app uses the following Flutter packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  url_launcher: ^6.1.12          # Launch phone calls
  permission_handler: ^10.4.3    # Handle runtime permissions
  contacts_service: ^0.6.3       # Access device contacts
  flutter_ringtone_player: ^3.2.0 # Play ringtones and sounds
  shared_preferences: ^2.2.0     # Store app preferences
  flutter_localizations:         # Internationalization support
    sdk: flutter
  intl: ^0.18.1                  # Date formatting and localization
```

## Key Features Implementation

### 1. Dialer Interface
- Numeric keypad with haptic feedback
- Number display with clear/backspace functionality
- Direct call initiation with visual feedback

### 2. Contact Management
- Automatic contact loading with permission handling
- Search functionality (ready for implementation)
- Alphabetical contact display with avatars

### 3. Call History
- Persistent call history storage
- Timestamp formatting with localization
- Quick redial functionality

### 4. Settings & Customization
- Language switching (English/Turkish)
- Ringtone preview and selection
- Vibration settings with immediate feedback
- About section with app information

### 5. Permissions & Security
- Runtime permission requests
- Graceful handling of permission denials
- Secure storage of user preferences

## Localization

The app supports multiple languages:

- **English** (default)
- **Turkish** (Türkçe)

Language can be changed in the Settings tab. All UI elements and messages are localized.

## Troubleshooting

### Common Issues

1. **App not appearing in default dialer list**
   - Ensure all intent filters are properly configured in AndroidManifest.xml
   - Check that the app has phone permissions
   - Restart the device after installation

2. **Contacts not loading**
   - Grant contacts permission when prompted
   - Check device contacts app for existing contacts
   - Restart the app after granting permissions

3. **Calls not working**
   - Ensure phone permission is granted
   - Check if device has active SIM card
   - Verify phone number format

4. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Ensure Android SDK is properly configured

### Debug Commands
```bash
# Check Flutter installation
flutter doctor

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# Run with verbose logging
flutter run -v
```

## Development Notes

### Single File Architecture
The entire app is implemented in a single `main.dart` file for simplicity and easy maintenance. This approach:
- Reduces complexity for small to medium apps
- Makes it easier to understand the complete app flow
- Simplifies debugging and maintenance
- Keeps all related functionality together

### State Management
The app uses Flutter's built-in `setState()` for state management, which is sufficient for this app's scope. For larger applications, consider using:
- Provider
- Riverpod
- Bloc/Cubit
- GetX

### Performance Considerations
- Contact loading is done asynchronously with loading indicators
- Call history is limited to 50 entries to prevent memory issues
- Preferences are cached in memory after initial load

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on different Android versions
5. Submit a pull request

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or feature requests:
1. Check the troubleshooting section above
2. Review Flutter documentation for platform-specific issues
3. Check Android developer documentation for dialer app requirements

## Version History

- **v1.0.0** - Initial release
  - Complete dialer functionality
  - Contact integration
  - Call history
  - Multi-language support
  - Default dialer capability
  - Ringtone customization

---

**Made with Flutter** ❤️

This app demonstrates the power of Flutter for creating native Android applications with complex system integrations.
# Caller
