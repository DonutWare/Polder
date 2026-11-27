package org.knaapen.polder.drive

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class WallpaperFileProvider : FileProvider()

class MainActivity : FlutterActivity() {
    private val copies = Executors.newSingleThreadExecutor()
    private var shareChannel: PendingIntentChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "polder/wallpaper")
            .setMethodCallHandler { call, result ->
                if (call.method == "set") openSetAsChooser(call, result) else result.notImplemented()
            }
        FilesLocationChannel(messenger, applicationContext)
        DocumentScannerChannel(messenger, applicationContext)
        shareChannel = PendingIntentChannel(
            messenger,
            "polder/share",
            "share",
            intent,
            { SharedContent.from(this, it) },
            { call, result -> if (call.method == "copy") copySharedFile(call, result) else result.notImplemented() },
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        shareChannel?.deliver(intent)
    }

    override fun onDestroy() {
        copies.shutdown()
        super.onDestroy()
    }

    private fun copySharedFile(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")?.let(Uri::parse)
            ?: return result.error("share", "No file to copy", null)
        copies.execute {
            val copied = runCatching { SharedContent.copyToCache(this, uri) }
            runOnUiThread {
                copied.fold({ result.success(it) }, { result.error("share", it.message, null) })
            }
        }
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
