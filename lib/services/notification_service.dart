// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class NotificationServiceBase {
  Future<void> init();
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });
  Future<void> scheduleDailyReminder(TimeOfDay time);
  Future<void> cancelReminder();
  Future<bool> isReminderEnabled();
  Future<TimeOfDay?> getReminderTime();
  Future<void> toggleReminder(bool enabled, {TimeOfDay? time});
  Future<void> showTestNotification();
}

class NotificationService implements NotificationServiceBase {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  static const String _reminderEnabledKey = 'daily_reminder_enabled';
  static const String _reminderTimeKey = 'daily_reminder_time';
  static const int _reminderNotificationId = 1001;

  bool _isInitialized = false;

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<void> init() async {
    if (_isInitialized || !_isMobile) {
      if (!_isMobile) debugPrint('Notifications not supported on this platform');
      return;
    }

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      debugPrint('Timezone set to: Asia/Jakarta');

      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await _requestPermissions();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          debugPrint('Notification tapped: ${response.payload}');
        },
      );

      await _createNotificationChannel();

      _isInitialized = true;
      debugPrint('Notification service initialized successfully');

      await _scheduleExistingReminder();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    if (!_isMobile) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminder',
      description: 'Daily reminder to check restaurants',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    if (!_isMobile) return;

    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isMobile) {
      debugPrint('Notifications not supported on web - would show: $title - $body');
      return;
    }

    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Daily reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _flutterLocalNotificationsPlugin!.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_isMobile) {
      debugPrint('Scheduling not supported on web - would schedule at ${time.hour}:${time.minute}');
      await _saveReminderSettings(true, time);
      return;
    }

    if (!_isInitialized) await init();

    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      debugPrint('Scheduling reminder for: $scheduledDate (timezone: ${tz.local.name})');

      await cancelReminder();

      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        _reminderNotificationId,
        '🍽️ Time to Explore Restaurants!',
        'Discover new restaurants and save your favorites today!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminder',
            channelDescription: 'Daily reminder to check restaurants',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reminder',
      );

      await _saveReminderSettings(true, time);
      debugPrint('Daily reminder scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  @override
  Future<void> cancelReminder() async {
    if (_isMobile && _isInitialized) {
      try {
        await _flutterLocalNotificationsPlugin!.cancel(_reminderNotificationId);
      } catch (e) {
        debugPrint('Error canceling reminder: $e');
      }
    }
    await _saveReminderSettings(false, null);
    debugPrint('Reminder cancelled');
  }

  @override
  Future<bool> isReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reminderEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error checking reminder enabled: $e');
      return false;
    }
  }

  @override
  Future<TimeOfDay?> getReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_reminderTimeKey);

      if (timeString != null && timeString.isNotEmpty) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting reminder time: $e');
    }
    return null;
  }

  Future<void> _saveReminderSettings(bool enabled, TimeOfDay? time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, enabled);

      if (time != null) {
        final timeString = '${time.hour}:${time.minute}';
        await prefs.setString(_reminderTimeKey, timeString);
        debugPrint('Reminder settings saved: enabled=$enabled, time=$timeString');
      } else {
        await prefs.remove(_reminderTimeKey);
        debugPrint('Reminder settings saved: enabled=$enabled, time=null');
      }
    } catch (e) {
      debugPrint('Error saving reminder settings: $e');
    }
  }

  Future<void> _scheduleExistingReminder() async {
    try {
      final enabled = await isReminderEnabled();
      final time = await getReminderTime();

      if (enabled && time != null) {
        debugPrint('Rescheduling existing reminder for ${time.hour}:${time.minute}');
        await scheduleDailyReminder(time);
      }
    } catch (e) {
      debugPrint('Error scheduling existing reminder: $e');
    }
  }

  @override
  Future<void> toggleReminder(bool enabled, {TimeOfDay? time}) async {
    if (enabled && time != null) {
      await scheduleDailyReminder(time);
    } else {
      await cancelReminder();
    }
  }

  @override
  Future<void> showTestNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Restaurant App',
      payload: 'test',
    );
  }
}