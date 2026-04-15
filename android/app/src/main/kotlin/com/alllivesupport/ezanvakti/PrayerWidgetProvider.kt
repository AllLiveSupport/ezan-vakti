package com.alllivesupport.ezanvakti

import com.alllivesupport.ezanvakti.R

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.Date

class PrayerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                val cityName = widgetData.getString("city_name", "Şehir") ?: "Şehir"
                
                // Get pre-saved times or fallbacks
                val fajr = widgetData.getString("fajr", null)
                val sunrise = widgetData.getString("sunrise", null)
                val dhuhr = widgetData.getString("dhuhr", null)
                val asr = widgetData.getString("asr", null)
                val maghrib = widgetData.getString("maghrib", null)
                val isha = widgetData.getString("isha", null)

                var currentPrayerName = widgetData.getString("current_prayer_name", "--") ?: "--"
                var currentPrayerTime = widgetData.getString("current_prayer_time", "--:--") ?: "--:--"
                var nextPrayerName = widgetData.getString("next_prayer_name", "--") ?: "--"
                var nextPrayerTime = widgetData.getString("next_prayer_time", "--:--") ?: "--:--"

                // Native time comparison
                if (fajr != null && dhuhr != null && isha != null) {
                    val sdf = SimpleDateFormat("HH:mm", Locale.getDefault())
                    val cal = Calendar.getInstance()
                    val nowStr = String.format(Locale.US, "%02d:%02d", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE))
                    
                    val times = listOf(fajr, sunrise!!, dhuhr, asr!!, maghrib!!, isha)
                    val names = listOf("İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı")
                    
                    var found = false
                    for (i in times.indices) {
                        if (nowStr < times[i]) {
                            nextPrayerName = names[i]
                            nextPrayerTime = times[i]
                            val currIndex = if (i == 0) 5 else i - 1
                            currentPrayerName = names[currIndex]
                            currentPrayerTime = times[currIndex]
                            found = true
                            break
                        }
                    }
                    if (!found) {
                        // After Isha, next is tomorrow's Fajr
                        nextPrayerName = "İmsak"
                        nextPrayerTime = fajr
                        currentPrayerName = "Yatsı"
                        currentPrayerTime = isha
                    }
                }

                setTextViewText(R.id.city_name, cityName)
                setTextViewText(R.id.current_prayer_name, currentPrayerName)
                setTextViewText(R.id.current_prayer_time, currentPrayerTime)
                setTextViewText(R.id.next_prayer_name, "Sıradaki: $nextPrayerName")
                setTextViewText(R.id.next_prayer_time, nextPrayerTime)
            }

            // Widget'a tıklanınca uygulamayı aç
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP) }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
