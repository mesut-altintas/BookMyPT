package com.bookmypt

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var calendarPlugin: CalendarPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        calendarPlugin = CalendarPlugin(this)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CalendarPlugin.CHANNEL
        )
        calendarPlugin.register(channel)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        calendarPlugin.onRequestPermissionsResult(requestCode, grantResults)
    }
}
