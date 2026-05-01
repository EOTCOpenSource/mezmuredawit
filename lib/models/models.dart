class Verse {
  final int verse;
  final String text;
  Verse({required this.verse, required this.text});
  factory Verse.fromJson(Map<String, dynamic> json) =>
      Verse(verse: json['verse'], text: json['text']);
}

class Section {
  final String title;
  final List<Verse> verses;
  Section({required this.title, required this.verses});
  factory Section.fromJson(Map<String, dynamic> json) => Section(
    title: json['title'] ?? '',
    verses:
        (json['verses'] as List?)?.map((v) => Verse.fromJson(v)).toList() ?? [],
  );
}

class Chapter {
  final int chapter;
  final List<Section> sections;
  Chapter({required this.chapter, required this.sections});
  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    chapter: json['chapter'],
    sections:
        (json['sections'] as List?)?.map((s) => Section.fromJson(s)).toList() ??
        [],
  );
}

class DayConfig {
  final String name;
  final int startChapter;
  final int endChapter;
  DayConfig(this.name, this.startChapter, this.endChapter);
}

final List<DayConfig> days = [
  DayConfig('Monday (ሰኞ)', 1, 30),
  DayConfig('Tuesday (ማክሰኞ)', 31, 60),
  DayConfig('Wednesday (ረቡዕ)', 61, 80),
  DayConfig('Thursday (ሐሙስ)', 81, 110),
  DayConfig('Friday (አርብ)', 111, 130),
  DayConfig('Saturday (ቅዳሜ)', 131, 150),
];

class DailyQuote {
  final int psalm;
  final String verses;

  DailyQuote({required this.psalm, required this.verses});
}
