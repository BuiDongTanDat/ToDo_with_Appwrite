import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._();

  Future<void> init() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      final String currentTimezone = await _getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimezone));

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');

      // iOS and macOS initialization settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      // Initialize the plugin
      final bool? initialized =
          await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
        },
      );

      if (initialized != true) {
        throw Exception('Failed to initialize notifications');
      }

      // Request permissions
      await _requestPermissions();

      // Ensure Android notification channel is created
      await _createAndroidNotificationChannel();

      // Log pending notifications for debugging
      await _logPendingNotifications();
    } catch (e) {
      print('NotificationService init error: $e');
    }
  }

  Future<String> _getLocalTimezone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      print('Failed to get local timezone: $e');
      return 'Etc/UTC';
    }
  }

  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_channel', // Channel ID
      'Todo Notifications', // Channel name
      description: 'Notifications for Todo reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    print('Notification channel created: todo_channel');
  }

  Future<void> _requestPermissions() async {
    try {
      // Android permission (API 33+)
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? granted =
            await androidPlugin.requestNotificationsPermission();
        if (granted != true) {
          print('Android notification permission not granted');
        } else {
          print('Android notification permission granted');
        }
        // Request exact alarm permission (Android 12+)
        final bool? exactAlarmGranted =
            await androidPlugin.requestExactAlarmsPermission();
        if (exactAlarmGranted != true) {
          print('Android exact alarm permission not granted');
        } else {
          print('Android exact alarm permission granted');
        }
      }

      // iOS/macOS permission
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final bool? granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted != true) {
          print('iOS notification permission not granted');
        } else {
          print('iOS notification permission granted');
        }
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> _logPendingNotifications() async {
    final pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print(
          'Notification ID: ${notification.id}, Title: ${notification.title}, Scheduled Time: ${notification.payload}');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // Validate inputs
      if (id < 0) {
        print('Invalid notification ID: $id');
        return;
      }
      if (title.isEmpty || body.isEmpty) {
        print('Title or body cannot be empty');
        return;
      }
      if (scheduledDate.isBefore(DateTime.now())) {
        print('Cannot schedule notification for past date: $scheduledDate');
        return;
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      print(
          'Scheduling notification - ID: $id, Title: $title, Body: $body, Time: $tzScheduledDate, Payload: $payload');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'Todo Notifications',
            channelDescription: 'Notifications for Todo reminders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: 'ic_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'todo_thread',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload ?? '',
      );

      print(
          'Successfully scheduled notification: ID=$id, Title=$title, Time=$tzScheduledDate');
      await _logPendingNotifications(); // Log after scheduling
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      if (id < 0) {
        print('Invalid notification ID: $id');
        return;
      }
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('Cancelled notification: ID=$id');
      await _logPendingNotifications(); // Log after cancelling
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('Cancelled all notifications');
      await _logPendingNotifications(); // Log after cancelling
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}