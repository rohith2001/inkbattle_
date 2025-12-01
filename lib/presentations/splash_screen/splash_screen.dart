import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/backgroun_scafold.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Check if token exists
      final token = await LocalStorageUtils.fetchToken();
      
      if (token != null && token.isNotEmpty && token.trim().isNotEmpty) {
        // Token exists, verify it's valid by fetching user
        final result = await _userRepository.getMe();
        
        result.fold(
          (failure) {
            // Token invalid or expired, clear it and go to sign in
            print('Token validation failed: ${failure.message}');
            if (mounted) {
              LocalStorageUtils.clear();
              context.go(Routes.signInScreen);
            }
          },
          (user) {
            // Token valid, go to home
            print('User authenticated, navigating to home');
            if (mounted) context.go(Routes.homeScreen);
          },
        );
      } else {
        // No token, go to sign in
        print('No token found, navigating to sign in');
        if (mounted) context.go(Routes.signInScreen);
      }
    } catch (e) {
      print('Error checking auth: $e');
      // On error, go to sign in
      if (mounted) context.go(Routes.signInScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Center(
        child: Image.asset(
          AppImages.logo,
        ),
      ),
    );
  }
}
