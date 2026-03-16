import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // Corrected syntax: method<Type>()
    final AndroidFlutterLocalNotificationsPlugin? android =
    _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.requestNotificationsPermission();
    }

    // Corrected syntax: method<Type>()
    final IOSFlutterLocalNotificationsPlugin? ios =
    _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Saqlangan vaqtni olish
  static Future<Map<String, int>> getSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt('notification_hour') ?? 20,
      'minute': prefs.getInt('notification_minute') ?? 0,
    };
  }

  // Vaqtni saqlash va notificationni qayta rejalashtirish
  static Future<void> setNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);

    // Avvalgisini bekor qilib, yangisini rejalashtirish
    await cancel(0);
    await scheduleDailyNotification();
  }

  static Future<void> scheduleDailyNotification() async {
    try {
      final time = await getSavedTime();

      await _notifications.zonedSchedule(
        0,
        'Canozbek Academy 🔥',
        'Streak olovini o\'chirib qo\'ymang! Bugun yangi so\'zlar yodladingizmi?',
        _nextInstanceOfTime(time['hour']!, time['minute']!),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel_v2',
            'Kunlik Eslatmalar',
            channelDescription: 'Canozbek Academy streak eslatmalari',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Notification xatosi ilovani buzmasin
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}