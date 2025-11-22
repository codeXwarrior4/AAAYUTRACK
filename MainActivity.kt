package com.example.aayu_track

import android.app.AlarmManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "app.channel/exact_alarms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "canScheduleExactAlarms" -> {
                        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
                        val can =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                alarmManager.canScheduleExactAlarms()
                            } else true

                        result.success(can)
                    }

                    "requestExactAlarmsPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
