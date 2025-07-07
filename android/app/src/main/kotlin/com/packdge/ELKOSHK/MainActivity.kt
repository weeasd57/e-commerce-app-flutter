package com.packdge.elkoshk

import android.os.Bundle
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Simple fix for WebView JavaScript errors
        WebView.setWebContentsDebuggingEnabled(false)
    }
}
