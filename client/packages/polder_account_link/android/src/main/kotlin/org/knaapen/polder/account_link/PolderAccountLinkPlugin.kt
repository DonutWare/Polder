package org.knaapen.polder.account_link

import android.accounts.Account
import android.accounts.AccountManager
import android.accounts.OnAccountsUpdateListener
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PolderAccountLinkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var context: Context
    private lateinit var methods: MethodChannel
    private lateinit var events: EventChannel
    private var listener: OnAccountsUpdateListener? = null

    private val accounts: AccountManager get() = AccountManager.get(context)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methods = MethodChannel(binding.binaryMessenger, "polder/account_link")
        methods.setMethodCallHandler(this)
        events = EventChannel(binding.binaryMessenger, "polder/account_link/changes")
        events.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        stopListening()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "read" -> result.success(read(call.argument<String>("namespace")!!))
                "write" -> {
                    write(call.argument<String>("namespace")!!, call.argument<String>("name")!!, call.argument<String>("json")!!)
                    result.success(null)
                }
                "remove" -> {
                    remove(call.argument<String>("namespace")!!)
                    result.success(null)
                }
                "isInstalled" -> result.success(launchIntent(call.argument<String>("package")!!) != null)
                "open" -> result.success(open(call.argument<String>("package")!!))
                else -> result.notImplemented()
            }
        } catch (error: SecurityException) {
            result.error("forbidden", error.message, null)
        } catch (error: IllegalStateException) {
            result.error("failed", error.message, null)
        }
    }

    private fun accountsOf(namespace: String): Array<Account> = accounts.getAccountsByType(namespace)

    private fun read(namespace: String): String? =
        accountsOf(namespace).firstOrNull()?.let { accounts.getUserData(it, ACCOUNT_KEY) }

    private fun write(namespace: String, name: String, json: String) {
        val existing = accountsOf(namespace)
        val current = existing.firstOrNull { it.name == name }
        if (current != null) {
            accounts.setUserData(current, ACCOUNT_KEY, json)
            existing.filter { it != current }.forEach { accounts.removeAccountExplicitly(it) }
            return
        }
        existing.forEach { accounts.removeAccountExplicitly(it) }
        val userData = Bundle().apply { putString(ACCOUNT_KEY, json) }
        check(accounts.addAccountExplicitly(Account(name, namespace), null, userData)) { "Could not add the Polder account" }
    }

    private fun remove(namespace: String) {
        accountsOf(namespace).forEach { accounts.removeAccountExplicitly(it) }
    }

    private fun launchIntent(packageName: String): Intent? = context.packageManager.getLaunchIntentForPackage(packageName)

    private fun open(packageName: String): Boolean {
        val intent = launchIntent(packageName) ?: return false
        context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        return true
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        stopListening()
        val namespace = arguments as String
        val handler = Handler(Looper.getMainLooper())
        val update = OnAccountsUpdateListener { sink.success(true) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            accounts.addOnAccountsUpdatedListener(update, handler, false, arrayOf(namespace))
        } else {
            accounts.addOnAccountsUpdatedListener(update, handler, false)
        }
        listener = update
    }

    override fun onCancel(arguments: Any?) = stopListening()

    private fun stopListening() {
        listener?.let { accounts.removeOnAccountsUpdatedListener(it) }
        listener = null
    }

    private companion object {
        const val ACCOUNT_KEY = "account"
    }
}
