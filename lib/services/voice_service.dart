import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:inkbattle_frontend/config/environment.dart';
import 'package:inkbattle_frontend/repositories/agora_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inkbattle_frontend/services/socket_service.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();
  RtcEngine? engine;
  final SocketService _socketService = SocketService();
  final AgoraRepository _agoraRepository = AgoraRepository();
  String? token;
  int? currentUserId;
  bool mute = false;
  bool joinedChannel = false;
  // Single PeerConnection for SFU transport
  // Set up the Agora RTC engine instance
  Future<bool> initializeAgoraVoiceSDK(int uid) async {
    engine = createAgoraRtcEngine();
    await engine?.initialize(RtcEngineContext(
      appId: Environment.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    currentUserId = uid;
    // engine!.muteLocalAudioStream(mute);
    return true;
  }

// Join a channel
  Future<void> joinChannel(String channel) async {
    engine!.enableAudio();

    await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    if (!joinedChannel) {
      await engine!.joinChannel(
        token: token!,
        channelId: channel,
        options: const ChannelMediaOptions(
          autoSubscribeAudio:
              true, // Automatically subscribe to all audio streams
          publishMicrophoneTrack: true, // Publish microphone-captured audio
          // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
        uid: currentUserId!,
      );
      joinedChannel = true;
    }
    mute = true;
  }

  Future<bool> toggleMic({bool? muteOption}) async {
    if (muteOption != null) {
      mute = muteOption;
    } else {
      mute = !mute;
    }
    if (engine != null) {
      await engine!.muteLocalAudioStream(mute);
      return true;
    } else {
      return false;
    }
  }

  void cleanUp() {
    if (engine != null) {
      engine!.leaveChannel();
      engine!.release();
    }
    engine = null;
    token = null;
    currentUserId = null;
    mute = false;
    joinedChannel = false;
  }
}
