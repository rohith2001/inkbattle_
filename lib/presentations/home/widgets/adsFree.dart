import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
// import 'package:inkbattle_frontend/services/payment_service.dart';
// import 'package:inkbattle_frontend/config/environment.dart';
import 'package:inkbattle_frontend/widgets/video_reward_dialog.dart';

import '../../../main.dart';

class AdsFreePopup extends StatefulWidget {
  final Function(dynamic)? onAdWatched;
  final BuildContext? parentContext;
  const AdsFreePopup({super.key, this.onAdWatched, this.parentContext});

  static void show(BuildContext context, {Function(dynamic)? onAdWatched}) {
    showDialog(
      context: context,
      builder: (ctx) => AdsFreePopup(
        onAdWatched: onAdWatched,
        parentContext: context,
      ),
    );
  }

  @override
  State<AdsFreePopup> createState() => _AdsFreePopupState();
}

class _AdsFreePopupState extends State<AdsFreePopup> {
  final UserRepository _userRepository = UserRepository();
  // final PaymentService _paymentService = PaymentService();
  final GlobalKey _contextKey = GlobalKey();
  bool _isLoading = false;
  RewardedAd? _rewardedAd;
  final bool _adWatched = false;
  bool _isLoadingAd = false;
  bool _adLoadFailed = false;
  bool _shouldClaimReward = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadAd();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _paymentService.initialize();
    // });
  }

  Future<void> _initializeAndLoadAd() async {
    if (_isLoadingAd) return;

    if (!mounted) return;
    setState(() {
      _isLoadingAd = true;
    });
    try {
      await AdService.initializeMobileAds();
      await Future.delayed(const Duration(milliseconds: 500));

      AdService.loadRewardedAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _rewardedAd = ad;
              _isLoadingAd = false;
              _adLoadFailed = false;
            });
            print('✅ RewardedAd loaded successfully');
          }
        },
        onAdFailedToLoad: (error) {
          print('❌ RewardedAd failed to load: $error');
          if (mounted) {
            setState(() {
              _isLoadingAd = false;
              _adLoadFailed = true;
            });
          }
        },
      );
    } catch (e) {
      print('Error initializing ads: $e');
      if (mounted) {
        setState(() {
          _isLoadingAd = false;
          _adLoadFailed = true;
        });
      }
    }
  }

  void _simulateAdWatch() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 500));

      final coins = await _claimReward();
      if (coins != null) {
        widget.onAdWatched?.call(coins);
        // _showRewardAnimation(coins);
      }
    });
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    // _paymentService.dispose();
    super.dispose();
  }

  Future<void> _handleBuyCoins() async {
    // Payment functionality commented out
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment feature is currently unavailable.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    // if (_isProcessingPayment) return;

    // setState(() {
    //   _isProcessingPayment = true;
    // });

    // Timer? timeoutTimer;
    // timeoutTimer = Timer(const Duration(seconds: 5), () {
    //   if (mounted && _isProcessingPayment) {
    //     print('⚠️ Payment dialog timeout - resetting state');
    //     setState(() {
    //       _isProcessingPayment = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Payment dialog did not open. Please try again.'),
    //         backgroundColor: Colors.orange,
    //       ),
    //     );
    //   }
    // });

    // try {
    //   await _paymentService.initiatePayment(
    //     context: context,
    //     onSuccess: (coins) {
    //       timeoutTimer?.cancel();
    //       if (mounted) {
    //         setState(() {
    //           _isProcessingPayment = false;
    //         });
    //         Navigator.pop(context);
    //         widget.onAdWatched?.call(coins);
    //       }
    //     },
    //     onError: () {
    //       timeoutTimer?.cancel();
    //       if (mounted) {
    //         setState(() {
    //           _isProcessingPayment = false;
    //         });
    //       }
    //     },
    //   );
    // } catch (e) {
    //   timeoutTimer?.cancel();
    //   if (mounted) {
    //     setState(() {
    //       _isProcessingPayment = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Failed to initiate payment: $e'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
  }

  Future<void> _watchAd() async {
    if (_rewardedAd == null) {
      print('⚠️ Ad is null, using fallback');
      _simulateAdWatch();
      return;
    }

    _shouldClaimReward = false;
    final adStartTime = DateTime.now();

    setState(() {
      _isLoading = true;
    });

    try {
      final ad = _rewardedAd!;
      _rewardedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (dismissedAd) async {
          final adDuration = DateTime.now().difference(adStartTime).inSeconds;
          print(
              '✅ Ad dismissed - shouldClaim: $_shouldClaimReward, duration: ${adDuration}s');
          dismissedAd.dispose();

          if (!_shouldClaimReward && adDuration >= 5) {
            print(
                '⚠️ onUserEarnedReward not called, but user watched ${adDuration}s - granting reward');
            _shouldClaimReward = true;
          }

          if (_shouldClaimReward) {
            print('✅ Claiming reward...');
            if (mounted) {
              Navigator.of(context).pop();
            }

            // Add sufficient delay for dialog to close completely
            await Future.delayed(const Duration(milliseconds: 800));

            final coins = await _claimReward();
            if (coins != null) {
              widget.onAdWatched?.call(coins);
              // _showRewardAnimation(coins);
            }
          } else {
            print('⚠️ User did not watch full ad (only ${adDuration}s)');
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        onAdFailedToShowFullScreenContent: (failedAd, error) {
          print('❌ Ad failed to show: $error');
          failedAd.dispose();
          setState(() {
            _isLoading = false;
          });
          _simulateAdWatch();
        },
      );

      print('🎬 Showing ad...');
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          print(
              '✅✅✅ User earned reward! Amount: ${reward.amount}, Type: ${reward.type}');
          _shouldClaimReward = true;
          print('🎯 _shouldClaimReward set to: $_shouldClaimReward');
        },
      );
      print('📺 Ad show() method completed');
    } catch (e) {
      print('❌ Error showing ad: $e');
      setState(() {
        _isLoading = false;
      });
      _simulateAdWatch();
    }
  }

  Future<int?> _claimReward() async {
    // Reload ad for next time
    _initializeAndLoadAd();

    final result = await _userRepository.claimAdReward(adType: 'interstitial');
    return result.fold(
      (failure) {
        print('❌ Failed to claim reward: ${failure.message}');
        _showErrorSnackBar(failure.message);
        return null;
      },
      (data) {
        final coinsAwarded = data['coinsAwarded'] ?? 1000;
        print('✅ Coins awarded: $coinsAwarded');
        return coinsAwarded;
      },
    );
  }

  void _showErrorSnackBar(String message) {
    // Use navigatorKey for global context access - this is always available
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showRewardAnimation(int coinsAwarded) {
    print('📍 Attempting to show reward animation with $coinsAwarded coins');

    // Use the global navigatorKey context which is always available
    final BuildContext? contextToUse = navigatorKey.currentContext;

    if (contextToUse == null) {
      print('❌ No global context available');
      return;
    }

    print('📍 Using global context: ${contextToUse.hashCode}');

    // Add post frame callback to ensure we're in a valid build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final freshContext = navigatorKey.currentContext;
      if (freshContext == null || !freshContext.mounted) {
        print('❌ Context not available or not mounted');
        return;
      }

      try {
        print('📍 Showing VideoRewardDialog with fresh context...');

        // Use the static show method which should handle its own context
        VideoRewardDialog.show(
          freshContext,
          coinsAwarded: coinsAwarded,
          onComplete: () {
            print('📍 Video animation completed');
            widget.onAdWatched?.call(coinsAwarded);
          },
        );

        print('📍 VideoRewardDialog.show called successfully');
      } catch (e, stackTrace) {
        print('❌ Error showing reward animation: $e');
        print('❌ Stack trace: $stackTrace');

        // Fallback: try with showDialog directly
        try {
          print('📍 Trying fallback with showDialog...');
          showDialog(
            context: freshContext,
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.7),
            useRootNavigator: true,
            builder: (context) => VideoRewardDialog(
              coinsAwarded: coinsAwarded,
              onComplete: () {
                print('📍 Video animation completed (fallback)');
                Navigator.of(context).pop();
                widget.onAdWatched?.call(coinsAwarded);
              },
            ),
          );
        } catch (e2) {
          print('❌ Fallback also failed: $e2');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isTablet = mq.width > 600;

    final double dialogWidth = isTablet ? mq.width * 0.80 : mq.width * 0.85;
    final double dialogHeight = isTablet ? mq.height * 0.55 : mq.height * 0.6;
    final double coinSize = dialogWidth * 0.30;
    final double closeSize = 30.w;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          key: _contextKey,
          width: dialogWidth,
          decoration: BoxDecoration(
            color: const Color(0xFF002A50),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.blue, width: 2.w),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16.w, coinSize * 0.5 + 12.h, 16.w, 16.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: dialogHeight - (coinSize * 0.5),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Get Coins",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          "Choose how you want to unlock\ncoins",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF90C1D6),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 100.h : 80.h,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(AppImages.bluebutton),
                                fit: BoxFit.contain,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _watchAd,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 15.w),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                alignment: Alignment.centerLeft,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              icon: Padding(
                                padding:
                                    EdgeInsets.only(right: 10.w, left: 10.w),
                                child: _isLoading || _isLoadingAd
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 40.w,
                                      ),
                              ),
                              label: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLoadingAd ? "Loading Ad..." : "Watch Ad",
                                    style: GoogleFonts.lato(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _adLoadFailed
                                        ? "Tap to try again"
                                        : "Get 1000 coins",
                                    style: GoogleFonts.lato(
                                      fontSize: 12.sp,
                                      color: _adLoadFailed
                                          ? Colors.orange
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 100.h : 80.h,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(AppImages.yellowbutton),
                                fit: BoxFit.contain,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isProcessingPayment ? null : _handleBuyCoins,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 15.w),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              icon: Padding(
                                padding: EdgeInsets.only(right: 1.w, left: 1.w),
                                child: Image.asset(
                                  AppImages.buycoin,
                                  height: 60.w,
                                  width: 60.w,
                                ),
                              ),
                              label: _isProcessingPayment
                                  ? Center(
                                      child: Text(
                                        "Processing...",
                                        style: GoogleFonts.lato(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Buy",
                                          style: GoogleFonts.lato(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 30.w),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 22.0, bottom: 22.0),
                                          child: Container(
                                            width: 2,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 253, 195, 120),
                                                  Colors.orange,
                                                ],
                                              ),
                                            ),
                                            child: const VerticalDivider(
                                                color: Colors.transparent,
                                                width: 2),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 15.w),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Get 8000 coins",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 14.sp,
                                                      color: Colors.white,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -(coinSize * 0.5),
                left: (dialogWidth - coinSize) / 2,
                child: SizedBox(
                  width: coinSize,
                  height: coinSize,
                  child:
                      Image.asset(AppImages.adsfreecoin, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: -closeSize * 0.50,
                left: -(closeSize * 0.25),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: closeSize,
                    height: closeSize,
                    child: Image.asset(
                      AppImages.closepopup,
                      width: closeSize,
                      height: closeSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
