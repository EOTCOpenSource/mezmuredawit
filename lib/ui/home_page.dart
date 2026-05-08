import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'widgets/reading_view.dart';
import 'widgets/sidebar.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/settings_sheet.dart';
import 'widgets/chapter_selector.dart';
import 'info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chapter> _chapters = [];
  Map<String, List<DailyQuote>> _quotes = {};
  bool _isLoading = true;
  DayConfig? _selectedDay;
  int _currentChapterNumber = 1;
  PageController? _pageController;
  String? _dailyQuoteText;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final chapters = await DataService.loadPsalms();
      final quotes = await DataService.loadQuotes();
      setState(() {
        _chapters = chapters;
        _quotes = quotes;
        _autoSelectDay();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateDailyQuote() {
    if (_selectedDay == null || _quotes.isEmpty) return;
    
    String key = _selectedDay!.name.split(' ')[0].toLowerCase();
    
    List<DailyQuote>? dayQuotes = _quotes[key];
    if (dayQuotes != null && dayQuotes.isNotEmpty) {
      // Create simple hash of datetime so it doesn't change every millisecond
      final randomQuote = dayQuotes[DateTime.now().second % dayQuotes.length];
      
      Chapter? chapter;
      try {
        chapter = _chapters.firstWhere((c) => c.chapter == randomQuote.psalm);
      } catch (_) {
        return;
      }
      
      String verseText = "";
      List<String> range = randomQuote.verses.split('-');
      int start = int.tryParse(range[0]) ?? 1;
      int end = range.length > 1 ? (int.tryParse(range[1]) ?? start) : start;
      
      for (var section in chapter.sections) {
        for (var v in section.verses) {
          if (v.verse >= start && v.verse <= end) {
            verseText += "${v.text} ";
          }
        }
      }
      
      _dailyQuoteText = "${verseText.trim()}\n\n— መዝሙር ${randomQuote.psalm}:${randomQuote.verses}";
    }
  }

  void _autoSelectDay() {
    int weekday = DateTime.now().weekday;
    DayConfig day = weekday >= 1 && weekday <= 6 ? days[weekday - 1] : days[0];
    setState(() {
      _selectedDay = day;
      _currentChapterNumber = day.startChapter;
      _updateDailyQuote();
    });
    _pageController = PageController(initialPage: 0);
  }

  void _selectDay(DayConfig day) {
    setState(() {
      _selectedDay = day;
      _currentChapterNumber = day.startChapter;
      _updateDailyQuote();
    });
    _pageController?.jumpToPage(0);
  }

  void _changeChapter(int newChapter) {
    if (_selectedDay == null) return;
    if (newChapter >= _selectedDay!.startChapter &&
        newChapter <= _selectedDay!.endChapter) {
      int newPage = newChapter - _selectedDay!.startChapter;
      if (_pageController != null && _pageController!.hasClients) {
        _pageController!.animateToPage(
          newPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _currentChapterNumber = newChapter);
      }
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SettingsSheet(),
    );
  }

  void _showChapterSelector() {
    if (_selectedDay == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChapterSelector(
        selectedDay: _selectedDay!,
        currentChapterNumber: _currentChapterNumber,
        onChapterChanged: _changeChapter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _selectedDay == null
        ? 0
        : (_currentChapterNumber - _selectedDay!.startChapter + 1) /
            (_selectedDay!.endChapter - _selectedDay!.startChapter + 1);

    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Text('መዝሙረ ዳዊት $_currentChapterNumber'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoPage()),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentChapterNumber = _selectedDay!.startChapter + index;
                });
              },
              itemCount: _selectedDay!.endChapter - _selectedDay!.startChapter + 1,
              itemBuilder: (context, index) {
                int chapterNum = _selectedDay!.startChapter + index;
                Chapter? chapter;
                if (_chapters.isNotEmpty) {
                  chapter = _chapters.firstWhere(
                    (c) => c.chapter == chapterNum,
                    orElse: () => _chapters.first,
                  );
                }

                if (chapter == null) return const SizedBox.shrink();

                return ReadingView(chapter: chapter);
              },
            ),
      drawer: SidebarDrawer(
        selectedDay: _selectedDay,
        onDaySelected: _selectDay,
        dailyQuoteText: _dailyQuoteText,
      ),
      bottomSheet: BottomNav(
        selectedDay: _selectedDay,
        currentChapterNumber: _currentChapterNumber,
        onChapterChanged: _changeChapter,
        onShowSettings: _showSettingsSheet,
        onShowChapterSelector: _showChapterSelector,
      ),
    );
  }
}
