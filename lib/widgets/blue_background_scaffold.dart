import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class BlueBackgroundScaffold extends StatelessWidget {
  final Widget child;

  const BlueBackgroundScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.bluebackgroundImg,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SizedBox.expand(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
