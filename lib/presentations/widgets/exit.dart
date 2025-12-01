import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class ExitPopUp extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onExit;
  final VoidCallback? continueWaiting;
  final String? text;

  const ExitPopUp({required this.imagePath, this.onExit,this.continueWaiting,this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, fit: BoxFit.contain),
              SizedBox(height: 30.h),
              if(text==null)
              Text(
                'You\'ve been inactive',
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none),
              ),
              if(text==null)
              SizedBox(height: 20.h),
              if(text==null)
              Text(
                'You\'ve been away for a while.\n Want to jump back in?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
              ),
              if(text!=null)
              Text(
                text!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
              ),

              SizedBox(height: 30.h),
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
                      minimumSize: const Size(120, 45),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Exit',
                          style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          AppImages.inactiveexit,
                          height: 25,
                          width: 25,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15.w),
                  ElevatedButton(
                    onPressed: (){
                      continueWaiting?.call();
                      Navigator.pop(context);},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(120, 45),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.resume,
                          height: 25,
                          width: 25,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Resume',
                          style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
