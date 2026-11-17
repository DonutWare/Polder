package org.knaapen.polder

import android.content.Intent
import android.provider.CalendarContract
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class WallpaperFileProvider : FileProvider()

class MainActivity : FlutterActivity() {
    private var calendarInsertChannel: MethodChannel? = null
    private var pendingCalendarInsert: Map<String, Any?>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "polder/wallpaper")
            .setMethodCallHandler { call, result ->
                if (call.method == "set") openSetAsChooser(call, result) else result.notImplemented()
            }
        pendingCalendarInsert = calendarInsertFrom(intent)
        calendarInsertChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "polder/calendar_insert")
            .apply {
                setMethodCallHandler { call, result ->
                    if (call.method != "takePending") return@setMethodCallHandler result.notImplemented()
                    result.success(pendingCalendarInsert)
                    pendingCalendarInsert = null
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val insert = calendarInsertFrom(intent) ?: return
        calendarInsertChannel?.invokeMethod("insert", insert)
    }

    private fun calendarInsertFrom(intent: Intent?): Map<String, Any?>? {
        if (intent == null || !isCalendarInsert(intent)) return null
        return mapOf(
            "title" to intent.getStringExtra(CalendarContract.Events.TITLE),
            "description" to intent.getStringExtra(CalendarContract.Events.DESCRIPTION),
            "location" to intent.getStringExtra(CalendarContract.Events.EVENT_LOCATION),
            "rrule" to intent.getStringExtra(CalendarContract.Events.RRULE),
            "begin" to intent.longExtraOrNull(CalendarContract.EXTRA_EVENT_BEGIN_TIME),
            "end" to intent.longExtraOrNull(CalendarContract.EXTRA_EVENT_END_TIME),
            "allDay" to intent.getBooleanExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, false),
            "emails" to intent.emailsExtra(),
        )
    }

    private fun isCalendarInsert(intent: Intent): Boolean =
        intent.action == Intent.ACTION_INSERT || intent.action == Intent.ACTION_EDIT

    private fun Intent.longExtraOrNull(name: String): Long? = if (hasExtra(name)) getLongExtra(name, 0) else null

    private fun Intent.emailsExtra(): List<String> {
        val raw = getStringArrayExtra(Intent.EXTRA_EMAIL)?.toList()
            ?: getStringExtra(Intent.EXTRA_EMAIL)?.split(",")
            ?: emptyList()
        return raw.map { it.trim() }.filter { it.isNotEmpty() }
    }

    private fun openSetAsChooser(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("wallpaper", "No image to use", null)
            return
        }
        try {
            val uri = FileProvider.getUriForFile(this, "$packageName.wallpaper_provider", File(path))
            val intent = Intent(Intent.ACTION_ATTACH_DATA).apply {
                addCategory(Intent.CATEGORY_DEFAULT)
                setDataAndType(uri, "image/*")
                putExtra("mimeType", "image/*")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(intent, call.argument<String>("title")))
            result.success(null)
        } catch (error: Exception) {
            result.error("wallpaper", error.message, null)
        }
    }
}
