package com.inkbattle.app

import android.os.Build
import android.os.Bundle
import android.view.WindowInsetsController
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Use edge-to-edge for Android 15+ (API 35+) to avoid deprecated API warnings
        // This helps mitigate warnings from Flutter's internal use of deprecated APIs
        if (Build.VERSION.SDK_INT >= 35) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
            val insetsController = window.insetsController
            if (insetsController != null) {
                insetsController.systemBarsBehavior = 
                    WindowInsetsController.BEHAVIOR_DEFAULT
            }
        }
    }
}
