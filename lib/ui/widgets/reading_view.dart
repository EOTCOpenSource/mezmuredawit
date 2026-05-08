import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class ReadingView extends StatelessWidget {
  final Chapter chapter;

  const ReadingView({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          ...chapter.sections.asMap().entries.map(
                (entry) => _buildSection(context, entry.value, entry.key),
              ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, Section section, int sectionIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sectionIndex == 0) ...[
            Center(
              child: Text(
                'ምዕራፍ ${chapter.chapter}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (section.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  section.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ValueListenableBuilder<String>(
            valueListenable: fontFamilyNotifier,
            builder: (context, fontFamily, _) {
              return ValueListenableBuilder<double>(
                valueListenable: fontSizeNotifier,
                builder: (context, fontSize, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: section.verses.asMap().entries.map((entry) {
                      return _buildVerseTile(
                          context, entry.value, fontSize, fontFamily, sectionIndex == 0 && entry.key == 0);
                    }).toList(),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVerseTile(
      BuildContext context, Verse verse, double fontSize, String fontFamily, bool isFirstVerse) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    Widget verseContent = RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: 1.6,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(
            text: '${verse.verse} ',
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: fontSize * 0.8,
            ),
          ),
          TextSpan(text: verse.text),
          TextSpan(
            text: ' ※',
            style: TextStyle(
              fontFamily: fontFamily,
              color: primaryColor,
              fontSize: fontSize * 0.8,
            ),
          ),
        ],
      ),
    );

    if (isFirstVerse) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${chapter.chapter}',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize * 3.2,
                height: 1.1,
                fontWeight: FontWeight.w400,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: verseContent,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: verseContent,
    );
  }
}
