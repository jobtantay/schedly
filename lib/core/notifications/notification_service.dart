import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> scheduleReminderNotification({
    required int id,
    required String tripTitle,
    required DateTime tripStartDate,
    required int daysBefore,
  }) async {
    final reminderDate =
        tripStartDate.subtract(Duration(days: daysBefore));

    // Don't schedule if reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      '✈️ Trip Reminder',
      '$tripTitle starts in $daysBefore day${daysBefore == 1 ? '' : 's'}!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedly_reminders',
          'Trip Reminders',
          channelDescription: 'Reminders for upcoming trips',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}