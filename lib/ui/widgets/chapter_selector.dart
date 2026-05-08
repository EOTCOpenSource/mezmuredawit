import 'package:flutter/material.dart';
import '../../models/models.dart';

class ChapterSelector extends StatelessWidget {
  final DayConfig selectedDay;
  final int currentChapterNumber;
  final ValueChanged<int> onChapterChanged;

  const ChapterSelector({
    super.key,
    required this.selectedDay,
    required this.currentChapterNumber,
    required this.onChapterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      expand: false,
      builder: (_, controller) => GridView.builder(
        controller: controller,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: selectedDay.endChapter - selectedDay.startChapter + 1,
        itemBuilder: (context, index) {
          int ch = selectedDay.startChapter + index;
          bool isCurrent = ch == currentChapterNumber;
          return InkWell(
            onTap: () {
              onChapterChanged(ch);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$ch',
                style: TextStyle(
                  color: isCurrent ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
