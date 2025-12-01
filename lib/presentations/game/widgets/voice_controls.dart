import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/services/voice_service.dart';

class VoiceControls extends StatefulWidget {
  const VoiceControls({super.key});

  @override
  State<VoiceControls> createState() => _VoiceControlsState();
}

class _VoiceControlsState extends State<VoiceControls> {
  final VoiceService _voiceService = VoiceService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _voiceService.mute
                  ? Icons.mic_rounded
                  : Icons.mic_off_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              // setState(() {
              //   _voiceService.
              (_voiceService.currentUserId ?? '');
              // });
            },
          ),
          // IconButton(
          //   icon: Icon(
          //     _voiceService.isSpeakerEnabled
          //         ? Icons.volume_up_rounded
          //         : Icons.volume_off_rounded,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _voiceService.toggleSpeaker();
          //     });
          //   },
          // ),
        ],
      ),
    );
  }
}