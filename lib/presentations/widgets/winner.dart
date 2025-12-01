import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

// --- Data Model ---
class Team {
  final String name;
  final int score;
  final String avatar;

  Team({required this.name, required this.score, required this.avatar});
}

// --- Helper Widget for Podium Steps ---

// --- Main Popup Widget ---
class TeamWinnerPopup extends StatelessWidget {
  final List<Team> teams;
  final bool isTeamvTeam;
  final Function()? onNext;
  const TeamWinnerPopup({
    super.key,
    this.onNext,
    required this.teams,
    this.isTeamvTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));

    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.score.compareTo(a.score));
    // sortedTeams.add(Team(name: 'New Team', score: 0, avatar: AppImages.av1));
    final first = sortedTeams.isNotEmpty ? sortedTeams[0] : null;
    final second = sortedTeams.length > 1 ? sortedTeams[1] : null;
    final third = sortedTeams.length > 2 ? sortedTeams[2] : null;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isTwoWinners = sortedTeams.length == 2;
    final podiumAsset = isTwoWinners
        ? AppImages.podium_3
        : AppImages
            .podium_3; // Using same asset for 2 or 3 winners for consistency, will use separate pieces below.

    // Define the required heights for the podium bases
    // These values must be adjusted based on the specific podium image heights (podium_1, podium_2_left, etc.)
    final double rank1PodiumHeight =
        170.h; // Taller podium piece (e.g., AppImages.podium_1)
    final double rank2PodiumHeight =
        130.h; // Shorter podium piece (e.g., AppImages.podium_2_left)
    final double rank3PodiumHeight = 90.h; // Shortest podium piece

    return Center(
      child: Container(
        width: 0.9.sw,
        height: 0.80.sh,
        decoration: BoxDecoration(
          color: const Color(0xFF101020),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.blueAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 8.r,
              spreadRadius: 1,
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // --- Ribbon Header ---
              Container(
                height: isTablet ? 140.h : 100.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.redflg),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: ClipRect(
                  child: CustomPaint(
                    painter: RibbonTextPainter(
                      text: "CONGRATULATIONS",
                      textStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: SizedBox(
                      width: 200.w,
                      height: 100.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.h), // Reduce initial gap if 70.h was too much

              // --- PODIUM VISUALIZATION AREA (300h) ---
              Container(
                width: 300.w,
                height: 300.h,
                // Using a Stack to place the podium steps relative to the container center/bottom
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    if (isTwoWinners)
                      // --- TWO WINNERS MODE (Rank 1 and 2, equal width, aligned bottom) ---
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (first != null)
                              _buildPodiumStep(
                                  team: first,
                                  rank: 1,
                                  podiumHeight: rank1PodiumHeight,
                                  podiumAsset: AppImages.podium_1,
                                  isTeamvTeam: isTeamvTeam,
                                  context: context),
                            if (second != null)
                              _buildPodiumStep(
                                  team: second,
                                  rank: 2,
                                  podiumHeight: rank2PodiumHeight,
                                  podiumAsset: AppImages.podium_2,
                                  isTeamvTeam: isTeamvTeam,
                                  context: context),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildPodiumStep(
                              team: second,
                              rank: 2,
                              podiumHeight: rank2PodiumHeight,
                              podiumAsset: AppImages
                                  .podium_2_left, // Use the left piece for 2nd
                              isTeamvTeam: isTeamvTeam,
                              context: context),
                          _buildPodiumStep(
                              team: first,
                              rank: 1,
                              podiumHeight: rank1PodiumHeight,
                              podiumAsset: AppImages.podium_1,
                              isTeamvTeam: isTeamvTeam,
                              context: context),
                          _buildPodiumStep(
                              team: third,
                              rank: 3,
                              podiumHeight: rank3PodiumHeight,
                              podiumAsset: AppImages.podium_3,
                              isTeamvTeam: isTeamvTeam,
                              context: context),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 50.h),

              // --- Next Button ---
              GestureDetector(
                onTap: () {
                  onNext?.call();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 150.w,
                  height: 50.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.winnernextbutton),
                      fit: BoxFit.cover,
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

  Widget _buildPodiumStep(
      {required Team? team,
      required int rank,
      required double podiumHeight,
      required String podiumAsset,
      required bool isTeamvTeam,
      required BuildContext context}) {
    if (team == null) {
      // Return an empty, equally-sized flexible space if the team data is missing
      return const Expanded(child: SizedBox.shrink());
    }

    // Determine the color for the outer circle/glow based on rank
    final Color outerColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey[400]!
            : Colors.brown;
    final double height = rank == 1
        ? -1
        : rank == 2.0
            ? -0.5
            : 0;

    final List<Color> colors = rank == 1
        ? [Color.fromRGBO(234, 185, 45, 1), Color.fromRGBO(54, 52, 49, 1)]
        : rank == 2.0
            ? [Color.fromRGBO(155, 155, 155, 1), Color.fromRGBO(54, 52, 49, 1)]
            : [Color.fromRGBO(188, 110, 69, 1), Color.fromRGBO(54, 52, 49, 1)];
    // Avatar and text column
    final Widget avatarWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Avatar background/border
            Container(
              // margin: EdgeInsets.all(2),
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: rank == 1 ? 25.r : 23.r,
                backgroundImage: AssetImage(team.avatar),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          " ${team.name}",
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            color: team.name == 'Team A' ? Colors.blue : Colors.orange,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          "${team.score}",
          style: GoogleFonts.inter(
            color: Colors.amber,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      width: isTablet ? 70.w : 90.w,
      // height: height,
      // color: Colors.white,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        // mainAxisAlignment: MainAxisAlignment
        // .end, // Aligns all content (avatar + podium) to the bottom
        children: [
          // SizedBox(height: 10.h),
          Align(
            alignment: Alignment(0, height),
            child: avatarWidget,
          ),
          Align(
            alignment: rank == 3 ? Alignment(-1, 1.0) : Alignment(0.0, 1.0),
            child: SizedBox(
              height: podiumHeight,
              child: Image.asset(
                podiumAsset,
                fit: BoxFit
                    .fill, // Ensures the image stretches to fill the container's exact height and width
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter for Ribbon Text (Unchanged) ---
class RibbonTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  RibbonTextPainter({required this.text, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const curveHeight = 20.0;

    final charCount = text.length;
    final charWidth = textPainter.width / charCount;

    for (int i = 0; i < charCount; i++) {
      final x =
          centerX - (textPainter.width / 2) + (i * charWidth) + (charWidth / 2);
      final y = centerY -
          curveHeight +
          (curveHeight * math.pow((i - charCount / 2) / (charCount / 2), 2));

      final charPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(0);
      charPainter.paint(
          canvas, Offset(-charPainter.width / 2, -charPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
