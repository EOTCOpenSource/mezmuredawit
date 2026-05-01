import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<double> fontSizeNotifier = ValueNotifier(18.0);
final ValueNotifier<String> fontFamilyNotifier = ValueNotifier('Shiromeda');

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
