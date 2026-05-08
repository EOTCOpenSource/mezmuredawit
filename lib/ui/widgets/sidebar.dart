import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SidebarDrawer extends StatelessWidget {
  final DayConfig? selectedDay;
  final ValueChanged<DayConfig> onDaySelected;
  final String? dailyQuoteText;

  const SidebarDrawer({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.dailyQuoteText,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 42),
                  const SizedBox(height: 16),
                  const Text(
                    "መዝሙረ ዳዊት",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Daily Prayer Guide",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (dailyQuoteText != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ValueListenableBuilder<String>(
                          valueListenable: fontFamilyNotifier,
                          builder: (context, font, _) {
                            return Text(
                              dailyQuoteText!,
                              style: TextStyle(
                                fontFamily: font,
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: days.map((day) {
                final isSelected = selectedDay == day;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    title: Text(
                      day.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      'Chapters ${day.startChapter} - ${day.endChapter}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.7)
                            : Colors.grey,
                      ),
                    ),
                    selected: isSelected,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      onDaySelected(day);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse('https://t.me/EOTCOpenSource');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch Telegram')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/eotc.jpg',
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.church_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "ማኅበረ ነህምያ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Join our Telegram",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.telegram,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
