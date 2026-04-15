package com.alllivesupport.ezanvakti

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.Calendar
import java.util.Locale

class PrayerNotificationReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "prayer_times_permanent"
        private const val NOTIFICATION_ID = 888
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                // Yeniden başlatıldığında foreground service'i başlat
                PrayerForegroundService.start(context)
            }
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                updateNotification(context)
                triggerWidgetUpdate(context)
            }
        }
    }

    private fun updateNotification(context: Context) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val cityName = prefs.getString("flutter.notif_city", null) ?: return
        val fajr    = prefs.getString("flutter.notif_fajr", null)    ?: return
        val sunrise = prefs.getString("flutter.notif_sunrise", null) ?: return
        val dhuhr   = prefs.getString("flutter.notif_dhuhr", null)   ?: return
        val asr     = prefs.getString("flutter.notif_asr", null)     ?: return
        val maghrib = prefs.getString("flutter.notif_maghrib", null) ?: return
        val isha    = prefs.getString("flutter.notif_isha", null)    ?: return

        val times = listOf(fajr, sunrise, dhuhr, asr, maghrib, isha)
        val names = listOf("İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı")

        val cal = Calendar.getInstance()
        val nowStr = String.format(Locale.US, "%02d:%02d",
            cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE))

        var currentName = "Yatsı"
        var currentTime = isha
        var nextName    = "İmsak"
        var nextTime    = fajr

        for (i in times.indices) {
            if (nowStr < times[i]) {
                nextName  = names[i]
                nextTime  = times[i]
                val ci    = if (i == 0) 5 else i - 1
                currentName = names[ci]
                currentTime = times[ci]
                break
            }
        }

        val body = "İmsak: $fajr • Güneş: $sunrise • Öğle: $dhuhr • İkindi: $asr • Akşam: $maghrib • Yatsı: $isha"
        val title = "$cityName - $currentName Vakti  •  Sıradaki: $nextName $nextTime"

        createChannel(context)

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP) }
        val pi = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pi)
            .build()

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, notification)
    }

    private fun triggerWidgetUpdate(context: Context) {
        val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, PrayerWidgetProvider::class.java))
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        context.sendBroadcast(intent)
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Namaz Vakitleri (Sabit)",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Bildirim çubuğunda namaz vakitlerini gösterir."
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }
}
