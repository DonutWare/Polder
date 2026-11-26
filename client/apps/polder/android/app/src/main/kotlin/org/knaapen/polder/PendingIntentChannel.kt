package org.knaapen.polder

import android.content.Intent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PendingIntentChannel(
    messenger: BinaryMessenger,
    name: String,
    private val deliverMethod: String,
    initialIntent: Intent?,
    private val read: (Intent) -> Map<String, Any?>?,
    private val handleOther: (MethodCall, MethodChannel.Result) -> Unit = { _, result -> result.notImplemented() },
) {
    private var pending: Map<String, Any?>? = initialIntent?.let(read)
    private val channel = MethodChannel(messenger, name).apply {
        setMethodCallHandler { call, result ->
            if (call.method != "takePending") return@setMethodCallHandler handleOther(call, result)
            result.success(pending)
            pending = null
        }
    }

    fun deliver(intent: Intent) {
        val payload = read(intent) ?: return
        channel.invokeMethod(deliverMethod, payload)
    }
}
