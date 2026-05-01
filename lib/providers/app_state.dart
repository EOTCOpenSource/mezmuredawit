import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<double> fontSizeNotifier = ValueNotifier(18.0);
final ValueNotifier<String> fontFamilyNotifier = ValueNotifier('Shiromeda');
final ValueNotifier<String> notificationPrefNotifier = ValueNotifier('None');

const List<String> availableFonts = [
  'Addis Abeba',
  'Abba Garima',
  'Bela Hidase',
  'Ethiopic Sadiss',
  'Geez Handwriting',
  'Nokia Pureheadline',
  'Selam',
  'Shiromeda',
  'Kiros',
];

Future<void> initAppState() async {
  final prefs = await SharedPreferences.getInstance();

  // Load preferences
  final int? themeIndex = prefs.getInt('themeMode');
  if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
    themeNotifier.value = ThemeMode.values[themeIndex];
  }

  final double? fontSize = prefs.getDouble('fontSize');
  if (fontSize != null) {
    fontSizeNotifier.value = fontSize;
  }

  final String? fontFamily = prefs.getString('fontFamily');
  if (fontFamily != null && availableFonts.contains(fontFamily)) {
    fontFamilyNotifier.value = fontFamily;
  }

  final String? notificationPref = prefs.getString('notificationPref');
  if (notificationPref != null) {
    notificationPrefNotifier.value = notificationPref;
  }

  // Save preferences when they change
  themeNotifier.addListener(() {
    prefs.setInt('themeMode', themeNotifier.value.index);
  });
  
  fontSizeNotifier.addListener(() {
    prefs.setDouble('fontSize', fontSizeNotifier.value);
  });
  
  fontFamilyNotifier.addListener(() {
    prefs.setString('fontFamily', fontFamilyNotifier.value);
  });
  
  notificationPrefNotifier.addListener(() {
    prefs.setString('notificationPref', notificationPrefNotifier.value);
  });
}
