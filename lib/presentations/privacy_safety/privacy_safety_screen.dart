import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';

class PrivacySafetyScreen extends StatefulWidget {
  const PrivacySafetyScreen({super.key});

  @override
  State<PrivacySafetyScreen> createState() => _PrivacySafetyScreenState();
}

class _PrivacySafetyScreenState extends State<PrivacySafetyScreen> {
  bool isToggleOn = false;
  late String randomInstruction;

  @override
  void initState() {
    super.initState();
    randomInstruction =
    """Privacy & Safety.

    1. Data Collection
    We only use your Google account name and profile picture for game display purposes.

    We do not collect or store any other personal information. We do not share your data with advertisers or third-party providers for marketing.

    2. Game Services
    We use third-party services to enable features like drawing and room management.

    These services are strictly for game functionality and do not access your personal data.

    3. Data Deletion & Account Removal
    You can request account removal or data deletion by contacting us at rlcommunity0@gmail.com.

    4. Safety Guidelines
    Play fair and respect others.
    Do not engage in harmful behavior, including racism, caste-based remarks, or blackmail.

    If reported for misconduct, your turn may be skipped or you may be removed from the game.

    5. Ads
    Ads shown in the game are suitable for all age groups. We do not share your data with advertisers.

    6. Age Restrictions
    There are no age restrictions. All suggested words are appropriate for all age groups.

    7. Network & Performance
    We only monitor your network connection and game rooms to ensure smooth gameplay.

    8. Reporting
    A reporting option is available in-game for inappropriate behavior.

    Contact: rlcommunity0@gmail .com""";
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A2A44),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 8.w),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const CustomSvgImage(
                                    imageUrl: AppImages.arrow_back,
                                    height: 25,
                                    width: 25,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Privacy & Safety',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 15.h),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    randomInstruction,
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 10.w),
                //   child: SizedBox(
                //     width:
                //     MediaQuery.of(context).size.width > 600 ? 270.w : 250.w,
                //     height:
                //     MediaQuery.of(context).size.width > 600 ? 75.h : 60.h,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         setState(() {
                //           isToggleOn = !isToggleOn;
                //         });
                //       },
                //       style: ElevatedButton.styleFrom(
                //         padding: EdgeInsets.zero,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10.r),
                //         ),
                //         backgroundColor: Colors.transparent,
                //         shadowColor: Colors.transparent,
                //       ),
                //       child: Material(
                //         type: MaterialType.transparency,
                //         borderRadius: BorderRadius.circular(10.r),
                //         child: InkWell(
                //           borderRadius: BorderRadius.circular(10.r),
                //           splashColor: Colors.blue,
                //           highlightColor: Colors.blue,
                //           onTap: () {
                //             setState(() {
                //               isToggleOn = !isToggleOn;
                //             });
                //           },
                //           child: Container(
                //             width: MediaQuery.of(context).size.width > 600
                //                 ? 270.w
                //                 : 250.w,
                //             height: MediaQuery.of(context).size.width > 600
                //                 ? 75.h
                //                 : 60.h,
                //             padding: EdgeInsets.symmetric(
                //                 horizontal: 12.w, vertical: 15.h),
                //             decoration: const BoxDecoration(
                //               image: DecorationImage(
                //                 image: AssetImage(AppImages.bluebutton),
                //                 fit: BoxFit.fill,
                //               ),
                //             ),
                //             alignment: Alignment.center,
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               children: [
                //                 Text(
                //                   'Tutorial Guide',
                //                   style: GoogleFonts.luckiestGuy(
                //                     color: Colors.white,
                //                     fontSize: 23.sp,
                //                     fontWeight: FontWeight.w400,
                //                   ),
                //                 ),
                //                 // SizedBox(width: 15.w),
                //                 // GestureDetector(
                //                 //   onTap: () {
                //                 //     setState(() {
                //                 //       isToggleOn = !isToggleOn;
                //                 //     });
                //                 //   },
                //                 //   child: SizedBox(
                //                 //     width: 25.w,
                //                 //     height: 30.h,
                //                 //     child: Container(
                //                 //       decoration: BoxDecoration(
                //                 //         color: Colors.white,
                //                 //         borderRadius: BorderRadius.circular(5.0),
                //                 //         border: Border.all(
                //                 //           color: isToggleOn
                //                 //               ? Colors.green
                //                 //               : Colors.grey,
                //                 //           width: 2.0,
                //                 //         ),
                //                 //       ),
                //                 //       alignment: Alignment.center,
                //                 //       child: isToggleOn
                //                 //           ? Icon(
                //                 //         Icons.check,
                //                 //         size: 25.w,
                //                 //         color: Colors.green,
                //                 //       )
                //                 //           : null,
                //                 //     ),
                //                 //   ),
                //                 // ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20.h),
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.all(20.w),
                //   color: Colors.grey,
                //   child: const SizedBox.shrink(),
                // ),
                // SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }
}