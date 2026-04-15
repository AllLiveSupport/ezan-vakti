package com.alllivesupport.ezanvakti

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.util.Calendar
import java.util.Locale
import java.util.Timer
import java.util.TimerTask

class PrayerForegroundService : Service() {

    companion object {
        private const val CHANNEL_ID = "prayer_times_foreground"
        private const val NOTIFICATION_ID = 999

        fun start(context: Context) {
            val intent = Intent(context, PrayerForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, PrayerForegroundService::class.java))
        }
    }

    private var timer: Timer? = null

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Her 1 dakikada bir bildirimi güncelle
        timer?.cancel()
        timer = Timer().apply {
            scheduleAtFixedRate(object : TimerTask() {
                override fun run() {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    nm.notify(NOTIFICATION_ID, buildNotification())
                }
            }, 60000, 60000) // 1 dakika
        }
        return START_STICKY // Önemli: sistem servisi yeniden başlatır
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        timer?.cancel()
        // Servis öldürüldüğünde yeniden başlat
        val intent = Intent(applicationContext, PrayerForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            applicationContext.startForegroundService(intent)
        } else {
            applicationContext.startService(intent)
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        // X'a basınca uygulama kapatıldığında servisi yeniden başlat
        timer?.cancel()
        val intent = Intent(applicationContext, PrayerForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            applicationContext.startForegroundService(intent)
        } else {
            applicationContext.startService(intent)
        }
    }

    private fun buildNotification(): android.app.Notification {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val cityName = prefs.getString("flutter.notif_city", "Türkiye") ?: "Türkiye"
        val fajr    = prefs.getString("flutter.notif_fajr", "--:--") ?: "--:--"
        val sunrise = prefs.getString("flutter.notif_sunrise", "--:--") ?: "--:--"
        val dhuhr   = prefs.getString("flutter.notif_dhuhr", "--:--") ?: "--:--"
        val asr     = prefs.getString("flutter.notif_asr", "--:--") ?: "--:--"
        val maghrib = prefs.getString("flutter.notif_maghrib", "--:--") ?: "--:--"
        val isha    = prefs.getString("flutter.notif_isha", "--:--") ?: "--:--"

        val times = listOf(fajr, sunrise, dhuhr, asr, maghrib, isha)
        val names = listOf("İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı")

        val cal = Calendar.getInstance()
        val nowStr = String.format(Locale.US, "%02d:%02d",
            cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE))

        var currentName = "Yatsı"
        var nextName = "İmsak"
        var nextTime = fajr

        for (i in times.indices) {
            if (nowStr < times[i]) {
                nextName = names[i]
                nextTime = times[i]
                val ci = if (i == 0) 5 else i - 1
                currentName = names[ci]
                break
            }
        }

        val title = "$cityName • $currentName Vakti"
        val body = "Sıradaki: $nextName $nextTime    |    $fajr • $sunrise • $dhuhr • $asr • $maghrib • $isha"

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP) }
        val pi = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText("Sıradaki: $nextName $nextTime")
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pi)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Namaz Vakitleri (Arka Plan)",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Uygulama arka planda olsa bile namaz vakitlerini gösterir"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }
}
