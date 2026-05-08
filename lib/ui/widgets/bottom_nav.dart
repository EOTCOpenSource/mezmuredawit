import 'package:flutter/material.dart';
import '../../models/models.dart';

class BottomNav extends StatelessWidget {
  final DayConfig? selectedDay;
  final int currentChapterNumber;
  final ValueChanged<int> onChapterChanged;
  final VoidCallback onShowSettings;
  final VoidCallback onShowChapterSelector;

  const BottomNav({
    super.key,
    required this.selectedDay,
    required this.currentChapterNumber,
    required this.onChapterChanged,
    required this.onShowSettings,
    required this.onShowChapterSelector,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: currentChapterNumber > selectedDay!.startChapter
                  ? () => onChapterChanged(currentChapterNumber - 1)
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 22),
              onPressed: onShowSettings,
            ),
            Flexible(
              child: InkWell(
                onTap: onShowChapterSelector,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'መዝሙር $currentChapterNumber',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: currentChapterNumber < selectedDay!.endChapter
                  ? () => onChapterChanged(currentChapterNumber + 1)
                  : null,
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
