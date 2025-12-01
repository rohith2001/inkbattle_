import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/models/room_model.dart';

class DrawerSelectionRoller extends StatefulWidget {
  final List<RoomParticipant> participants;
  final Map<String, dynamic> selectedDrawerInfo;
  final String gifPath;
  final VoidCallback onAnimationComplete;
  const DrawerSelectionRoller({
    super.key,
    required this.participants,
    required this.onAnimationComplete, // <<< NEW

    required this.selectedDrawerInfo,
    required this.gifPath,
  });

  @override
  State<DrawerSelectionRoller> createState() => _DrawerSelectionRollerState();
}

class _DrawerSelectionRollerState extends State<DrawerSelectionRoller> {
  late ScrollController _scrollController;
  bool _didAnimate = false;

  final double pillHeight = 46.h;
  final double spacing = 8.h;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRolling());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // 🔥 Rolling Logic
  // ----------------------------------------------------------
  Future<void> _startRolling() async {
    if (_didAnimate || widget.participants.isEmpty) return;

    _didAnimate = true;

    final targetName = widget.selectedDrawerInfo['name'];
    final participants = widget.participants;

    final targetIndex = participants.indexWhere(
      (p) => p.user?.name == targetName,
    );

    if (targetIndex == -1) return;

    const int cycles = 3;
    final totalIndex = targetIndex + participants.length * cycles;

    final double itemExtent = pillHeight + spacing;
    final double offset = totalIndex * itemExtent;

    await _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 2200),
      curve: Curves.easeOutCubic,
    );
    if (mounted) widget.onAnimationComplete();
  }

  @override
  Widget build(BuildContext context) {
    final double pillWidth = 160.w;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_arrow, color: Colors.white, size: 24.h),
        SizedBox(width: 10.w),

        // Outer fixed cyan pill
        Container(
          width: pillWidth,
          height: pillHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: Colors.cyan, width: 3),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildRollingContent(pillWidth),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // 🔥 Only this part scrolls inside the pill
  // ----------------------------------------------------------
  Widget _buildRollingContent(double width) {
    final participants = widget.participants;
    final itemHeight = pillHeight + spacing;

    return ListView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemExtent: itemHeight,
      padding: EdgeInsets.zero,
      itemBuilder: (_, index) {
        final actualIndex = index % participants.length;
        final p = participants[actualIndex];

        return _buildInnerContent(
          p.user?.name ?? "Player",
          p.user?.avatar,
          width,
        );
      },
      itemCount: participants.length * 50, // long loop for rolling
    );
  }

  // ----------------------------------------------------------
  // 🔥 Rolling avatar + name widget (NOT the outer pill)
  // ----------------------------------------------------------
  Widget _buildInnerContent(String name, String? avatarUrl, double width) {
    final String initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Container(
      width: width,
      height: pillHeight,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 32.w,
            height: 32.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? Image.asset(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(initial),
                    )
                  : _fallback(initial),
            ),
          ),

          SizedBox(width: 10.w),

          // Name
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -2.h),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
