import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class CoinContainer extends StatelessWidget {
  final int coins;

  const CoinContainer({super.key, this.coins = 0});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Row(
      children: [
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 125.w,
              height: isTablet ? 50.h : 40.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color.fromRGBO(0, 133, 182, 1),
                  width: 2.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    coins.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: -20.w,
              top: -2.h,
              child: Image.asset(
                AppImages.coin,
                height: isTablet ? 50.h : 45.h,
                width: isTablet ? 50.h : 45.w,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
