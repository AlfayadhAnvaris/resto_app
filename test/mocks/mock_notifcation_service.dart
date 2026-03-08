// test/mocks/mock_notification_service.dart

import 'package:flutter/material.dart';
import 'package:resto_app/services/notification_service.dart';

// Mock class yang mengimplementasikan base class
class MockNotificationService implements NotificationServiceBase {
  bool _mockReminderEnabled = false;
  TimeOfDay? _mockReminderTime;

  @override
  Future<void> init() async {
    // Do nothing in mock
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('Mock notification: $title - $body');
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    _mockReminderEnabled = true;
    _mockReminderTime = time;
  }

  @override
  Future<void> cancelReminder() async {
    _mockReminderEnabled = false;
    _mockReminderTime = null;
  }

  @override
  Future<bool> isReminderEnabled() async {
    return _mockReminderEnabled;
  }

  @override
  Future<TimeOfDay?> getReminderTime() async {
    return _mockReminderTime;
  }

  @override
  Future<void> toggleReminder(bool enabled, {TimeOfDay? time}) async {
    if (enabled && time != null) {
      _mockReminderEnabled = true;
      _mockReminderTime = time;
    } else {
      _mockReminderEnabled = false;
      _mockReminderTime = null;
    }
  }

  @override
  Future<void> showTestNotification() async {
    print('Mock test notification');
  }
}