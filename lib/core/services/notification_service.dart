import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // ============ INIT ============
  static Future<void> init() async {
    if (_isInitialized) return;

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

    final result = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    if (result == true) {
      _isInitialized = true;
    }

    await _requestPermissions();
  }

  // ============ UNIVERSAL RUXSAT SO'RASH ============
  static Future<bool> _requestPermissions() async {
    bool granted = false;

    if (Platform.isAndroid) {
      granted = await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      granted = await _requestIOSPermissions();
    }

    return granted;
  }

  static Future<bool> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _notifications.resolvePlatformSpecificImplementation
    <AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return false;

    // Android 13+ (API 33) — POST_NOTIFICATIONS ruxsati kerak
    final bool? notifPermission = await android.requestNotificationsPermission();

    // Android 12+ (API 31) — EXACT_ALARM ruxsati
    // Bu metod Android 11 va pastda avtomatik true qaytaradi
    await android.requestExactAlarmsPermission();

    return notifPermission ?? false;
  }

  static Future<bool> _requestIOSPermissions() async {
    final IOSFlutterLocalNotificationsPlugin? ios =
        _notifications.resolvePlatformSpecificImplementation
    <IOSFlutterLocalNotificationsPlugin>();

    if (ios == null) return false;

    final bool? result = await ios.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return result ?? false;
  }

  // ============ RUXSAT HOLATINI TEKSHIRISH ============
  static Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _notifications.resolvePlatformSpecificImplementation
      <AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        final bool? areEnabled = await android.areNotificationsEnabled();
        return areEnabled ?? false;
      }
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? ios =
          _notifications.resolvePlatformSpecificImplementation
      <IOSFlutterLocalNotificationsPlugin>();

      if (ios != null) {
        // iOS da ruxsat so'raganda natija qaytadi
        return true;
      }
    }

    return false;
  }

  // ============ VAQT BOSHQARUVI ============
  static Future<Map<String, int>> getSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt('notification_hour') ?? 20,
      'minute': prefs.getInt('notification_minute') ?? 0,
    };
  }

  static Future<void> setNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);

    await cancel(0);
    await scheduleDailyNotification();
  }

  // ============ NOTIFICATION YOQILGAN/O'CHIRILGAN ============
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_enabled') ?? true;
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', enabled);

    if (enabled) {
      await scheduleDailyNotification();
    } else {
      await cancelAll();
    }
  }

  // ============ KUNLIK NOTIFICATION REJALASHTIRISH ============
  static Future<void> scheduleDailyNotification() async {
    try {
      // Notification o'chirilgan bo'lsa, hech narsa qilmaymiz
      final isEnabled = await isNotificationEnabled();
      if (!isEnabled) return;

      // Ruxsat borligini tekshiramiz
      final hasPermission = await isPermissionGranted();
      if (!hasPermission) return;

      final time = await getSavedTime();
      final scheduledTime = _nextInstanceOfTime(time['hour']!, time['minute']!);

      // Android versiyasiga qarab schedule mode tanlash
      AndroidScheduleMode scheduleMode;
      if (Platform.isAndroid) {
        // Avval exact alarm ni sinab ko'ramiz, bo'lmasa inexact ishlatamiz
        try {
          final AndroidFlutterLocalNotificationsPlugin? android =
              _notifications.resolvePlatformSpecificImplementation
          <AndroidFlutterLocalNotificationsPlugin>();

          if (android != null) {
            final bool? canScheduleExact =
            await android.canScheduleExactNotifications();
            scheduleMode = (canScheduleExact == true)
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexactAllowWhileIdle;
          } else {
            scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
          }
        } catch (e) {
          scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        }
      } else {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }

      await _notifications.zonedSchedule(
        0,
        'CAN ÖZBEK AKADEMİ 🔥',
        'Streak olovini o\'chirib qo\'ymang! Bugun yangi so\'zlar yodladingizmi?',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel_v4',
            'Kunlik Eslatmalar',
            channelDescription: 'Canozbek Academy streak eslatmalari',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            styleInformation: const BigTextStyleInformation(
              'Streak olovini o\'chirib qo\'ymang! Bugun yangi so\'zlar yodladingizmi?',
              contentTitle: 'Canozbek Academy 🔥',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Notification xatosi ilovani buzmasin
    }
  }

  // ============ VAQT HISOBLASH ============
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ============ TEST NOTIFICATION ============
  static Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        999,
        'Canozbek Academy 🔥',
        'Test bildirishnomasi — notification ishlayapti!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Kanal',
            channelDescription: 'Test uchun',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      // Xato
    }
  }

  // ============ BEKOR QILISH ============
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}