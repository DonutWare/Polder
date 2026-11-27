package org.knaapen.polder.drive

import android.app.Activity
import android.app.ActivityManager
import android.content.Intent
import android.os.Bundle

class IntentForwardActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val forwarded = Intent(intent).setClass(this, MainActivity::class.java)
        val reuseFlags = Intent.FLAG_ACTIVITY_CLEAR_TOP or
            Intent.FLAG_ACTIVITY_SINGLE_TOP or
            (intent.flags and Intent.FLAG_GRANT_READ_URI_PERMISSION)
        val polderTask = existingPolderTask()
        if (polderTask != null) {
            polderTask.startActivity(this, forwarded.setFlags(reuseFlags), null)
        } else {
            startActivity(forwarded.setFlags(reuseFlags or Intent.FLAG_ACTIVITY_NEW_TASK))
        }
        finish()
    }

    private fun existingPolderTask(): ActivityManager.AppTask? =
        getSystemService(ActivityManager::class.java).appTasks.firstOrNull { task ->
            runCatching { task.taskInfo?.baseIntent?.component?.className == MainActivity::class.java.name }
                .getOrDefault(false)
        }
}
