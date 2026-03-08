// lib/services/notification_service_interface.dart

import 'package:flutter/material.dart';

abstract class NotificationService {
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