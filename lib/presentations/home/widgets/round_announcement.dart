import 'dart:async';

import 'package:flutter/material.dart';

class RoundAnnouncementManager {
  final BuildContext context;
  final Function() onAllComplete;

  OverlayEntry? overlay1;
  OverlayEntry? overlay2;
  OverlayEntry? overlay3;
  Timer? _sequenceTimer;

  // Track the visibility state using a list of entries for easy removal
  final List<OverlayEntry> _activeOverlays = [];

  RoundAnnouncementManager({
    required this.context,
    required this.onAllComplete,
    required this.overlay1,
    required this.overlay2,
    required this.overlay3,

  });

  void startAnnouncementSequence({bool? isTimeUp}) {
    // Ensure no existing sequence is running
    print(overlay1);
    clearSequence();

    final overlay = Overlay.of(context);
    if (overlay == null) return;
    print(isTimeUp);
    if (isTimeUp!) {
      overlay.insert(overlay1!);
      _activeOverlays.add(overlay1!);
    }

    // Message 2: After 1.5 seconds
    _sequenceTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!context.mounted) {
        clearSequence();
        return;
      }
      if (isTimeUp!) {
        _removeOverlay(overlay1);
      }

      overlay.insert(overlay2!);
      _activeOverlays.add(overlay2!);

      // Message 3: After another 1.5 seconds
      _sequenceTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!context.mounted) {
          clearSequence();
          return;
        }
        _removeOverlay(overlay2);

        overlay.insert(overlay3!);
        _activeOverlays.add(overlay3!);

        // Final Cleanup: After 1.0 second, remove the final message and trigger phase change
        _sequenceTimer = Timer(const Duration(milliseconds: 2000), () {
          _removeOverlay(overlay3);
          onAllComplete(); // Callback to trigger phase change/word selection
          clearSequence(); // Final cleanup of timer
        });
      });
    });
  }

  // --- 3. CLEANUP ---

  void _removeOverlay(OverlayEntry? entry) {
    if (entry != null && entry.mounted) {
      entry.remove();
      _activeOverlays.remove(entry);
    }
  }

  void clearSequence() {
    _sequenceTimer?.cancel();
    _sequenceTimer = null;

    // Remove all active overlays immediately
    for (var entry in _activeOverlays) {
      if (entry.mounted) {
        entry.remove();
      }
    }
    _activeOverlays.clear();
    // overlay1 = overlay2 = overlay3 = null;
    print('Round announcement sequence cleared.');
  }
}
