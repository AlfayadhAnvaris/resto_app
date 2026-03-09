// test/notification_service_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mocks/mock_notifcation_service.dart';

void main() {
  late MockNotificationService notificationService;

  setUp(() {
    notificationService = MockNotificationService();
  });

  group('NotificationService Tests', () {
    test('Initial reminder should be disabled', () async {
      final isEnabled = await notificationService.isReminderEnabled();
      expect(isEnabled, false);
    });

    test('Reminder time should be null initially', () async {
      final time = await notificationService.getReminderTime();
      expect(time, isNull);
    });

    test('toggleReminder should save settings', () async {
      const testTime = TimeOfDay(hour: 20, minute: 30);

      await notificationService.toggleReminder(true, time: testTime);

      final isEnabled = await notificationService.isReminderEnabled();
      final savedTime = await notificationService.getReminderTime();

      expect(isEnabled, true);
      expect(savedTime?.hour, 20);
      expect(savedTime?.minute, 30);
    });

    test('cancelReminder should disable reminder', () async {
      // Enable first
      await notificationService.toggleReminder(
        true,
        time: const TimeOfDay(hour: 8, minute: 0),
      );

      // Then cancel
      await notificationService.cancelReminder();

      final isEnabled = await notificationService.isReminderEnabled();
      expect(isEnabled, false);
    });
  });
}