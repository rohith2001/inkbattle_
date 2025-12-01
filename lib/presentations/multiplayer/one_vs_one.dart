import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';

class OneVsOneScreen extends StatefulWidget {
  final String category;
  final int points;
  final String roomId;
  final RoomModel roomModel;
  final BannerAd? bannerAd;
  const OneVsOneScreen({
    super.key,
    required this.category,
    required this.points,
    required this.roomId,
    required this.roomModel,
    this.bannerAd,
  });

  @override
  State<OneVsOneScreen> createState() => _OneVsOneScreenState();
}

class _OneVsOneScreenState extends State<OneVsOneScreen> {
  // bool isMicEnabled = true;
  BannerAd? _bannerAd;

  bool _isBannerAdLoaded = false;

  bool isButtonPressed = false;
  Color gradientStartColor =
      Color.fromRGBO(110, 136, 206, 1); // rgba(110, 136, 206, 1)
  Color gradientEndColor =
      Color.fromRGBO(44, 61, 106, 1); // rgba(44, 61, 106, 1)

  // The thickness of the gradient border
  double borderWidth = 1.2;

  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  String? selectedTeam; // For team rooms
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
                    '${failure.message.isNotEmpty ? failure.message : 'Please check the code and try again.'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (roomResponse) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Successfully joined room! Entry cost: 250 coins'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to game room
            context.push('/game-room/${roomResponse.room?.id}');
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
      builder: (_, __) {
        final isTablet = MediaQuery.of(context).size.shortestSide > 600;

        return BlueBackgroundScaffold(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.w,
              vertical: isTablet ? 20.h : 15.h,
            ),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(50.r + borderWidth),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [gradientStartColor, gradientEndColor],
                          ),
                        ),
                        padding: EdgeInsets.all(borderWidth),
                        child: CircleAvatar(
                          backgroundColor: Color.fromRGBO(26, 42, 81, 1),
                          radius: 50.r,
                          child: Image.asset(
                            _getCategoryIcon(widget.category),
                            width: 70.w,
                            height: 70.h,
                          ),
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
                      SizedBox(height: 8.h),
                      Text(
                        "Are you ready to join Individual Game?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94AFE7),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 25.sp),
                          SizedBox(width: 6.w),
                          Text(
                            "${widget.roomModel.participantCount}/${widget.roomModel.maxPlayers}",
                            style: GoogleFonts.lato(
                              color: const Color(0xFFB9C7E5),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 55.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              // Row(
                              //   children: [
                              //     Image.asset(
                              //       AppImages.mic,
                              //       color: Colors.grey,
                              //       height: 30.h,
                              //       width: 30.w,
                              //     ),
                              //     SizedBox(width: 8.w),
                              //     GestureDetector(
                              //       onTap: () {
                              //         setState(() {
                              //           isMicEnabled = !isMicEnabled;
                              //         });
                              //         print("Mic toggled to $isMicEnabled");
                              //       },
                              //       child: Image.asset(
                              //         isMicEnabled
                              //             ? AppImages.toggleon
                              //             : AppImages.toggleoff,
                              //         width: 45.w,
                              //         height: isTablet ? 35.h : 30.h,
                              //         fit: BoxFit.contain,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 10.h),
                              // Text(
                              //   "Enable mic for \nreal-time\ndiscussion",
                              //   style: GoogleFonts.lato(
                              //     color: const Color(0xFF445881),
                              //     fontSize: 12.sp,
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                            ],
                          ),
                          // Container(
                          //   height: 50.h,
                          //   width: 1.w,
                          //   color: Colors.white.withOpacity(0.5),
                          //   margin: EdgeInsets.symmetric(horizontal: 16.w),
                          // ),
                          Column(
                            children: [
                              Row(children: [
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
                              ]),
                            ],
                          ),
                          Container(
                            height: 50.h,
                            width: 1.w,
                            color: Colors.white.withOpacity(0.5),
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                          Column(
                            children: [
                              Row(children: [
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
                              ]),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 99.h),
                      GestureDetector(
                        onTap: () {
                          if (!isButtonPressed) _handleJoinRoom(widget.roomId);
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
                                  : Row(children: [
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
                                    ])
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
