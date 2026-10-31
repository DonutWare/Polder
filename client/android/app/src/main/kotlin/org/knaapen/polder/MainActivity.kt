package org.knaapen.polder

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class WallpaperFileProvider : FileProvider()

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "polder/wallpaper")
            .setMethodCallHandler { call, result ->
                if (call.method == "set") openSetAsChooser(call, result) else result.notImplemented()
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
