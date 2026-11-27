package org.knaapen.polder.drive

import android.content.Context
import com.google.android.gms.common.moduleinstall.InstallStatusListener
import com.google.android.gms.common.moduleinstall.ModuleInstall
import com.google.android.gms.common.moduleinstall.ModuleInstallClient
import com.google.android.gms.common.moduleinstall.ModuleInstallRequest
import com.google.android.gms.common.moduleinstall.ModuleInstallStatusUpdate
import com.google.android.gms.common.moduleinstall.ModuleInstallStatusUpdate.InstallState
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class DocumentScannerChannel(messenger: BinaryMessenger, private val context: Context) {
    private val installer: ModuleInstallClient by lazy { ModuleInstall.getClient(context) }

    init {
        MethodChannel(messenger, "polder/document_scanner").setMethodCallHandler { call, result ->
            if (call.method == "prepare") prepare(SingleReply(result)) else result.notImplemented()
        }
    }

    private fun prepare(reply: SingleReply) {
        val scanner = runCatching { GmsDocumentScanning.getClient(GmsDocumentScannerOptions.Builder().build()) }
            .getOrElse { return reply.send(false) }
        installer.areModulesAvailable(scanner)
            .addOnSuccessListener { if (it.areModulesAvailable()) reply.send(true) else install(scanner, reply) }
            .addOnFailureListener { reply.send(false) }
    }

    private fun install(scanner: GmsDocumentScanner, reply: SingleReply) {
        val listener = object : InstallStatusListener {
            override fun onInstallStatusUpdated(update: ModuleInstallStatusUpdate) {
                val ready = when (update.installState) {
                    InstallState.STATE_COMPLETED -> true
                    InstallState.STATE_FAILED, InstallState.STATE_CANCELED -> false
                    else -> return
                }
                installer.unregisterListener(this)
                reply.send(ready)
            }
        }
        val request = ModuleInstallRequest.newBuilder().addApi(scanner).setListener(listener).build()
        installer.installModules(request)
            .addOnSuccessListener { response ->
                if (response.areModulesAlreadyInstalled()) {
                    installer.unregisterListener(listener)
                    reply.send(true)
                }
            }
            .addOnFailureListener {
                installer.unregisterListener(listener)
                reply.send(false)
            }
    }

    private class SingleReply(private val result: MethodChannel.Result) {
        private var sent = false

        fun send(ready: Boolean) {
            if (sent) return
            sent = true
            result.success(ready)
        }
    }
}
