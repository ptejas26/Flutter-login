# Social Login Setup Guide

This guide explains how to configure Google and Apple Sign-In for your Flutter app.

## Google Sign-In Setup

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google+ API

### 2. Configure OAuth 2.0
1. Go to "Credentials" in the Google Cloud Console
2. Create OAuth 2.0 Client ID
3. Add your app's package name and SHA-1 fingerprint

### 3. Android Configuration
Add to `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
    }
}
```

### 4. iOS Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## Apple Sign-In Setup

### 1. Apple Developer Account
1. Sign in to [Apple Developer Portal](https://developer.apple.com/)
2. Enable "Sign In with Apple" capability

### 2. iOS Configuration
1. In Xcode, select your project
2. Go to "Signing & Capabilities"
3. Add "Sign In with Apple" capability

### 3. Bundle ID Configuration
Ensure your bundle ID matches in:
- Apple Developer Portal
- Xcode project settings
- Flutter app configuration

## Testing

### Google Sign-In
- Works on both Android and iOS
- Requires Google account
- Shows Google account picker

### Apple Sign-In
- Works on iOS 13+ and macOS 10.15+
- Requires Apple ID
- Shows Apple ID authentication

## Current Implementation

The app currently uses mock authentication for demonstration purposes. In a production app, you would:

1. Send social login data to your backend
2. Verify tokens with Google/Apple servers
3. Create or update user accounts
4. Return proper JWT tokens

## Dependencies Added

- `google_sign_in: ^6.1.6` - Google Sign-In SDK
- `sign_in_with_apple: ^5.0.0` - Apple Sign-In SDK

## Features Implemented

✅ Google Sign-In with account picker
✅ Apple Sign-In with Face ID/Touch ID
✅ Token storage and user data persistence
✅ Loading states and error handling
✅ Navigation to home screen after successful login
✅ Logout functionality
✅ Consistent UI with existing design

## Next Steps

1. Configure Google Cloud Console
2. Set up Apple Developer account
3. Add proper backend integration
4. Test on physical devices
5. Handle edge cases and errors
