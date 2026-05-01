import 'package:flutter/material.dart';
import '../../providers/app_state.dart';
import '../../services/notification_service.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Adjust Reading Experience",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 24),
          const Text("Font Size", style: TextStyle(fontWeight: FontWeight.w500)),
          ValueListenableBuilder<double>(
            valueListenable: fontSizeNotifier,
            builder: (context, val, _) => Slider(
              value: val,
              min: 14,
              max: 32,
              onChanged: (v) => fontSizeNotifier.value = v,
            ),
          ),
          const SizedBox(height: 16),
          const Text("Font Style", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: fontFamilyNotifier,
            builder: (context, currentFont, _) {
              return DropdownButtonFormField<String>(
                value: currentFont,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                isExpanded: true,
                items: availableFonts.map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(
                      'መዝሙረ ዳዊት ($font)',
                      style: TextStyle(fontFamily: font, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newFont) {
                  if (newFont != null) {
                    fontFamilyNotifier.value = newFont;
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const Text("Daily Reminder", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.brightness_6),
            title: const Text("Toggle Dark Mode"),
            onTap: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                NotificationService.sendTestNotification();
              },
              icon: const Icon(Icons.bug_report),
              label: const Text("Debug: Test Notification"),
            ),
          ),
        ],
      ),
    );
  }
}
