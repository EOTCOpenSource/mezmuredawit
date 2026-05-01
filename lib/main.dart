import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<double> fontSizeNotifier = ValueNotifier(18.0);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrayerApp());
}

class PrayerApp extends StatelessWidget {
  const PrayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Mezmure Dawit',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: currentMode,
          home: const HomePage(),
        );
      },
    );
  }
}

// --- Data Models (Keep your existing logic) ---
class Verse {
  final int verse;
  final String text;
  Verse({required this.verse, required this.text});
  factory Verse.fromJson(Map<String, dynamic> json) => Verse(verse: json['verse'], text: json['text']);
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

  // --- Main UI ---
  class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  DayConfig? _selectedDay;
  int _currentChapterNumber = 1;
  final ScrollController _scrollController = ScrollController();

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
        final chaptersData = jsonData['chapters'] as List?;
        if (chaptersData != null) {
          _chapters = chaptersData.map((c) => Chapter.fromJson(c)).toList();
        }
        _autoSelectDay();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _autoSelectDay() {
    int weekday = DateTime.now().weekday;
    _selectDay(weekday >= 1 && weekday <= 6 ? days[weekday - 1] : days[0]);
  }

  void _selectDay(DayConfig day) {
    setState(() {
      _selectedDay = day;
      _currentChapterNumber = day.startChapter;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _changeChapter(int newChapter) {
    if (newChapter >= _selectedDay!.startChapter && newChapter <= _selectedDay!.endChapter) {
      setState(() => _currentChapterNumber = newChapter);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Chapter? currentChapter;
    if (_chapters.isNotEmpty) {
      currentChapter = _chapters.firstWhere((c) => c.chapter == _currentChapterNumber, orElse: () => _chapters.first);
    }

    double progress = _selectedDay == null 
        ? 0 
        : (_currentChapterNumber - _selectedDay!.startChapter + 1) / (_selectedDay!.endChapter - _selectedDay!.startChapter + 1);

    return Scaffold(
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  const int sensitivity = 300;
                  if (details.primaryVelocity! < -sensitivity) {
                    // Swiped Left -> Next Chapter
                    if (_selectedDay != null && _currentChapterNumber < _selectedDay!.endChapter) {
                      _changeChapter(_currentChapterNumber + 1);
                    }
                  } else if (details.primaryVelocity! > sensitivity) {
                    // Swiped Right -> Previous Chapter
                    if (_selectedDay != null && _currentChapterNumber > _selectedDay!.startChapter) {
                      _changeChapter(_currentChapterNumber - 1);
                    }
                  }
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                SliverAppBar.large(
                  title: Text(_selectedDay?.name ?? 'መዝሙረ ዳዊት'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.format_size),
                      onPressed: _showSettingsSheet,
                    ),
                    IconButton(
                      icon: const Icon(Icons.grid_view_rounded),
                      onPressed: _showChapterSelector,
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(4),
                    child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.transparent),
                  ),
                ),
                if (currentChapter != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSection(currentChapter!.sections[index]),
                        childCount: currentChapter.sections.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
      drawer: _buildDrawer(),
      bottomSheet: _buildBottomNav(),
    );
  }

  Widget _buildSection(Section section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                section.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ValueListenableBuilder<double>(
          valueListenable: fontSizeNotifier,
          builder: (context, fontSize, _) {
            return Column(
              children: section.verses.map((v) => _buildVerseTile(v, fontSize)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVerseTile(Verse verse, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text('${verse.verse}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              verse.text,
              style: TextStyle(fontSize: fontSize, height: 1.6, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    if (_selectedDay == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            onPressed: _currentChapterNumber > _selectedDay!.startChapter ? () => _changeChapter(_currentChapterNumber - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Chapter $_currentChapterNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton.filledTonal(
            onPressed: _currentChapterNumber < _selectedDay!.endChapter ? () => _changeChapter(_currentChapterNumber + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Adjust Reading Experience", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ValueListenableBuilder<double>(
              valueListenable: fontSizeNotifier,
              builder: (context, val, _) => Slider(
                value: val,
                min: 14, max: 32,
                onChanged: (v) => fontSizeNotifier.value = v,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text("Toggle Dark Mode"),
              onTap: () {
                themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterSelector() {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => GridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
          itemCount: _selectedDay!.endChapter - _selectedDay!.startChapter + 1,
          itemBuilder: (context, index) {
            int ch = _selectedDay!.startChapter + index;
            bool isCurrent = ch == _currentChapterNumber;
            return InkWell(
              onTap: () { _changeChapter(ch); Navigator.pop(context); },
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text('$ch', style: TextStyle(color: isCurrent ? Colors.white : null, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
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
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu_book_rounded, color: Colors.white, size: 42),
                  Spacer(),
                  Text(
                    "መዝሙረ ዳዊት",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Daily Prayer Guide",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: days.map((day) {
                final isSelected = _selectedDay == day;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                    title: Text(
                      day.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    subtitle: Text(
                      'Chapters ${day.startChapter} - ${day.endChapter}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7) : Colors.grey,
                      ),
                    ),
                    selected: isSelected,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () { 
                      _selectDay(day); 
                      Navigator.pop(context); 
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
