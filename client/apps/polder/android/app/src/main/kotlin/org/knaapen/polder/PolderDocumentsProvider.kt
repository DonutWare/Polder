package org.knaapen.polder

import android.content.Context
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.CancellationSignal
import android.os.Handler
import android.os.HandlerThread
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.provider.DocumentsContract.Root
import android.provider.DocumentsProvider
import android.util.Log
import android.webkit.MimeTypeMap
import java.io.File
import java.io.FileNotFoundException
import java.util.UUID
import java.util.concurrent.Executors

class PolderDocumentsProvider : DocumentsProvider() {
    private val client by lazy { ServerClient(requireContext()) }
    private val uploads = Executors.newSingleThreadExecutor()
    private val closeHandler by lazy { Handler(HandlerThread("polder-documents").apply { start() }.looper) }

    override fun onCreate() = true

    override fun queryRoots(projection: Array<out String>?): Cursor {
        val context = requireContext()
        val cursor = MatrixCursor(projection ?: rootColumns)
        cursor.setNotificationUri(context.contentResolver, DocumentsContract.buildRootsUri(authority(context)))
        val account = ProviderAccountStore.load(context) ?: return cursor
        cursor.newRow()
            .add(Root.COLUMN_ROOT_ID, account.accountId)
            .add(Root.COLUMN_DOCUMENT_ID, ServerEntry.root.path)
            .add(Root.COLUMN_TITLE, context.applicationInfo.loadLabel(context.packageManager).toString())
            .add(Root.COLUMN_SUMMARY, account.displayName)
            .add(Root.COLUMN_ICON, R.mipmap.ic_launcher)
            .add(Root.COLUMN_FLAGS, Root.FLAG_SUPPORTS_CREATE or Root.FLAG_SUPPORTS_IS_CHILD)
        return cursor
    }

    override fun queryDocument(documentId: String, projection: Array<out String>?): Cursor = server {
        MatrixCursor(projection ?: documentColumns).apply { addEntry(client.stat(documentId)) }
    }

    override fun queryChildDocuments(
        parentDocumentId: String,
        projection: Array<out String>?,
        sortOrder: String?,
    ): Cursor = server {
        val cursor = MatrixCursor(projection ?: documentColumns)
        client.list(parentDocumentId).forEach(cursor::addEntry)
        cursor.setNotificationUri(requireContext().contentResolver, childrenUri(parentDocumentId))
        cursor
    }

    override fun isChildDocument(parentDocumentId: String, documentId: String) =
        parentDocumentId == ServerEntry.root.path || documentId.startsWith("$parentDocumentId/")

    override fun openDocument(documentId: String, mode: String, signal: CancellationSignal?): ParcelFileDescriptor =
        server {
            val accessMode = ParcelFileDescriptor.parseMode(mode)
            val writes = accessMode and ParcelFileDescriptor.MODE_WRITE_ONLY != 0
            val truncates = accessMode and ParcelFileDescriptor.MODE_TRUNCATE != 0
            if (!writes) return@server ParcelFileDescriptor.open(downloaded(documentId), accessMode)
            val file = File(cacheFolder(requireContext(), "write"), UUID.randomUUID().toString())
            if (!truncates) downloaded(documentId).copyTo(file)
            ParcelFileDescriptor.open(file, accessMode, closeHandler) { error ->
                if (error == null) uploads.execute { upload(documentId, file) } else file.delete()
            }
        }

    override fun createDocument(parentDocumentId: String, mimeType: String, displayName: String): String = server {
        val taken = client.list(parentDocumentId).map { it.name }.toSet()
        val path = childPath(parentDocumentId, uniqueFileName(displayName, taken))
        val created = if (mimeType == Document.MIME_TYPE_DIR) client.makeDirectory(path) else client.upload(path, null, 0)
        notifyChildren(parentDocumentId)
        created.path
    }

    override fun deleteDocument(documentId: String) = server {
        client.delete(documentId)
        notifyChildren(parentPath(documentId))
    }

    override fun renameDocument(documentId: String, displayName: String): String? = server {
        val parent = parentPath(documentId)
        val moved = client.move(documentId, childPath(parent, displayName))
        notifyChildren(parent)
        moved.path.takeIf { it != documentId }
    }

    override fun moveDocument(sourceDocumentId: String, sourceParentDocumentId: String, targetParentDocumentId: String) =
        server {
            val target = childPath(targetParentDocumentId, sourceDocumentId.substringAfterLast('/'))
            val moved = client.move(sourceDocumentId, target)
            notifyChildren(sourceParentDocumentId)
            notifyChildren(targetParentDocumentId)
            moved.path
        }

    private fun downloaded(documentId: String): File {
        val entry = client.stat(documentId)
        if (entry.isDir) throw FileNotFoundException("$documentId is a folder")
        val folder = cacheFolder(requireContext(), "read")
        val file = File(folder, "${entry.id}-${entry.rev}")
        if (file.exists()) return file
        folder.listFiles { stale -> stale.name.startsWith("${entry.id}-") }?.forEach(File::delete)
        val partial = File(folder, "${file.name}.part")
        client.download(documentId, partial)
        partial.renameTo(file)
        return file
    }

    private fun upload(documentId: String, file: File) {
        try {
            client.upload(documentId, file, -1)
            notifyChildren(parentPath(documentId))
        } catch (error: Exception) {
            Log.w(tag, "Upload of $documentId failed", error)
        } finally {
            file.delete()
        }
    }

    private fun notifyChildren(parentDocumentId: String) =
        requireContext().contentResolver.notifyChange(childrenUri(parentDocumentId), null)

    private fun childrenUri(parentDocumentId: String) =
        DocumentsContract.buildChildDocumentsUri(authority(requireContext()), parentDocumentId)

    private inline fun <T> server(action: () -> T): T = try {
        action()
    } catch (error: FileNotFoundException) {
        throw error
    } catch (error: Exception) {
        Log.w(tag, "Polder request failed", error)
        throw FileNotFoundException(error.message)
    }

    companion object {
        private const val tag = "PolderDocuments"

        private val rootColumns = arrayOf(
            Root.COLUMN_ROOT_ID,
            Root.COLUMN_DOCUMENT_ID,
            Root.COLUMN_TITLE,
            Root.COLUMN_SUMMARY,
            Root.COLUMN_ICON,
            Root.COLUMN_FLAGS,
        )

        private val documentColumns = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_SIZE,
            Document.COLUMN_LAST_MODIFIED,
            Document.COLUMN_FLAGS,
        )

        fun authority(context: Context) = "${context.packageName}.documents"

        fun notifyAll(context: Context) {
            context.contentResolver.notifyChange(DocumentsContract.buildRootsUri(authority(context)), null)
            context.contentResolver.notifyChange(Uri.parse("content://${authority(context)}/"), null)
        }

        fun clearCache(context: Context) = File(context.cacheDir, "documents").deleteRecursively()

        private fun cacheFolder(context: Context, name: String) =
            File(context.cacheDir, "documents/$name").apply { mkdirs() }
    }
}

private fun MatrixCursor.addEntry(entry: ServerEntry) {
    newRow()
        .add(Document.COLUMN_DOCUMENT_ID, entry.path)
        .add(Document.COLUMN_DISPLAY_NAME, entry.name)
        .add(Document.COLUMN_MIME_TYPE, mimeType(entry))
        .add(Document.COLUMN_SIZE, if (entry.isDir) null else entry.size)
        .add(Document.COLUMN_LAST_MODIFIED, entry.mtime)
        .add(Document.COLUMN_FLAGS, documentFlags(entry))
}

private fun mimeType(entry: ServerEntry): String = when {
    entry.isDir -> Document.MIME_TYPE_DIR
    entry.mime.isNotBlank() -> entry.mime
    else -> MimeTypeMap.getSingleton().getMimeTypeFromExtension(entry.name.substringAfterLast('.', "").lowercase())
        ?: "application/octet-stream"
}

private fun documentFlags(entry: ServerEntry): Int {
    val editable = Document.FLAG_SUPPORTS_DELETE or Document.FLAG_SUPPORTS_RENAME or Document.FLAG_SUPPORTS_MOVE
    return when {
        entry.path == ServerEntry.root.path -> Document.FLAG_DIR_SUPPORTS_CREATE
        entry.isDir -> Document.FLAG_DIR_SUPPORTS_CREATE or editable
        else -> Document.FLAG_SUPPORTS_WRITE or editable
    }
}

private fun parentPath(path: String) = path.substringBeforeLast('/').ifEmpty { "/" }

private fun childPath(parent: String, name: String) = if (parent == "/") "/$name" else "$parent/$name"

private fun uniqueFileName(name: String, taken: Set<String>): String {
    val dot = name.lastIndexOf('.').takeIf { it > 0 } ?: name.length
    val base = name.substring(0, dot)
    val suffix = name.substring(dot)
    var candidate = name
    var number = 2
    while (candidate in taken) candidate = "$base ${number++}$suffix"
    return candidate
}
