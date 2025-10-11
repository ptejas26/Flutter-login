import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Google Sign-In
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {
          'success': false,
          'error': 'Google sign-in was cancelled',
        };
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        return {
          'success': false,
          'error': 'Failed to get Google access token',
        };
      }

      // Get user info from Google
      final userInfo = {
        'name': googleUser.displayName ?? '',
        'email': googleUser.email,
        'photoUrl': googleUser.photoUrl,
        'googleId': googleUser.id,
      };

      // For now, we'll create a mock user object since we don't have a backend endpoint for social login
      // In a real app, you would send this data to your backend
      final mockUser = User(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        age: 25, // Default age for social login users
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        version: 0,
      );

      // Generate mock tokens (in real app, these would come from your backend)
      final mockAuthToken = 'google_${googleUser.id}_${DateTime.now().millisecondsSinceEpoch}';
      final mockRefreshToken = 'refresh_${googleUser.id}_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'user': mockUser,
        'authToken': mockAuthToken,
        'refreshToken': mockRefreshToken,
        'provider': 'google',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Google sign-in failed: ${e.toString()}',
      };
    }
  }

  // Apple Sign-In
  static Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.userIdentifier == null) {
        return {
          'success': false,
          'error': 'Apple sign-in was cancelled',
        };
      }

      // Get user info from Apple
      final fullName = credential.givenName != null && credential.familyName != null
          ? '${credential.givenName} ${credential.familyName}'
          : 'Apple User';

      final email = credential.email ?? '${credential.userIdentifier}@privaterelay.appleid.com';

      // Create mock user object
      final mockUser = User(
        id: credential.userIdentifier!,
        name: fullName,
        email: email,
        age: 25, // Default age for social login users
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        version: 0,
      );

      // Generate mock tokens
      final mockAuthToken = 'apple_${credential.userIdentifier}_${DateTime.now().millisecondsSinceEpoch}';
      final mockRefreshToken = 'refresh_${credential.userIdentifier}_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'user': mockUser,
        'authToken': mockAuthToken,
        'refreshToken': mockRefreshToken,
        'provider': 'apple',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Apple sign-in failed: ${e.toString()}',
      };
    }
  }

  // Sign out from Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  // Check if user is signed in with Google
  static Future<bool> isSignedInWithGoogle() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  // Get current Google user
  static Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      return null;
    }
  }
}
