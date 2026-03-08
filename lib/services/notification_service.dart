// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

// Abstract class untuk testing
abstract class NotificationServiceBase {
  Future<void> init();
  Future<void> showNotification({required String title, required String body, String? payload});
  Future<void> scheduleDailyReminder(TimeOfDay time);
  Future<void> cancelReminder();
  Future<bool> isReminderEnabled();
  Future<TimeOfDay?> getReminderTime();
  Future<void> toggleReminder(bool enabled, {TimeOfDay? time});
  Future<void> showTestNotification();
}

// Real implementation
class NotificationService implements NotificationServiceBase {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static const String _reminderEnabledKey = 'daily_reminder_enabled';
  static const String _reminderTimeKey = 'daily_reminder_time';
  static const int _reminderNotificationId = 1001;

  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.payload != null) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      _isInitialized = true;
      await _scheduleExistingReminder();
    } catch (e) {
      print('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
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
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_isInitialized) await init();

    try {
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      tz.TZDateTime scheduledTZDate;
      if (scheduledDate.isBefore(now)) {
        scheduledTZDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + 1,
          time.hour,
          time.minute,
        );
      } else {
        scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminder',
        channelDescription: 'Daily reminder to check restaurants',
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

      await cancelReminder();

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _reminderNotificationId,
        '🍽️ Time to Explore Restaurants!',
        'Discover new restaurants and save your favorites today!',
        scheduledTZDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reminder',
      );

      await _saveReminderSettings(true, time);
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }

  @override
  Future<void> cancelReminder() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterLocalNotificationsPlugin.cancel(_reminderNotificationId);
      await _saveReminderSettings(false, null);
    } catch (e) {
      print('Error canceling reminder: $e');
    }
  }

  @override
  Future<bool> isReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reminderEnabledKey) ?? false;
    } catch (e) {
      print('Error checking reminder enabled: $e');
      return false;
    }
  }

  @override
  Future<TimeOfDay?> getReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_reminderTimeKey);
      
      if (timeString != null) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } catch (e) {
      print('Error getting reminder time: $e');
    }
    return null;
  }

  Future<void> _saveReminderSettings(bool enabled, TimeOfDay? time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, enabled);
      
      if (time != null) {
        await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');
      } else {
        await prefs.remove(_reminderTimeKey);
      }
    } catch (e) {
      print('Error saving reminder settings: $e');
    }
  }

  Future<void> _scheduleExistingReminder() async {
    try {
      final enabled = await isReminderEnabled();
      final time = await getReminderTime();
      
      if (enabled && time != null) {
        await scheduleDailyReminder(time);
      }
    } catch (e) {
      print('Error scheduling existing reminder: $e');
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
      body: 'This is a test notification',
      payload: 'test',
    );
  }
}