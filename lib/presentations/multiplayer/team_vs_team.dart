import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/presentations/widgets/winner.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';

class TeamVsTeamScreen extends StatefulWidget {
  final String category;
  final int points;
  final String roomId;
  final RoomModel roomModel;
  final BannerAd? bannerAd;
  const TeamVsTeamScreen(
      {super.key,
      required this.category,
      required this.points,
      required this.roomId,
      required this.roomModel,
      this.bannerAd});

  @override
  State<TeamVsTeamScreen> createState() => _TeamVsTeamScreenState();
}

class _TeamVsTeamScreenState extends State<TeamVsTeamScreen> {
  // bool isMicEnabled = true;
  bool isButtonPressed = false;
  String? selectedTeam;

  BannerAd? _bannerAd;

  bool _isBannerAdLoaded = false;
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool showTeamSelection = false;

  Future<void> _handleJoinRoom(String code) async {
    try {
      // Join room
      final result = await _roomRepository.joinRoomById(
        roomId: int.parse(code),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to join room: '
                    '${failure.message ?? 'Please check the code and try again.'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (roomResponse) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Successfully joined room! Entry cost: 250 coins'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to game room
            context.push('/game-room/${roomResponse.room?.id}',
                extra: {"selectedTeam": selectedTeam});
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadBannerAd();
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
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final bool isTablet = MediaQuery.of(context).size.width > 600;
        return Scaffold(
          backgroundColor: const Color(0xFF0B2A50),
          body: BlueBackgroundScaffold(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 25.w, vertical: isTablet ? 20.h : 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
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
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: Image.asset(
                            _getCategoryIcon(widget.category),
                            width: 70.w,
                            height: 70.h,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          widget.category,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Which team do you want to start?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            color: const Color(0xFF94AFE7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: selectedTeam == "orange"
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (mounted)
                                    setState(() {
                                      selectedTeam = "orange";
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
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF85CCE6),
                                        Color(0xFF39B7E5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                      horizontal: 15.w,
                                    ),
                                    child: Text(
                                      "Team A",
                                      style: GoogleFonts.lato(
                                        color: const Color(0xFF003143),
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: selectedTeam == "blue"
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (mounted)
                                    setState(() {
                                      selectedTeam = "blue";
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
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF85CCE6),
                                        Color(0xFF39B7E5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                      horizontal: 15.w,
                                    ),
                                    child: Text(
                                      "Team B",
                                      style: GoogleFonts.lato(
                                        color: const Color(0xFF003143),
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CustomSvgImage(
                                  imageUrl: AppImages.userSvg,
                                  width: 12.w,
                                  height: 12.w,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "13/15",
                                  style: GoogleFonts.lato(
                                    color: const Color(0xFFB9C7E7),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 50.w),
                            Row(
                              children: [
                                CustomSvgImage(
                                  imageUrl: AppImages.userSvg,
                                  width: 12.w,
                                  height: 12.w,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "${widget.roomModel.participantCount}/${widget.roomModel.maxPlayers}",
                                  style: GoogleFonts.lato(
                                    color: const Color(0xFFB9C7E7),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 60.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column(
                            //   children: [
                            //     Row(
                            //       children: [
                            //         Image.asset(
                            //           AppImages.mic,
                            //           color: Colors.grey,
                            //           height: 30.h,
                            //           width: 30.w,
                            //         ),
                            //         SizedBox(width: 8.w),
                            //         GestureDetector(
                            //           onTap: () {
                            //             setState(() {
                            //               isMicEnabled = !isMicEnabled;
                            //             });
                            //           },
                            //           child: Image.asset(
                            //             isMicEnabled
                            //                 ? AppImages.toggleon
                            //                 : AppImages.toggleoff,
                            //             width: 45.w,
                            //             height: isTablet ? 35.h : 30.h,
                            //             fit: BoxFit.contain,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     SizedBox(height: 10.h),
                            //     Text(
                            //       "Enable mic for \nreal-time\n discussion",
                            //       style: GoogleFonts.lato(
                            //         color: const Color(0xFF445881),
                            //         fontSize: 12.sp,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // Container(
                            //   height: 50.h,
                            //   width: 1.w,
                            //   color: Colors.white.withOpacity(0.5),
                            //   margin: EdgeInsets.symmetric(horizontal: 16.w),
                            // ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.language,
                                        color: Colors.white, size: 28.sp),
                                    SizedBox(width: isTablet ? 6.w : 4.w),
                                    Text(
                                      "EN",
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18.sp : 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              height: 25.h,
                              width: 1.w,
                              color: Colors.white.withOpacity(0.5),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.yellow, size: 21.sp),
                                    SizedBox(width: isTablet ? 6.w : 4.w),
                                    Text(
                                      "${widget.points}",
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: isTablet ? 44.h : 99.h),
                        GestureDetector(
                          onTap: () {
                            if (!isButtonPressed)
                              _handleJoinRoom(widget.roomId);
                            if (mounted) {
                              setState(() {
                                isButtonPressed = !isButtonPressed;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50.h,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isButtonPressed
                                  ? Colors.green
                                  : const Color.fromARGB(255, 189, 16, 4),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isButtonPressed
                                    ? Text(
                                        "🚀  Let's go!",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Image.asset(
                                            AppImages.coin,
                                            height: 30.h,
                                            width: 30.w,
                                          ),
                                          Text(
                                            "250",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
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
          ),
        );
      },
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case "Fruits":
        return AppImages.fruit;
      case "Animals":
        return AppImages.animal;
      case "Food":
        return AppImages.food;
      case "Movies":
        return AppImages.movies;
      default:
        return AppImages.food;
    }
  }
}
