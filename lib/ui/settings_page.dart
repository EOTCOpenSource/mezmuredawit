import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/notification_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, "Notifications"),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Reminder",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Set a time to receive a daily psalm reminder.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: notificationPrefNotifier,
                    builder: (context, currentPref, _) {
                      return DropdownButtonFormField<String>(
                        value: currentPref,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'None', child: Text('None')),
                          DropdownMenuItem(value: 'Morning', child: Text('Morning (6:00 AM)')),
                          DropdownMenuItem(value: 'Evening', child: Text('Evening (6:00 PM)')),
                        ],
                        onChanged: (String? newPref) {
                          if (newPref != null) {
                            notificationPrefNotifier.value = newPref;
                            if (newPref == 'None') {
                              NotificationService.cancelAll();
                            } else if (newPref == 'Morning') {
                              NotificationService.scheduleDailyPrayerReminder(const TimeOfDay(hour: 6, minute: 0));
                            } else if (newPref == 'Evening') {
                              NotificationService.scheduleDailyPrayerReminder(const TimeOfDay(hour: 18, minute: 0));
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Debug Tools"),
          ListTile(
            tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text("Test Notification"),
            subtitle: const Text("Sends an immediate test notification"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              NotificationService.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Test notification sent!")),
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              "መዝሙረ ዳዊት v1.0.0",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
