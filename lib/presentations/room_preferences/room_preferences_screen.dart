import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/theme_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for typography

class RoomPreferencesScreen extends StatefulWidget {
  const RoomPreferencesScreen({super.key});

  @override
  State<RoomPreferencesScreen> createState() => _RoomPreferencesScreenState();
}

class _RoomPreferencesScreenState extends State<RoomPreferencesScreen> {
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final ThemeRepository _themeRepository = ThemeRepository();

  String? selectedLanguage;
  String? selectedCountry;
  String? selectedCategory;
  int? selectedTargetPoints;
  bool voiceEnabled = false;
  bool _isLoading = false;

  // REMOVED: Ad variables
  // BannerAd? _bannerAd;
  // bool _isBannerAdLoaded = false;

  List<String> languages = [];
  final List<String> countries = [
    "🇮🇳 India",
    "🇺🇸 USA",
    "🇬🇧 UK",
    "🇯🇵 Japan",
    "🇪🇸 Spain",
    "🇵🇹 Portugal",
    "🇫🇷 France",
    "🇩🇪 Germany",
    "🇷🇺 Russia"
  ];
  List<String> categories = [];
  final List<int> targetPoints = [50, 100, 150, 200];

  @override
  void initState() {
    super.initState();
    _loadLanguagesAndCategories();
    // REMOVED: _loadBannerAd();
  }

  @override
  void dispose() {
    // REMOVED: _bannerAd?.dispose();
    super.dispose();
  }

  // REMOVED: _loadBannerAd() function

  Future<void> _loadLanguagesAndCategories() async {
    // Load languages
    final languagesResult = await _userRepository.getLanguages();
    languagesResult.fold(
          (failure) {
        // Fallback to default values on error
        if (mounted) {
          setState(() {
            languages = ["English", "Hindi", "Marathi", "Telugu"];
          });
        }
      },
          (languagesList) {
        if (languagesList.isEmpty) {
          // Fallback to default values if empty
          if (mounted) {
            setState(() {
              languages = ["English", "Hindi", "Marathi", "Telugu"];
            });
          }
          return;
        } else {
          if (mounted) {
            setState(() {
              languages = languagesList
                  .map((lang) => lang['languageName'] as String? ?? '')
                  .where((name) => name.isNotEmpty)
                  .toList();
            });
          }
        }
      },
    );

    // Load categories
    final categoriesResult = await _themeRepository.getCategories();
    categoriesResult.fold(
          (failure) {
        // Fallback to default values on error
        if (mounted) {
          setState(() {
            categories = ["Fruits", "Animals", "Food", "Movies"];
          });
        }
      },
          (categoriesList) {
        if (categoriesList.isEmpty) {
          // Fallback to default values if empty
          if (mounted) {
            setState(() {
              categories = ["Fruits", "Animals", "Food", "Movies"];
            });
          }
          return;
        }
        if (mounted) {
          setState(() {
            categories = categoriesList
                .map((cat) => cat['title'] as String? ?? '')
                .where((title) => title.isNotEmpty)
                .toList();
          });
        }
      },
    );
  }

  Future<void> _handlePlayRandom() async {
    // Validate required fields are selected
    if (selectedLanguage == null ||
        selectedCountry == null ||
        selectedCategory == null ||
        selectedTargetPoints == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.pleaseSelectAllFields),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call play random API (backend will check coins)
      final category = selectedCategory;
      final result = await _roomRepository.playRandom(
        language: selectedLanguage,
        country: selectedCountry,
        categories: category != null ? [category] : null,
        targetPoints: selectedTargetPoints,
        voiceEnabled: voiceEnabled,
      );

      result.fold(
            (failure) {
          if (mounted) {
            // Check if it's insufficient coins error
            if (failure.message.contains('insufficient_coins')) {
              _showInsufficientCoinsSnackBar();
            }
            // Check if it's a "no matches found" error
            else if (failure.message.contains('no_matches_found')) {
              _showNoMatchesDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppLocalizations.failedToFindMatch}: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
            (roomResponse) async {
          // Check if match was found
          if (roomResponse.success == true) {
            if (mounted) {
              // Navigate to game room (coins already deducted by backend)
              context.push('/game-room/${roomResponse.room?.id}');
            }
          } else {
            // No matches found
            if (mounted) {
              _showNoMatchesDialog();
            }
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

  // void _showInsufficientCoinsDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF1A1A2E),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20.r),
  //       ),
  //       title: TextWidget(
  //         text: AppLocalizations.insufficientCoinsTitle,
  //         fontSize: 18.sp,
  //         fontWeight: FontWeight.bold,
  //         color: AppColors.whiteColor,
  //       ),
  //       content: TextWidget(
  //         text: AppLocalizations.insufficientCoinsMessage,
  //         fontSize: 14.sp,
  //         color: Colors.grey,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: TextWidget(
  //             text: AppLocalizations.cancel,
  //             fontSize: 14.sp,
  //             color: Colors.grey,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // TODO: Navigate to watch ads screen
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text(AppLocalizations.watchAdsComingSoon)),
  //             );
  //           },
  //           child: TextWidget(
  //             text: AppLocalizations.watchAds,
  //             fontSize: 14.sp,
  //             color: Colors.orange,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // TODO: Navigate to buy coins screen
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text(AppLocalizations.buyCoinsComingSoon)),
  //             );
  //           },
  //           child: TextWidget(
  //             text: AppLocalizations.buyCoins,
  //             fontSize: 14.sp,
  //             color: Colors.green,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showInsufficientCoinsSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: "${AppLocalizations.insufficientCoinsTitle}. ${AppLocalizations.insufficientCoinsMessage}",
          fontSize: 14.sp,
          color: Colors.grey,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }



  void _showNoMatchesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: TextWidget(
          text: AppLocalizations.noMatchesFound,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
        content: TextWidget(
          text: AppLocalizations.noMatchesMessage,
          fontSize: 14.sp,
          color: Colors.grey,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: AppLocalizations.tryAgain,
              fontSize: 14.sp,
              color: Colors.blue,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createPublicRoom();
            },
            child: TextWidget(
              text: AppLocalizations.createRoom,
              fontSize: 14.sp,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPublicRoom() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final category = selectedCategory;
      final result = await _roomRepository.createPublicRoom(
        name: '${category!} Room',
        language: selectedLanguage,
        categories: category != null ? [category] : null,
        country: selectedCountry,
        targetPoints: selectedTargetPoints,
      );

      result.fold(
            (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create room: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
            (roomResponse) async {
          // Deduct 250 coins
          await _userRepository.addCoins(amount: -250, reason: 'room_create');

          if (mounted) {
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
  Widget build(BuildContext context) {
    // Removed manual tablet checks - use ScreenUtil for consistent scaling
    
    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                children: [
                   GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.randomMatch,
                        style: GoogleFonts.orbitron( // Game font
                          fontSize: 24.sp, // Reduced from 26.sp
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 60.w), // Balance back button
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // MAIN CONTENT
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500.w), // Re-introduced constraint
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                          ? 480
                          : 0.82.sw, // was 0.9
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Language
                          _buildGradientDropdown(
                            hint: AppLocalizations.selectLanguage,
                            value: selectedLanguage,
                            items: languages,
                            iconData: Icons.language,
                            onChanged: (v) => setState(() => selectedLanguage = v),
                          ),
                          SizedBox(height: 20.h),

                          // Country
                          _buildGradientDropdown(
                            hint: AppLocalizations.country,
                            value: selectedCountry,
                            items: countries,
                            iconData: Icons.public,
                            onChanged: (v) => setState(() => selectedCountry = v),
                          ),
                          SizedBox(height: 20.h),

                          // Category
                          _buildGradientDropdown(
                            hint: AppLocalizations.selectCategory,
                            value: selectedCategory,
                            items: categories,
                            iconData: Icons.grid_view_rounded,
                            onChanged: (v) => setState(() => selectedCategory = v),
                          ),
                          SizedBox(height: 20.h),

                          // Target Points
                          _buildGradientDropdown(
                            hint: AppLocalizations.selectTargetPoints,
                            value: selectedTargetPoints?.toString(),
                            items: targetPoints.map((e) => e.toString()).toList(),
                            iconData: Icons.ads_click,
                            onChanged: (v) => setState(() =>
                            selectedTargetPoints = int.tryParse(v ?? '100')),
                          ),
                          SizedBox(height: 40.h),

                          // Join button
                          _buildJoinButton(),
                          
                          SizedBox(height: 20.h), // Bottom padding for scrolling
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Persistent Banner Ad (app-wide, loaded once)
            const PersistentBannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return Container(
      width: double.infinity, // Fills the constrained parent
      height: 58.h, // Reduced from 65.h
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00C6FF), // Cyan
            Color(0xFF0072FF), // Blue
          ],
        ),
        borderRadius: BorderRadius.circular(15.r), // Match dropdown radius
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // Remove default padding
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        onPressed: _isLoading ? null : _handlePlayRandom,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            AppLocalizations.playRandomCoins,
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 18.sp, // Kept readable size for button
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData iconData,
    required ValueChanged<String?> onChanged,
  }) {
    final GlobalKey tapKey = GlobalKey();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 0.8),
            Color.fromRGBO(9, 189, 255, 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.2), // Border width
      child: Container(
        height: 58.h, // Reduced from 65.h
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: tapKey,
            borderRadius: BorderRadius.circular(13.r),
            onTap: () async {
              final box = tapKey.currentContext!.findRenderObject() as RenderBox;
              final Offset pos = box.localToGlobal(Offset.zero);
              final Size size = box.size;

              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  pos.dx,
                  pos.dy + size.height + 5,
                  pos.dx + size.width,
                  pos.dy + size.height + 5,
                ),
                color: const Color(0xFF1E1E2C), // Dark dropdown bg
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF09BDFF), width: 1),
                ),
                constraints: BoxConstraints(
                  minWidth: size.width,
                  maxWidth: size.width,
                  maxHeight: 300,
                ),
                items: items.map((e) {
                  return PopupMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                  );
                }).toList(),
              );
              if (selected != null) onChanged(selected);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Ensured center alignment
                children: [
                  Icon(
                    iconData,
                    color: const Color(0xFF09BDFF),
                    size: 24.sp, // Reduced from 28.sp
                  ),
                  SizedBox(width: 15.w), // Slightly reduced spacing
                  Expanded(
                    child: Text(
                      value ?? hint,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.lato(
                        color: value == null ? Colors.white54 : Colors.white,
                        fontSize: 16.sp, // Reduced from 18.sp
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.sp, // Reduced from 30.sp
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

