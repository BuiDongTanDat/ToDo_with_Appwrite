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
          AndroidInitializationSettings('@mipmap/ic_launcher');

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
        // Optionally handle notification taps
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap (e.g., navigate to todo details)
          print('Notification tapped: ${response.payload}');
        },
      );

      if (initialized != true) {
        throw Exception('Failed to initialize notifications');
      }

      // Request permissions
      await _requestPermissions();
    } catch (e) {
      print('NotificationService init error: $e');
      // Optionally, rethrow or notify the app of initialization failure
      // rethrow;
    }
  }

  Future<String> _getLocalTimezone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      print('Failed to get local timezone: $e');
      // Fallback to a default timezone (e.g., device's system timezone or a common one)
      return 'Etc/UTC';
    }
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
          // Optionally, prompt user to enable permissions in settings
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
          // Optionally, prompt user to enable permissions in settings
        }
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
    String? payload,
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
            // Optional: Add actions
            // actions: [
            //   AndroidNotificationAction('mark_done', 'Mark as Done'),
            // ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // Optional: Custom sound
            // sound: 'notification_sound.mp3',
            threadIdentifier: 'todo_thread',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print(
          'Scheduled notification: ID=$id, Title=$title, Time=$scheduledDate');
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

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('Cancelled all notifications');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}
