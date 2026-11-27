package org.knaapen.polder.drive

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FilesLocationChannel(messenger: BinaryMessenger, private val context: Context) {
    init {
        MethodChannel(messenger, "polder/file_browser").setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enabled" -> result.success(true)
            "connectedAccount" -> result.success(ProviderAccountStore.load(context)?.accountId)
            "connect" -> connect(call, result)
            "disconnect" -> result.success(replaceAccount(null))
            "signal" -> {
                PolderDocumentsProvider.notifyAll(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val account = accountFrom(call)
            ?: return result.error("invalid_arguments", "connect needs an account and a display name", null)
        result.success(replaceAccount(account))
    }

    private fun replaceAccount(account: ProviderAccount?): Map<String, String>? {
        val previous = ProviderAccountStore.load(context)
        if (account == null) ProviderAccountStore.remove(context) else ProviderAccountStore.save(context, account)
        if (previous?.accountId != account?.accountId) PolderDocumentsProvider.clearCache(context)
        PolderDocumentsProvider.notifyAll(context)
        return previous?.revocation()
    }

    private fun accountFrom(call: MethodCall): ProviderAccount? = ProviderAccount(
        accountId = call.argument<String>("accountId") ?: return null,
        serverUrl = call.argument<String>("serverUrl") ?: return null,
        displayName = call.argument<String>("displayName") ?: return null,
        deviceName = call.argument<String>("deviceName") ?: return null,
        accessToken = call.argument<String>("accessToken") ?: return null,
        refreshToken = call.argument<String>("refreshToken") ?: return null,
    )
}
