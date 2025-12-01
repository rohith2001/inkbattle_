import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/models/user_model.dart';
import 'package:inkbattle_frontend/utils/api/failure.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class FacebookAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final UserRepository _userRepository = UserRepository();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Facebook and register with backend
  Future<AuthResponse?> signInWithFacebook() async {
    try {
      // Trigger the authentication flow
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        // The user canceled the sign-in
        return null;
      }

      if (result.status == LoginStatus.failed) {
        throw Exception('Facebook login failed: ${result.message}');
      }

      // Get the access token
      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        throw Exception('Failed to get Facebook access token');
      }

      // Create a new credential
      final credential = FacebookAuthProvider.credential(accessToken.token);

      // Sign in to Firebase with the Facebook credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Get user info from Facebook
      final userData = await _facebookAuth.getUserData(
        fields: "email,name,picture.width(200).height(200)",
      );

      // Register/Login with backend with retry logic
      // Use default avatar av3.png (same as guest signup)
      final resultBackend = await _retryBackendSignup(
        provider: 'facebook',
        providerId: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? userData['name'] ?? 'Facebook User',
        avatar: AppImages.av3,
      );

      return resultBackend.fold(
        (failure) {
          print('Backend signup failed: ${failure.toString()}');
          return null;
        },
        (authResponse) => authResponse,
      );
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // Retry logic with exponential backoff
  Future<Either<Failure, AuthResponse>> _retryBackendSignup({
    required String provider,
    required String providerId,
    required String name,
    String? avatar,
  }) async {
    int maxRetries = 3;
    int delayMs = 1000;

    for (int i = 0; i < maxRetries; i++) {
      try {
        final result = await _userRepository.signup(
          provider: provider,
          providerId: providerId,
          name: name,
          avatar: avatar,
        );

        // If successful, return immediately
        if (result.isRight()) {
          return result;
        }

        // If it's the last retry, return the failure
        if (i == maxRetries - 1) {
          return result;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Double the delay for next retry
      } catch (e) {
        print('Retry $i failed: $e');
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }

    return left(ApiFailure(message: 'Max retries exceeded'));
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}
