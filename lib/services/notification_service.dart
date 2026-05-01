import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  static Future<void> scheduleDailyPrayerReminder(TimeOfDay time) async {
    await flutterLocalNotificationsPlugin.cancelAll(); // Clear old ones

    // Request permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Schedule for each day of the week
    await _scheduleForDay(1, time, '1', '30');    // Monday
    await _scheduleForDay(2, time, '31', '60');   // Tuesday
    await _scheduleForDay(3, time, '61', '80');   // Wednesday
    await _scheduleForDay(4, time, '81', '110');  // Thursday
    await _scheduleForDay(5, time, '111', '130'); // Friday
    await _scheduleForDay(6, time, '131', '150'); // Saturday
    await _scheduleForDay(7, time, '1', '30');    // Sunday (Defaults to Mon's part)
  }

  static Future<void> _scheduleForDay(
      int dayOfWeek, TimeOfDay time, String start, String end) async {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
        
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'prayer_reminders',
      'Daily Prayer Reminders',
      channelDescription: 'Notifications for daily prayer readings',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: dayOfWeek,
      title: 'የዕለቱ መዝሙረ ዳዊት',
      body: 'መዝሙረ ዳዊት ከ $start እስከ $end ያንብቡ',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
