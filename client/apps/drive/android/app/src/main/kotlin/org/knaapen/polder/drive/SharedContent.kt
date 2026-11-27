package org.knaapen.polder.drive

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import androidx.core.content.IntentCompat
import java.io.File
import java.util.UUID

object SharedContent {
    fun from(context: Context, intent: Intent): Map<String, Any?>? {
        if (intent.action != Intent.ACTION_SEND && intent.action != Intent.ACTION_SEND_MULTIPLE) return null
        val files = streamsOf(intent).distinct().map { describe(context, it) }
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.takeIf { it.isNotBlank() }
        if (files.isEmpty() && text == null) return null
        return mapOf(
            "files" to files,
            "text" to text,
            "subject" to intent.getStringExtra(Intent.EXTRA_SUBJECT),
        )
    }

    fun copyToCache(context: Context, uri: Uri): String {
        val target = File(File(context.cacheDir, "shared"), UUID.randomUUID().toString())
        target.parentFile?.mkdirs()
        val input = context.contentResolver.openInputStream(uri) ?: error("Cannot open $uri")
        input.use { source -> target.outputStream().use { source.copyTo(it) } }
        return target.path
    }

    private fun streamsOf(intent: Intent): List<Uri> {
        val clip = intent.clipData
        val clipped = if (clip == null) emptyList() else (0 until clip.itemCount).mapNotNull { clip.getItemAt(it).uri }
        if (clipped.isNotEmpty()) return clipped
        if (intent.action == Intent.ACTION_SEND_MULTIPLE) {
            return IntentCompat.getParcelableArrayListExtra(intent, Intent.EXTRA_STREAM, Uri::class.java).orEmpty()
        }
        return listOfNotNull(IntentCompat.getParcelableExtra(intent, Intent.EXTRA_STREAM, Uri::class.java))
    }

    private fun describe(context: Context, uri: Uri): Map<String, Any?> {
        val name = runCatching { displayName(context, uri) }.getOrNull()
        val mime = runCatching { context.contentResolver.getType(uri) }.getOrNull()
        return mapOf(
            "uri" to uri.toString(),
            "name" to (name ?: uri.lastPathSegment),
            "extension" to mime?.let { MimeTypeMap.getSingleton().getExtensionFromMimeType(it) },
        )
    }

    private fun displayName(context: Context, uri: Uri): String? =
        context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getString(0) else null
        }
}
