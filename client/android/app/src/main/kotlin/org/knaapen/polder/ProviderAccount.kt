package org.knaapen.polder

import android.content.Context
import android.util.AtomicFile
import org.json.JSONObject
import java.io.File

data class ProviderAccount(
    val accountId: String,
    val serverUrl: String,
    val displayName: String,
    val deviceName: String,
    val accessToken: String,
    val refreshToken: String,
) {
    fun revocation(): Map<String, String> = mapOf("serverUrl" to serverUrl, "refreshToken" to refreshToken)

    fun toJson(): JSONObject = JSONObject()
        .put("accountId", accountId)
        .put("serverUrl", serverUrl)
        .put("displayName", displayName)
        .put("deviceName", deviceName)
        .put("accessToken", accessToken)
        .put("refreshToken", refreshToken)

    companion object {
        fun fromJson(json: JSONObject) = ProviderAccount(
            accountId = json.getString("accountId"),
            serverUrl = json.getString("serverUrl"),
            displayName = json.getString("displayName"),
            deviceName = json.getString("deviceName"),
            accessToken = json.getString("accessToken"),
            refreshToken = json.getString("refreshToken"),
        )
    }
}

object ProviderAccountStore {
    fun load(context: Context): ProviderAccount? = synchronized(this) {
        val file = file(context)
        if (!file.baseFile.exists()) return null
        runCatching { ProviderAccount.fromJson(JSONObject(String(file.readFully()))) }.getOrNull()
    }

    fun save(context: Context, account: ProviderAccount) = synchronized(this) {
        val file = file(context)
        val stream = file.startWrite()
        try {
            stream.write(account.toJson().toString().toByteArray())
            file.finishWrite(stream)
        } catch (error: Exception) {
            file.failWrite(stream)
            throw error
        }
    }

    fun remove(context: Context) = synchronized(this) { file(context).delete() }

    private fun file(context: Context) = AtomicFile(File(context.noBackupFilesDir, "documents_account.json"))
}
