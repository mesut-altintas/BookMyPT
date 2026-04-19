package com.bookmypt

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CalendarPlugin(private val activity: FlutterActivity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.bookmypt/calendar"
        const val REQUEST_CALENDAR_PERMISSION = 1001
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingCall: MethodCall? = null

    fun register(channel: MethodChannel) {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!hasCalendarPermission()) {
            pendingResult = result
            pendingCall = call
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.READ_CALENDAR),
                REQUEST_CALENDAR_PERMISSION
            )
            return
        }
        handleCall(call, result)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode == REQUEST_CALENDAR_PERMISSION) {
            val pr = pendingResult ?: return
            val pc = pendingCall ?: return
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                handleCall(pc, pr)
            } else {
                pr.success(emptyList<Any>())
            }
            pendingResult = null
            pendingCall = null
        }
    }

    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCalendars" -> result.success(getCalendars())
            "getEvents" -> {
                val calendarId = call.argument<String>("calendarId") ?: return result.success(emptyList<Any>())
                val startMs = call.argument<Long>("startMs") ?: return result.success(emptyList<Any>())
                val endMs = call.argument<Long>("endMs") ?: return result.success(emptyList<Any>())
                result.success(getEvents(calendarId, startMs, endMs))
            }
            else -> result.notImplemented()
        }
    }

    private fun hasCalendarPermission() = ActivityCompat.checkSelfPermission(
        activity, Manifest.permission.READ_CALENDAR
    ) == PackageManager.PERMISSION_GRANTED

    private fun getCalendars(): List<Map<String, Any>> {
        val calendars = mutableListOf<Map<String, Any>>()
        val uri = CalendarContract.Calendars.CONTENT_URI
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.CALENDAR_COLOR,
        )
        val cursor: Cursor? = activity.contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            while (it.moveToNext()) {
                calendars.add(mapOf(
                    "id" to it.getLong(0).toString(),
                    "name" to (it.getString(1) ?: "Takvim"),
                    "color" to it.getInt(2),
                ))
            }
        }
        return calendars
    }

    private fun getEvents(calendarId: String, startMs: Long, endMs: Long): List<Map<String, Any>> {
        val events = mutableListOf<Map<String, Any>>()
        val uri = CalendarContract.Events.CONTENT_URI
        val projection = arrayOf(
            CalendarContract.Events._ID,
            CalendarContract.Events.TITLE,
            CalendarContract.Events.DTSTART,
            CalendarContract.Events.DTEND,
        )
        val selection = "${CalendarContract.Events.CALENDAR_ID} = ? AND " +
            "${CalendarContract.Events.DTEND} > ? AND " +
            "${CalendarContract.Events.DTSTART} < ?"
        val selectionArgs = arrayOf(calendarId, startMs.toString(), endMs.toString())
        val cursor: Cursor? = activity.contentResolver.query(uri, projection, selection, selectionArgs, null)
        cursor?.use {
            while (it.moveToNext()) {
                events.add(mapOf(
                    "id" to it.getLong(0).toString(),
                    "title" to (it.getString(1) ?: "Etkinlik"),
                    "startMs" to it.getLong(2),
                    "endMs" to it.getLong(3),
                ))
            }
        }
        return events
    }
}
