import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class ExitPopUp extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onExit;
  final VoidCallback? continueWaiting;
  final String? text;

  const ExitPopUp({
    required this.imagePath,
    this.onExit,
    this.continueWaiting,
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Prevents popup from becoming too wide on tablets
          maxWidth: isTablet
              ? 420.w
              : MediaQuery.of(context).size.width * 0.9,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 24.h,
            ),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// IMAGE
                SizedBox(
                  height: isTablet ? 120.h : 140.h,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 25.h),

                /// TITLE + MESSAGE
                if (text == null) ...[
                  Text(
                    'You\'ve been inactive',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'You\'ve been away for a while.\nWant to jump back in?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ] else
                  Text(
                    text!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),

                SizedBox(height: 30.h),

                /// BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onExit?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0C9C9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(
                          isTablet ? 140.w : 120.w,
                          45.h,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Exit',
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Image.asset(
                            AppImages.inactiveexit,
                            height: 25.h,
                            width: 25.w,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15.w),

                    ElevatedButton(
                      onPressed: () {
                        continueWaiting?.call();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(
                          isTablet ? 140.w : 120.w,
                          45.h,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.resume,
                            height: 25.h,
                            width: 25.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Resume',
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
