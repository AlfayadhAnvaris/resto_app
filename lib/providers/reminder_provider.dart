// lib/providers/reminder_provider.dart

import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  late final NotificationServiceBase _notificationService;

  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  bool _isLoading = false;
  bool _testNotificationSent = false;

  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  bool get isLoading => _isLoading;
  bool get testNotificationSent => _testNotificationSent;

  ReminderProvider({NotificationServiceBase? notificationService}) {
    _notificationService = notificationService ?? NotificationService();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      _isReminderEnabled = await _notificationService.isReminderEnabled();
      final savedTime = await _notificationService.getReminderTime();
      if (savedTime != null) {
        _reminderTime = savedTime;
      }
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
    }
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isLoading = true;
    notifyListeners();

    _isReminderEnabled = value;
    try {
      await _notificationService.toggleReminder(value ? true : false,
          time: value ? _reminderTime : null);
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _isLoading = true;
    notifyListeners();

    _reminderTime = time;
    try {
      if (_isReminderEnabled) {
        await _notificationService.scheduleDailyReminder(time);
      }
    } catch (e) {
      debugPrint('Error setting reminder time: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateReminder(bool enabled, TimeOfDay time) async {
    _isReminderEnabled = enabled;
    _reminderTime = time;

    try {
      await _notificationService.toggleReminder(enabled, time: time);
    } catch (e) {
      debugPrint('Error updating reminder: $e');
    }

    notifyListeners();
  }

  Future<void> sendTestNotification() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.showTestNotification();
      _testNotificationSent = true;
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetTestNotification() {
    _testNotificationSent = false;
    notifyListeners();
  }

  String getFormattedTime() {
    final hour = _reminderTime.hour.toString().padLeft(2, '0');
    final minute = _reminderTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getTimePeriod() {
    return _reminderTime.period == DayPeriod.am ? 'AM' : 'PM';
  }
}