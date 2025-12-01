import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/adsFree.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/button.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/dailyCoins.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/showRoom.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/models/user_model.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

import '../../../widgets/video_reward_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserRepository _userRepository = UserRepository();
  UserModel? _currentUser;
  bool _isLoading = true;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _hasInitialized = false;
  DateTime? _lastRefreshTime;
  int _headerKey = 0; // Key to force header rebuild

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadBannerAd();
    _hasInitialized = true;
    _lastRefreshTime = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh user data when app resumes
      _loadUserData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we've already initialized (to avoid double loading on first build)
    if (_hasInitialized) {
      // Refresh header when returning to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _headerKey++; // Force header rebuild
          });
          // Load fresh user data
          _userRepository.getUserLocally().then((localUser) {
            if (localUser != null && mounted) {
              setState(() {
                _currentUser = localUser;
                _headerKey++; // Force header rebuild again with new data
              });
            }
            _loadUserData();
          });
        }
      });
    }
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

  Future<void> _loadUserData({bool forceRefresh = false}) async {
    try {
      // First, always try to load from local storage for immediate update
      final localUser = await _userRepository.getUserLocally();
      if (localUser != null && mounted) {
        setState(() {
          _currentUser = localUser;
        });
      }

      // Then refresh from server to get latest data (only if not initial load or forced)
      if (forceRefresh || !_isLoading) {
        final result = await _userRepository.getMe();
        result.fold(
          (failure) {
            print('Failed to load user data: ${failure.message}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          (user) {
            if (mounted) {
              setState(() {
                _currentUser = user;
                _isLoading = false;
              });
            }
          },
        );
      } else {
        // If it's initial load, still fetch from server
        final result = await _userRepository.getMe();
        result.fold(
          (failure) {
            print('Failed to load user data: ${failure.message}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          (user) {
            if (mounted) {
              setState(() {
                _currentUser = user;
                _isLoading = false;
              });
            }
          },
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    // Always refresh header when screen becomes visible (debounced to avoid excessive calls)
    if (_hasInitialized) {
      final now = DateTime.now();
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!).inSeconds > 1) {
        _lastRefreshTime = now;
        // Force header rebuild and load fresh data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Always refresh header when screen is built
            setState(() {
              _headerKey++; // Force header rebuild
            });
            // Load from local storage immediately for instant update
            _userRepository.getUserLocally().then((localUser) {
              if (localUser != null && mounted) {
                setState(() {
                  _currentUser = localUser;
                  _headerKey++; // Force header rebuild again with new data
                });
              }
              // Then refresh from server
              if (!_isLoading) {
                _loadUserData(forceRefresh: true);
              }
            });
          }
        });
      }
    }

    if (_isLoading) {
      return const BlueBackgroundScaffold(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlueBackgroundScaffold(
          child: SafeArea(
            child: SizedBox(
              key: ValueKey(AppLocalizations
                  .getCurrentLanguage()), // Force rebuild on language change
              height: 1.sh,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CustomTopBar(
                    key: ValueKey(_headerKey),
                    user: _currentUser,
                  ),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double circleSize = isTablet ? 0.55.sw : 0.7.sw;
                        circleSize = circleSize.clamp(
                            isTablet ? 300 : 200, isTablet ? 600 : 400);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 3.w,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  AppImages.homelogoPng,
                                  width: circleSize * 0.80,
                                  height: circleSize * 0.80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              left: circleSize * 0.01,
                              top: circleSize * 0.01,
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierColor:
                                          Colors.black.withOpacity(0.8),
                                      builder: (_) => DailyCoinsPopup(
                                        onClaimed: (coins) {
                                          _loadUserData();
                                        },
                                      ),
                                    );
                                  },
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.white24,
                                  highlightColor: Colors.white10,
                                  child: SizedBox(
                                    width: isTablet
                                        ? circleSize * 0.35
                                        : circleSize * 0.3,
                                    height: isTablet
                                        ? circleSize * 0.35
                                        : circleSize * 0.3,
                                    child: Image.asset(
                                      AppImages.dailycoins,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: circleSize * 0.01,
                              bottom: circleSize * 0.01,
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: () {
                                    AdsFreePopup.show(
                                      context,
                                      onAdWatched: (coins) {
                                        VideoRewardDialog.show(
                                          context,
                                          coinsAwarded: coins,
                                          onComplete: () {
                                            print(
                                                '📍 Video animation completed');
                                            // widget.onAdWatched?.call();
                                          },
                                        );
                                        // Refresh user data after ad watched
                                        _loadUserData();
                                      },
                                    );
                                  },
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.white24,
                                  highlightColor: Colors.white10,
                                  child: SizedBox(
                                    width: isTablet
                                        ? circleSize * 0.35
                                        : circleSize * 0.3,
                                    height: isTablet
                                        ? circleSize * 0.35
                                        : circleSize * 0.3,
                                    child: Image.asset(
                                      AppImages.adsfree,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomRoomButton(
                          text: AppLocalizations.playRandom,
                          onPressed: () => context.push('/room-preferences'),
                        ),
                        SizedBox(height: 10.h),
                        CustomRoomButton(
                          text: AppLocalizations.friends,
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.8),
                              builder: (_) => const RoomPopup(),
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        CustomRoomButton(
                          text: AppLocalizations.multiplayer,
                          onPressed: () => context.push(Routes.multiplayer,
                              extra: {'bannerAd': _bannerAd}),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Banner Ad
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
}

class CustomTopBar extends StatefulWidget {
  final UserModel? user;

  const CustomTopBar({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<CustomTopBar> createState() => _CustomTopBarState();
}

class _CustomTopBarState extends State<CustomTopBar> {
  UserModel? _localUser;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    // Load user data from local storage when header is created/refreshed
    _loadUserData();
  }

  @override
  void didUpdateWidget(CustomTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always reload user data when widget is updated (key changed)
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also reload when dependencies change (e.g., when returning from settings)
    // Schedule after build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    // Always load fresh data from local storage
    final localUser = await _userRepository.getUserLocally();
    if (mounted) {
      setState(() {
        _localUser = localUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    // Use local user if available, otherwise use prop user
    final displayUser = _localUser ?? widget.user;
    final coins = displayUser?.coins ?? 0;
    // Default to av3.png if no avatar exists (for both current and new users)
    final avatar = displayUser?.avatar ?? displayUser?.profilePicture ?? AppImages.av3;

    return SafeArea(
      child: SizedBox(
        height: isTablet ? 120.h : 140.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                height: 0.08.sh,
                AppImages.topBarBg,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              left: 0.05.sw,
              top: 0.45 * (isTablet ? 120.h : 140.h),
              child: Row(
                children: [
                  // SETTINGS BUTTON
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 133, 182, 1),
                          width: 1.w,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        splashColor: Colors.blue.withOpacity(1),
                        onTap: () async {
                          await context.push(Routes.settingsScreen);
                          // Trigger rebuild when returning from settings
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: CustomSvgImage(
                            imageUrl: AppImages.settingsSvg,
                            width: 25.w,
                            height: 25.h,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 133, 182, 1),
                          width: 1.w,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        splashColor: Colors.blue.withOpacity(1),
                        onTap: () => context.push(Routes.instructions),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: CustomSvgImage(
                            imageUrl: AppImages.home_menu_iconSvg,
                            width: 25.w,
                            height: 25.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 5.h),
                  padding: EdgeInsets.all(4.w),
                  child: Stack(
                    children: [
                      ClipOval(
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          alignment: Alignment.center,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                avatar,
                                width: 40.w,
                                height: 40.h,
                                fit: BoxFit.cover,
                                cacheWidth:
                                    null, // Disable cache to force reload
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to av3.png if image fails to load
                                  return Image.asset(
                                    AppImages.av3,
                                    width: 40.w,
                                    height: 40.h,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )),
                        ),
                      ),
                      ClipOval(
                        child: Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            AppImages.frameImage,
                            width: 75.w,
                            height: 75.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                AppImages.homeprofile,
                                width: 75.w,
                                height: 75.h,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0.03.sw,
              top: 0.45 * (isTablet ? 110.h : 140.h),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2.w),
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      coins.toString(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -0.08.sw,
                    top: -5.h,
                    child: Image.asset(
                      AppImages.coin,
                      width: isTablet ? 45.w : 40.w,
                      height: isTablet ? 55.h : 50.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
