import 'dart:async';

/// Voice service stub - Agora SDK disabled. Voice features are no-op.
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  int? currentUserId;
  bool mute = false;
  bool joinedChannel = false;

  Future<bool> initializeAgoraVoiceSDK(int uid) async {
    currentUserId = uid;
    return false; // not available
  }

  Future<void> joinChannel(String channel) async {
    // no-op
  }

  Future<bool> toggleMic({bool? muteOption}) async {
    if (muteOption != null) {
      mute = muteOption;
    } else {
      mute = !mute;
    }
    return false;
  }

  void cleanUp() {
    currentUserId = null;
    mute = false;
    joinedChannel = false;
  }
}
