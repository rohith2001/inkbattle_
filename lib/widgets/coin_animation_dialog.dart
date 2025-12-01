import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoinAnimationDialog extends StatefulWidget {
  final int coinsAwarded;
  final VoidCallback? onComplete;

  const CoinAnimationDialog({
    super.key,
    required this.coinsAwarded,
    this.onComplete,
  });

  @override
  State<CoinAnimationDialog> createState() => _CoinAnimationDialogState();

  static void show(
    BuildContext context, {
    required int coinsAwarded,
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => CoinAnimationDialog(
        coinsAwarded: coinsAwarded,
        onComplete: onComplete,
      ),
    );
  }
}

class _CoinAnimationDialogState extends State<CoinAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    
    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete?.call();
      }
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300.w,
        height: 400.h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated coin icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 120.sp,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '+${widget.coinsAwarded}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Coins Earned!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
