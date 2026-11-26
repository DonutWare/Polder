package org.knaapen.polder

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.time.OffsetDateTime

class ServerEntry(
    val id: Long,
    val path: String,
    val name: String,
    val isDir: Boolean,
    val size: Long,
    val mtime: Long?,
    val rev: Long,
    val mime: String,
) {
    companion object {
        val root = ServerEntry(0, "/", "Polder", true, 0, null, 0, "")

        fun from(json: JSONObject) = ServerEntry(
            id = json.getLong("id"),
            path = json.getString("path"),
            name = json.getString("name"),
            isDir = json.getBoolean("isDir"),
            size = json.optLong("size"),
            mtime = runCatching { OffsetDateTime.parse(json.getString("mtime")).toInstant().toEpochMilli() }.getOrNull(),
            rev = json.optLong("rev"),
            mime = json.optString("mime"),
        )
    }
}

class SignedOutException : IOException("Not signed in to Polder")

class ServerStatusException(val status: Int) : IOException("Polder server responded with $status")

private typealias BodyWriter = (HttpURLConnection) -> Unit

class ServerClient(private val context: Context) {
    fun stat(path: String): ServerEntry =
        if (path == "/") ServerEntry.root else ServerEntry.from(json("GET", "/files/stat", mapOf("path" to path)))

    fun list(path: String): List<ServerEntry> {
        val entries = json("GET", "/files/list", mapOf("path" to path)).getJSONArray("entries")
        return List(entries.length()) { ServerEntry.from(entries.getJSONObject(it)) }
    }

    fun download(path: String, target: File) =
        authorized("GET", "/files/content", mapOf("path" to path), null) { connection ->
            connection.inputStream.use { input -> target.outputStream().use { input.copyTo(it) } }
        }

    fun upload(path: String, source: File?, baseRev: Long): ServerEntry {
        val query = mapOf("path" to path, "baseRev" to baseRev.toString())
        return ServerEntry.from(authorized("PUT", "/files/content", query, fileBody(source), ::readJson))
    }

    fun makeDirectory(path: String): ServerEntry =
        ServerEntry.from(json("POST", "/files/mkdir", body = JSONObject().put("path", path)))

    fun move(from: String, to: String): ServerEntry =
        ServerEntry.from(json("POST", "/files/move", body = JSONObject().put("from", from).put("to", to)))

    fun delete(path: String) {
        try {
            authorized("DELETE", "/files", mapOf("path" to path, "baseRev" to "-1"), null) {}
        } catch (_: FileNotFoundException) {
        }
    }

    private fun json(method: String, path: String, query: Map<String, String> = emptyMap(), body: JSONObject? = null) =
        authorized(method, path, query, body?.let(::jsonBody), ::readJson)

    private fun <T> authorized(
        method: String,
        path: String,
        query: Map<String, String>,
        body: BodyWriter?,
        read: (HttpURLConnection) -> T,
    ): T {
        val token = signedIn().accessToken
        val first = open(method, path, query, body, token)
        if (first.responseCode != HttpURLConnection.HTTP_UNAUTHORIZED) return finish(first, read)
        first.disconnect()
        refresh(token)
        return finish(open(method, path, query, body, signedIn().accessToken), read)
    }

    private fun open(
        method: String,
        path: String,
        query: Map<String, String>,
        body: BodyWriter?,
        token: String?,
    ): HttpURLConnection {
        val connection = URL(url(path, query)).openConnection() as HttpURLConnection
        connection.requestMethod = method
        connection.connectTimeout = 30_000
        connection.readTimeout = 60_000
        token?.let { connection.setRequestProperty("Authorization", "Bearer $it") }
        body?.invoke(connection)
        return connection
    }

    private fun <T> finish(connection: HttpURLConnection, read: (HttpURLConnection) -> T): T = try {
        check(connection)
        read(connection)
    } finally {
        connection.disconnect()
    }

    private fun refresh(staleToken: String) = synchronized(this) {
        val current = signedIn()
        if (current.accessToken != staleToken) return
        val request = JSONObject().put("refreshToken", current.refreshToken).put("deviceName", current.deviceName)
        val connection = open("POST", "/auth/refresh", emptyMap(), jsonBody(request), null)
        try {
            if (connection.responseCode == 401 || connection.responseCode == 403) {
                ProviderAccountStore.remove(context)
                throw SignedOutException()
            }
            check(connection)
            val tokens = readJson(connection)
            val renewed = current.copy(
                accessToken = tokens.getString("accessToken"),
                refreshToken = tokens.getString("refreshToken"),
            )
            ProviderAccountStore.save(context, renewed)
        } finally {
            connection.disconnect()
        }
    }

    private fun signedIn(): ProviderAccount = ProviderAccountStore.load(context) ?: throw SignedOutException()

    private fun url(path: String, query: Map<String, String>): String {
        val base = signedIn().serverUrl.trimEnd('/') + "/api/v1" + path
        if (query.isEmpty()) return base
        return base + "?" + query.entries.joinToString("&") { "${encode(it.key)}=${encode(it.value)}" }
    }

    private fun check(connection: HttpURLConnection) {
        when (val status = connection.responseCode) {
            in 200..299 -> return
            401 -> throw SignedOutException()
            404 -> throw FileNotFoundException(connection.url.toString())
            else -> throw ServerStatusException(status)
        }
    }

    private fun readJson(connection: HttpURLConnection) =
        JSONObject(connection.inputStream.bufferedReader().use { it.readText() })

    private fun jsonBody(json: JSONObject): BodyWriter = { connection ->
        val bytes = json.toString().toByteArray()
        connection.doOutput = true
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setFixedLengthStreamingMode(bytes.size)
        connection.outputStream.use { it.write(bytes) }
    }

    private fun fileBody(source: File?): BodyWriter = { connection ->
        connection.doOutput = true
        connection.setRequestProperty("Content-Type", "application/octet-stream")
        connection.setFixedLengthStreamingMode(source?.length() ?: 0L)
        connection.outputStream.use { output -> source?.inputStream()?.use { it.copyTo(output) } }
    }

    private fun encode(value: String) = URLEncoder.encode(value, "UTF-8")
}
