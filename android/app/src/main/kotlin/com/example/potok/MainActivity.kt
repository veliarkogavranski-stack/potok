package com.example.potok

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Мост к файлам на телефоне.
 *
 * Зачем: системный выбор файлов (SAF) на части прошивок не показывает .fb2 —
 * тип файла ему неизвестен. Поэтому «Поток» показывает свой список книг из
 * обычных папок (Загрузки, Документы, Books). Для чтения нужен доступ
 * «Все файлы» (MANAGE_EXTERNAL_STORAGE) — он выдаётся один раз в настройках.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "potok/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasAccess" -> result.success(hasAllFilesAccess())
                    "requestAccess" -> {
                        openAllFilesSettings()
                        result.success(true)
                    }
                    "listFiles" -> result.success(listBookFiles())
                    "importBook" -> result.success(importBook(call.arguments as? String))
                    "dataDir" -> result.success(filesDir.absolutePath)
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasAllFilesAccess(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            true
        }

    private fun openAllFilesSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                startActivity(
                    Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                        .setData(Uri.parse("package:$packageName"))
                )
            } catch (e: Exception) {
                startActivity(Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION))
            }
        }
    }

    private fun listBookFiles(): List<Map<String, Any>> {
        val extensions = setOf("fb2", "txt", "epub", "docx", "pdf", "doc", "rtf", "odt", "mobi", "azw", "azw3", "prc")
        val roots = ArrayList<File>()
        roots.add(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS))
        roots.add(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS))
        roots.add(File("/storage/emulated/0/Books"))
        roots.add(File("/storage/emulated/0/Поток"))
        roots.add(File("/storage/emulated/0/Download"))
        roots.add(File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS), "Мои книги"))

        val seen = HashSet<String>()
        val out = ArrayList<Map<String, Any>>()
        for (root in roots) {
            if (root == null || !root.exists() || !root.isDirectory) continue
            val files = root.listFiles() ?: continue
            for (f in files) {
                if (!f.isFile) continue
                val ext = f.extension.lowercase()
                if (!extensions.contains(ext)) continue
                val key = f.absolutePath
                if (!seen.add(key)) continue
                out.add(
                    mapOf(
                        "path" to f.absolutePath,
                        "name" to f.name,
                        "size" to f.length(),
                        "folder" to root.name,
                        "modified" to f.lastModified()
                    )
                )
            }
        }
        out.sortWith(compareByDescending<Map<String, Any>> { it["modified"] as Long })
        return out
    }

    /**
     * Каждая открытая книга складывается в Документы/Поток - своя полка читалки.
     * Возвращает путь к копии или null, если скопировать не удалось.
     */
    private fun importBook(srcPath: String?): String? {
        if (srcPath == null) return null
        return try {
            val src = File(srcPath)
            if (!src.exists() || !src.isFile) return null
            val dir = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS),
                "Поток"
            )
            if (!dir.exists()) dir.mkdirs()
            val dst = File(dir, src.name)
            // Тот же файл - копировать нечего, это уже полка.
            if (src.canonicalPath == dst.canonicalPath) return dst.absolutePath
            if (dst.exists() && dst.length() == src.length()) {
                // Такое же имя и размер: считаем, что книга уже на полке.
                dst.setLastModified(System.currentTimeMillis())
                return dst.absolutePath
            }
            src.copyTo(dst, overwrite = true)
            dst.absolutePath
        } catch (e: Exception) {
            null
        }
    }
}
