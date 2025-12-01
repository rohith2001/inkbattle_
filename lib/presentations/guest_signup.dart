// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:inkbattle_frontend/constants/app_colors.dart';
// import 'package:inkbattle_frontend/constants/app_images.dart';
// import 'package:inkbattle_frontend/widgets/backgroun_scafold.dart';
// import 'package:inkbattle_frontend/widgets/custom_svg.dart';
// import 'package:inkbattle_frontend/widgets/text_widget.dart';
// import 'package:inkbattle_frontend/widgets/textformfield_widget.dart';
// import 'package:go_router/go_router.dart';
// import 'package:inkbattle_frontend/utils/routes/routes.dart';
// import 'package:inkbattle_frontend/widgets/topCoins.dart';
// import 'package:inkbattle_frontend/repositories/user_repository.dart';
// import 'package:video_player/video_player.dart';

// class GuestSignUpScreen extends StatefulWidget {
//   const GuestSignUpScreen({super.key});

//   @override
//   State<GuestSignUpScreen> createState() => _GuestSignUpScreenState();
// }

// class _GuestSignUpScreenState extends State<GuestSignUpScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _usernameController = TextEditingController();
//   final FocusNode _usernameFocusNode = FocusNode();
//   final UserRepository _userRepository = UserRepository();

//   String? selectedLanguage;
//   String? selectedCountry;
//   XFile? selctedProfilePhoto;
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   int selectedAvatarIndex = 0;
//   bool showAvatarSelection = false;
//   bool _isLoading = false;

//   late AnimationController _controller;
//   late List<Animation<Offset>> _coinDrops;
//   late Animation<double> _textOpacity;
//   VideoPlayerController? _videoController;

//   final List<String> languages = ["Hindi", "Marathi", "English"];
//   final List<String> countries = ["India", "USA", "UK", "Japan"];

//   void _selectAvatar(int index) {
//     setState(() {
//       selectedAvatarIndex = index;
//       selctedProfilePhoto = null;
//     });
//   }

//   void _toggleAvatarSelection() {
//     setState(() {
//       showAvatarSelection = !showAvatarSelection;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     );
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         Future.delayed(const Duration(seconds: 3), () {
//           if (mounted) context.go(Routes.homeScreen);
//         });
//       }
//     });
//     _coinDrops = [];
//     _textOpacity = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
//     );
//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     _videoController = VideoPlayerController.asset(
//       'asset/animationVideos/coin_reward_animation.mp4',
//     );
//     await _videoController!.initialize();
//     _videoController!.setLooping(false);
//     // Don't play immediately - wait until second page is shown
//     if (mounted) setState(() {});
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final random = Random();
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final stackWidth = screenWidth * 0.6;
//     final stackHeight = screenHeight * 0.4;
//     final childSize = screenWidth * 0.1;
//     final radius = min(stackWidth, stackHeight) * 0.15;

//     // Generate 20 coin drop animations - change this number to match coinReward
//     const int numberOfCoins = 20;
//     _coinDrops = List.generate(numberOfCoins, (i) {
//       // Circular pattern: coins drop from top and form a circle
//       final angle =
//           (i * 2 * pi / numberOfCoins) + (random.nextDouble() * pi / 10 - pi / 20);
//       final endDx = (radius * cos(angle)) / childSize;
//       final endDy = (radius * sin(angle)) / childSize;
//       // Random starting positions from top
//       final beginDx = random.nextDouble() * 4 - 2;
//       final beginDy = -(stackHeight / childSize) - (random.nextDouble() * 2);

//       return Tween<Offset>(
//         begin: Offset(beginDx, beginDy),
//         end: Offset(endDx, endDy),
//       ).animate(CurvedAnimation(
//         parent: _controller,
//         // Stagger animation: each coin starts 5% later than previous
//         curve: Interval(i * 0.05, 1.0, curve: Curves.easeOut),
//       ));
//     });
//   }

//   Future<void> _handleGuestSignup() async {
//     // Validate username
//     if (_usernameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a username'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Generate guest name with random suffix
//       final randomSuffix = Random().nextInt(99999).toString().padLeft(5, '0');
//       final guestName = _usernameController.text.trim().isEmpty
//           ? 'Guest_$randomSuffix'
//           : _usernameController.text.trim();

//       // Call backend signup
//       final result = await _userRepository.guestSignup(
//         name: guestName,
//         language: selectedLanguage,
//         country: selectedCountry,
//       );

//       result.fold(
//         (failure) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Signup failed: ${failure.message}'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         (authResponse) {
//           if (mounted) {
//             // Show coin animation page
//             _pageController.nextPage(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeInOut,
//             );
//           }
//         },
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _usernameFocusNode.dispose();
//     _pageController.dispose();
//     _controller.dispose();
//     _videoController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BackgroundScaffold(
//       child: PageView.builder(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 2,
//         onPageChanged: (index) {
//           setState(() => _currentPage = index);
//           if (index == 1) {
//             _controller.forward(from: 0);
//             // Reset and play video when second page is shown
//             if (_videoController != null && _videoController!.value.isInitialized) {
//               _videoController!.seekTo(Duration.zero);
//               _videoController!.play();
//             }
//           }
//         },
//         itemBuilder: (context, index) {
//           if (index == 0) return _buildFirstPage();
//           return _buildSecondPage();
//         },
//       ),
//     );
//   }

//   Widget _buildFirstPage() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             const CoinContainer(coins: 0),
//             SizedBox(height: 0.15.sh),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 30.w),
//               child: Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: _toggleAvatarSelection,
//                         child: Container(
//                           height: 150.h,
//                           width: 150.w,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                                 color: const Color.fromRGBO(9, 189, 255, 1),
//                                 width: 2.w),
//                           ),
//                           child: CircleAvatar(
//                             radius: 75.r,
//                             backgroundColor: Colors.transparent,
//                             child: Icon(Icons.person,
//                                 size: 50.sp, color: Colors.grey[700]),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 10.h,
//                         right: 10.w,
//                         child: GestureDetector(
//                           onTap: _toggleAvatarSelection,
//                           child: Container(
//                             height: 40.h,
//                             width: 40.w,
//                             decoration: const BoxDecoration(
//                               color: Color.fromRGBO(217, 217, 217, 1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Image.asset(
//                               AppImages.pencil,
//                               height: 30.h,
//                               width: 30.w,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (showAvatarSelection) ...[
//                     SizedBox(height: 5.h),
//                     SizedBox(
//                       height: 0.1.sh,
//                       width: double.infinity,
//                       child: Stack(
//                         children: List.generate(4, (index) {
//                           final isSelected = selectedAvatarIndex == index;
//                           double size = 0.15.sw;
//                           if (size < 0.08.sw) size = 0.08.sw;

//                           double centerX = 0.5.sw;
//                           double startY = 0;

//                           double x, y;
//                           if (index == 0) {
//                             x = centerX - (0.30.sw);
//                             y = startY;
//                           } else if (index == 1) {
//                             x = centerX - (0.48.sw);
//                             y = startY + 15.h;
//                           } else if (index == 2) {
//                             x = centerX - (size / 2.0);
//                             y = startY + 1.h;
//                           } else {
//                             x = centerX + (0.10.sw);
//                             y = startY + 15.h;
//                           }

//                           return Positioned(
//                             left: x,
//                             top: y,
//                             child: GestureDetector(
//                               onTap: () => _selectAvatar(index),
//                               child: Container(
//                                 width: size,
//                                 height: size,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.grey.withOpacity(0.5),
//                                     width: 3.w,
//                                   ),
//                                 ),
//                                 child: CircleAvatar(
//                                   radius: size / 3,
//                                   backgroundColor: Colors.transparent,
//                                   child: Icon(
//                                     Icons.person,
//                                     size: size * 0.5,
//                                     color: Colors.grey[400],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                   ],
//                   SizedBox(height: 0.05.sh),
//                   SizedBox(
//                     width: 0.6.sw,
//                     child: TextformFieldWidget(
//                       controller: _usernameController,
//                       focusNode: _usernameFocusNode,
//                       height: 48.h,
//                       rouneded: 15.r,
//                       fontSize: 18.sp,
//                       hintTextColor: const Color.fromRGBO(255, 255, 255, 0.52),
//                       hintText: "Enter username",
//                       prefixIcon: Padding(
//                         padding: EdgeInsets.all(10.w),
//                         child: CustomSvgImage(
//                           imageUrl: AppImages.userSvg,
//                           height: 21.h,
//                           width: 21.w,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 0.03.sh),
//                   SizedBox(
//                     width: 0.6.sw,
//                     child: _buildGradientDropdown(
//                       hint: "Language",
//                       value: selectedLanguage,
//                       items: languages,
//                       prefixIcon: Padding(
//                         padding: EdgeInsets.all(12.w),
//                         child: CustomSvgImage(
//                           imageUrl: AppImages.languageSvg,
//                           height: 21.h,
//                           width: 21.w,
//                         ),
//                       ),
//                       onChanged: (val) =>
//                           setState(() => selectedLanguage = val),
//                     ),
//                   ),
//                   SizedBox(height: 0.03.sh),
//                   SizedBox(
//                     width: 0.6.sw,
//                     child: _buildGradientDropdown(
//                       hint: "Country",
//                       value: selectedCountry,
//                       items: countries,
//                       prefixIcon: Padding(
//                         padding: EdgeInsets.all(12.w),
//                         child: CustomSvgImage(
//                           imageUrl: AppImages.coutrySvg,
//                           height: 21.h,
//                           width: 21.w,
//                         ),
//                       ),
//                       onChanged: (val) => setState(() => selectedCountry = val),
//                     ),
//                   ),
//                   SizedBox(height: 25.h),
//                   InkWell(
//                     onTap: _isLoading ? null : _handleGuestSignup,
//                     child: _isLoading
//                         ? const Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : Row(
//                             children: [
//                               const Spacer(),
//                               TextWidget(
//                                   text: "Next",
//                                   fontSize: 18.sp,
//                                   color: AppColors.whiteColor),
//                               Icon(Icons.navigate_next_outlined,
//                                   color: AppColors.whiteColor, size: 22.sp),
//                             ],
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientDropdown({
//     required String hint,
//     required String? value,
//     required List<String> items,
//     required Widget prefixIcon,
//     required ValueChanged<String?> onChanged,
//   }) {
//     final GlobalKey tapKey = GlobalKey();
//     return Builder(
//       builder: (context) {
//         return Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.all(2.w),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15.r),
//             gradient: const LinearGradient(
//               colors: [
//                 Color.fromRGBO(255, 255, 255, 1),
//                 Color.fromRGBO(9, 189, 255, 1)
//               ],
//             ),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               key: tapKey,
//               borderRadius: BorderRadius.circular(13.r),
//               onTap: () async {
//                 final box =
//                     tapKey.currentContext!.findRenderObject() as RenderBox;
//                 final Offset pos = box.localToGlobal(Offset.zero);
//                 final Size size = box.size;
//                 const double gap = -2.0;
//                 final selected = await showMenu<String>(
//                   context: context,
//                   position: RelativeRect.fromLTRB(
//                       pos.dx,
//                       pos.dy + size.height + gap,
//                       pos.dx + size.width,
//                       pos.dy + size.height + gap),
//                   color: Colors.transparent,
//                   constraints: BoxConstraints(
//                     minWidth: size.width,
//                     maxWidth: size.width,
//                   ),
//                   items: [
//                     PopupMenuItem<String>(
//                       enabled: false,
//                       padding: EdgeInsets.zero,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15.r),
//                           gradient: const LinearGradient(
//                             colors: [
//                               Color.fromRGBO(255, 255, 255, 1),
//                               Color.fromRGBO(9, 189, 255, 1)
//                             ],
//                           ),
//                         ),
//                         padding: EdgeInsets.all(2.w),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15.r),
//                             color: Colors.black,
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: items.asMap().entries.map((entry) {
//                               final index = entry.key;
//                               final e = entry.value;
//                               return Container(
//                                 decoration: BoxDecoration(
//                                   border: index < items.length - 1
//                                       ? const Border(
//                                           bottom: BorderSide(
//                                               color: Color.fromRGBO(
//                                                   255, 255, 255, 0.2),
//                                               width: 3))
//                                       : null,
//                                 ),
//                                 child: InkWell(
//                                   onTap: () => Navigator.pop(context, e),
//                                   child: Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 12.w,
//                                       vertical: 12.h,
//                                     ),
//                                     child: Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(
//                                         e,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18.sp,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//                 if (selected != null) onChanged(selected);
//               },
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(13.r),
//                   color: Colors.black,
//                 ),
//                 child: Row(
//                   children: [
//                     prefixIcon,
//                     SizedBox(width: 8.w),
//                     Expanded(
//                       child: Text(
//                         value ?? hint,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: value == null
//                               ? const Color.fromRGBO(255, 255, 255, 0.52)
//                               : Colors.white,
//                           fontSize: 18.sp,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_drop_down,
//                       size: 35.sp,
//                       color: const Color.fromRGBO(9, 189, 255, 1),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSecondPage() {
//     // Coin reward amount - set to 20 coins for guest signup
//     const int coinReward = 1000;
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
//       child: SafeArea(
//         child: Column(
//           children: [
//             const CoinContainer(coins: coinReward),
//             const Spacer(),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   height: 0.4.sh,
//                   width: 0.6.sw,
//                   child: _videoController != null &&
//                           _videoController!.value.isInitialized
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(15.r),
//                           child: SizedBox.expand(
//                             child: FittedBox(
//                               fit: BoxFit.cover,
//                               child: SizedBox(
//                                 width: _videoController!.value.size.width,
//                                 height: _videoController!.value.size.height,
//                                 child: VideoPlayer(_videoController!),
//                               ),
//                             ),
//                           ),
//                         )
//                       : const Center(
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//                 SizedBox(height: 16.h),
//                 AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     // Animate coin count from 0 to coinReward (20)
//                     final count = (coinReward * _controller.value).round().clamp(0, coinReward);
//                     return TextWidget(
//                       text: "+ $count Coins",
//                       fontSize: 25.sp,
//                       color: AppColors.whiteColor,
//                       fontWeight: FontWeight.bold,
//                     );
//                   },
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Padding(
//                 padding: EdgeInsets.only(bottom: 160.h),
//                 child: TextButton(
//                   onPressed: () => context.go(Routes.homeScreen),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text("Skip ",
//                           style: TextStyle(
//                               color: Colors.white70, fontSize: 14.sp)),
//                       Icon(Icons.arrow_forward_ios,
//                           size: 16.sp, color: Colors.white70),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
