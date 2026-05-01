import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PrayerApp());
}

class PrayerApp extends StatelessWidget {
  const PrayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mezmure Dawit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class Verse {
  final int verse;
  final String text;
  Verse({required this.verse, required this.text});
  factory Verse.fromJson(Map<String, dynamic> json) => Verse(
        verse: json['verse'],
        text: json['text'],
      );
}

class Section {
  final String title;
  final List<Verse> verses;
  Section({required this.title, required this.verses});
  factory Section.fromJson(Map<String, dynamic> json) => Section(
        title: json['title'] ?? '',
        verses: (json['verses'] as List?)?.map((v) => Verse.fromJson(v)).toList() ?? [],
      );
}

class Chapter {
  final int chapter;
  final List<Section> sections;
  Chapter({required this.chapter, required this.sections});
  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        chapter: json['chapter'],
        sections: (json['sections'] as List?)?.map((s) => Section.fromJson(s)).toList() ?? [],
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  String _bookNameAm = 'መዝሙረ ዳዊት';

  DayConfig? _selectedDay;
  int _currentChapterNumber = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/psalms.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      setState(() {
        _bookNameAm = jsonData['book_name_am'] ?? 'መዝሙረ ዳዊት';
        final chaptersData = jsonData['chapters'] as List?;
        if (chaptersData != null) {
          _chapters = chaptersData.map((c) => Chapter.fromJson(c)).toList();
        }
        
        // Auto-select day based on current weekday
        _autoSelectDay();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _autoSelectDay() {
    int weekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    if (weekday >= 1 && weekday <= 6) {
      _selectDay(days[weekday - 1]);
    } else {
      // It's Sunday (7), fallback to Monday or just show Monday by default
      _selectDay(days[0]);
    }
  }

  void _selectDay(DayConfig day) {
    setState(() {
      _selectedDay = day;
      _currentChapterNumber = day.startChapter;
    });
  }

  void _changeChapter(int newChapter) {
    if (_selectedDay == null) return;
    if (newChapter >= _selectedDay!.startChapter && newChapter <= _selectedDay!.endChapter) {
      setState(() {
        _currentChapterNumber = newChapter;
      });
    }
  }

  void _showChapterSelector() {
    if (_selectedDay == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Chapter',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedDay!.endChapter - _selectedDay!.startChapter + 1,
                itemBuilder: (context, index) {
                  int chapterNum = _selectedDay!.startChapter + index;
                  return ListTile(
                    title: Text('Chapter $chapterNum'),
                    trailing: _currentChapterNumber == chapterNum
                        ? const Icon(Icons.check, color: Colors.deepPurple)
                        : null,
                    onTap: () {
                      _changeChapter(chapterNum);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Chapter? currentChapter;
    if (_chapters.isNotEmpty) {
      try {
        currentChapter = _chapters.firstWhere((c) => c.chapter == _currentChapterNumber);
      } catch (e) {
        currentChapter = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedDay != null ? '${_selectedDay!.name} - Ch $_currentChapterNumber' : _bookNameAm),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Choose Chapter',
            onPressed: _showChapterSelector,
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              accountName: Text(
                _bookNameAm,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                'Daily Prayer App',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.book, color: Colors.white),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Day',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isSelected = _selectedDay == day;
                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(day.name),
                    subtitle: Text('Chapters ${day.startChapter} - ${day.endChapter}'),
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    onTap: () {
                      _selectDay(day);
                      Navigator.pop(context); // close drawer
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentChapter == null
              ? const Center(child: Text('Chapter not found.'))
              : _buildChapterView(currentChapter),
      bottomNavigationBar: _selectedDay == null
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentChapterNumber > _selectedDay!.startChapter
                          ? () => _changeChapter(_currentChapterNumber - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('Prev'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    Text(
                      '${_currentChapterNumber} / ${_selectedDay!.endChapter}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentChapterNumber < _selectedDay!.endChapter
                          ? () => _changeChapter(_currentChapterNumber + 1)
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChapterView(Chapter chapter) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: chapter.sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = chapter.sections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    section.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ...section.verses.map((verse) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            height: 1.5,
                          ),
                      children: [
                        TextSpan(
                          text: '${verse.verse}. ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(text: verse.text),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
