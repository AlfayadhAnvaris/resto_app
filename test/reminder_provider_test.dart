// test/reminder_provider_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resto_app/providers/reminder_provider.dart';
import 'mocks/mock_notifcation_service.dart';

void main() {
  late ReminderProvider reminderProvider;
  late MockNotificationService mockService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Buat mock service
    mockService = MockNotificationService();
    
    // Inject mock service ke provider
    reminderProvider = ReminderProvider(notificationService: mockService);
  });

  group('ReminderProvider Tests', () {
    test('Initial reminder should be disabled', () async {
      final isEnabled = await reminderProvider.isReminderEnabled;
      expect(isEnabled, false);
    });

    test('Default reminder time should be 19:00 (7 PM)', () {
      expect(reminderProvider.reminderTime.hour, 19);
      expect(reminderProvider.reminderTime.minute, 0);
    });

    test('Formatted time should be correct', () {
      expect(reminderProvider.getFormattedTime(), '19:00');
    });

    test('Time period should be PM for 19:00', () {
      expect(reminderProvider.getTimePeriod(), 'PM');
    });

    test('setReminderTime should update reminder time', () async {
      const newTime = TimeOfDay(hour: 8, minute: 30);
      
      await reminderProvider.setReminderTime(newTime);
      
      expect(reminderProvider.reminderTime.hour, 8);
      expect(reminderProvider.reminderTime.minute, 30);
      expect(reminderProvider.getFormattedTime(), '08:30');
      expect(reminderProvider.getTimePeriod(), 'AM');
    });

    test('toggleReminder should enable/disable reminder', () async {
      // Initial state should be disabled
      expect(await reminderProvider.isReminderEnabled, false);
      
      // Enable reminder
      await reminderProvider.toggleReminder(true);
      expect(await reminderProvider.isReminderEnabled, true);
      
      // Disable reminder
      await reminderProvider.toggleReminder(false);
      expect(await reminderProvider.isReminderEnabled, false);
    });

    test('updateReminder should update both enabled and time', () async {
      const newTime = TimeOfDay(hour: 10, minute: 15);
      
      await reminderProvider.updateReminder(true, newTime);
      
      expect(await reminderProvider.isReminderEnabled, true);
      expect(reminderProvider.reminderTime.hour, 10);
      expect(reminderProvider.reminderTime.minute, 15);
    });
  });
}