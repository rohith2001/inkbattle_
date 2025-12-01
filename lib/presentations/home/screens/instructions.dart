import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool isToggleOn = false;
  late String randomInstruction;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add your code here
      isToggleOn = (await LocalStorageUtils.showTutorial()) ?? true;
      setState(() {});
    });
    randomInstruction = AppLocalizations.instructionsText;
  }

  Future<void> _loadBannerAd() async {
    try {
      // Initialize Mobile Ads SDK first
      await AdService.initializeMobileAds();

      // Load banner ad
      await AdService.loadBannerAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _isBannerAdLoaded = true;
            });
            print('✅ Banner ad loaded successfully');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          key: ValueKey(AppLocalizations
              .getCurrentLanguage()), // Force rebuild on language change
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
                                      AppLocalizations.instructions,
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
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  randomInstruction,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SizedBox(
                    width:
                        MediaQuery.of(context).size.width > 600 ? 270.w : 250.w,
                    height:
                        MediaQuery.of(context).size.width > 600 ? 75.h : 60.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isToggleOn = !isToggleOn;
                          LocalStorageUtils.setTutorialShown(isToggleOn);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        borderRadius: BorderRadius.circular(10.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.r),
                          splashColor: Colors.blue,
                          highlightColor: Colors.blue,
                          onTap: () {
                            setState(() {
                              isToggleOn = !isToggleOn;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 270.w
                                : 250.w,
                            height: MediaQuery.of(context).size.width > 600
                                ? 75.h
                                : 60.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 15.h),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(AppImages.bluebutton),
                                fit: BoxFit.fill,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.tutorialGuide,
                                  style: GoogleFonts.luckiestGuy(
                                    color: Colors.white,
                                    fontSize: 23.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isToggleOn = !isToggleOn;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 25.w,
                                    height: 30.h,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: isToggleOn
                                              ? Colors.green
                                              : Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: isToggleOn
                                          ? Icon(
                                              Icons.check,
                                              size: 25.w,
                                              color: Colors.green,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                if (_isBannerAdLoaded && _bannerAd != null)
                  Container(
                    width: double.infinity,
                    height: 60.h,
                    color: Colors.black.withOpacity(0.3),
                    child: AdWidget(ad: _bannerAd!),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 60.h,
                    color: Colors.grey.withOpacity(0.2),
                    child: Center(
                      child: Text(
                        AppLocalizations.loadingAds,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
