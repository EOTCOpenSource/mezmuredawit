import 'package:flutter/material.dart';
import '../../providers/app_state.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Adjust Reading Experience",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<double>(
            valueListenable: fontSizeNotifier,
            builder: (context, val, _) => Slider(
              value: val,
              min: 14,
              max: 32,
              onChanged: (v) => fontSizeNotifier.value = v,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text("Toggle Dark Mode"),
            onTap: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
        ],
      ),
    );
  }
}
