// pages/reminder_settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  bool _isLoading = false;
  bool _testNotificationSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminder'),
        elevation: 0,
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            'Enable Daily Reminder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Get notified daily to explore restaurants',
                          ),
                          value: reminderProvider.isReminderEnabled,
                          activeColor: Colors.blue,
                          onChanged: (value) async {
                            setState(() => _isLoading = true);
                            await reminderProvider.toggleReminder(value);
                            setState(() => _isLoading = false);
                            _showSnackBar(
                              value
                                  ? 'Daily reminder enabled'
                                  : 'Daily reminder disabled',
                            );
                          },
                        ),
                        const Divider(height: 32),
                        if (reminderProvider.isReminderEnabled) ...[
                          const Text(
                            'Reminder Time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectTime(context, reminderProvider),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    reminderProvider.getFormattedTime(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    reminderProvider.getTimePeriod(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'About Daily Reminder',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('• You will receive a notification at your selected time',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text('• Reminders help you discover new restaurants daily',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text('• You can change the time anytime',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text('• Make sure notification permissions are enabled',
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (reminderProvider.isReminderEnabled)
                  Center(
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _testNotificationSent
                              ? null
                              : () => _sendTestNotification(context),
                          icon: Icon(
                            _testNotificationSent
                                ? Icons.check
                                : Icons.notifications,
                          ),
                          label: Text(
                            _testNotificationSent
                                ? 'Test Notification Sent!'
                                : 'Send Test Notification',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        if (_testNotificationSent)
                          TextButton(
                            onPressed: () {
                              setState(() => _testNotificationSent = false);
                            },
                            child: const Text('Send Again'),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Never Miss a Meal!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set a daily reminder to explore new restaurants\nand save your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, ReminderProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != provider.reminderTime) {
      setState(() => _isLoading = true);
      await provider.setReminderTime(picked);
      setState(() => _isLoading = false);
      if (context.mounted) {
        _showSnackBar('Reminder time updated to ${picked.format(context)}');
      }
    }
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Lewat provider, bukan singleton langsung
      await context.read<ReminderProvider>().sendTestNotification();
      setState(() {
        _testNotificationSent = true;
        _isLoading = false;
      });
      _showSnackBar('Test notification sent! Check your notifications.');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to send test notification', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}