import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class TeamPlayer {
  final int rank;
  final String name;
  final String avatarPath;
  final String flagEmoji;

  TeamPlayer({
    required this.rank,
    required this.name,
    required this.avatarPath,
    required this.flagEmoji,
  });
}

class TeamDisplayPopup extends StatelessWidget {
  final String teamName;
  final List<TeamPlayer> players;

  const TeamDisplayPopup({
    super.key,
    required this.teamName,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isTablet = mq.width > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 480.w : mq.width * 0.9,
          maxHeight: mq.height * 0.80,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131424),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [

                /// HEADER
                Container(
                  width: double.infinity,
                  height: isTablet ? 110.h : 100.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        (teamName == "Team A" || teamName == "A")
                            ? AppImages.redflg_teamA
                            : AppImages.redflg_teamB,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    teamName,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: isTablet ? 22.sp : 20.sp,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                /// PLAYER LIST
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 8.h),
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(36, 38, 63, 1),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [

                              /// RANK
                              Container(
                                height: isTablet ? 36.h : 30.h,
                                width: isTablet ? 36.w : 30.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1D33),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  '${player.rank}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        isTablet ? 18.sp : 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              SizedBox(width: 15.w),

                              /// AVATAR
                              Container(
                                width: isTablet ? 40.w : 32.w,
                                height: isTablet ? 40.w : 32.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image:
                                        AssetImage(player.avatarPath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(width: 12.w),

                              /// NAME + FLAG
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        player.name,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontSize: isTablet
                                              ? 18.sp
                                              : 17.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      player.flagEmoji,
                                      style: TextStyle(
                                        fontSize: isTablet
                                            ? 20.sp
                                            : 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class RibbonTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  RibbonTextPainter({required this.text, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final centerX = size.width / 2;
    final centerY = size.height / 2.3;
    const curveHeight = 10.0;

    final charCount = text.length;
    final charWidth = textPainter.width / charCount;

    for (int i = 0; i < charCount; i++) {
      final x = centerX -
          (textPainter.width / 2) +
          (i * charWidth) +
          (charWidth / 2);

      final y = centerY -
          curveHeight +
          (curveHeight *
              math.pow(
                  (i - charCount / 2) / (charCount / 2), 2));

      final charPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      charPainter.paint(
        canvas,
        Offset(-charPainter.width / 2,
            -charPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      true;
}
