import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      // Set the local timezone instead of UTC
      tz.setLocalLocation(tz.getLocation(tz.local.name));

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure icon exists in res/mipmap

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Request permissions
      await _requestPermissions();
    } catch (e) {
      print('NotificationService init error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Android 13+ permission
      if (await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ==
          false) {
        print('Android notification permission denied');
      }

      // iOS permission
      if (await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ==
          false) {
        print('iOS notification permission denied');
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Ensure scheduledDate is in the future
      if (scheduledDate.isBefore(DateTime.now())) {
        print('Cannot schedule notification for past date: $scheduledDate');
        return;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'Todo Notifications',
            channelDescription: 'Notifications for Todo reminders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Scheduled notification: ID=$id, Title=$title, Time=$scheduledDate');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('Cancelled notification: ID=$id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }
}