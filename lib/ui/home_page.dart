import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'widgets/reading_view.dart';
import 'widgets/sidebar.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/settings_sheet.dart';
import 'widgets/chapter_selector.dart';

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
  PageController? _pageController;

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
      setState(() {
        _chapters = chapters;
        _autoSelectDay();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _autoSelectDay() {
    int weekday = DateTime.now().weekday;
    DayConfig day = weekday >= 1 && weekday <= 6 ? days[weekday - 1] : days[0];
    setState(() {
      _selectedDay = day;
      _currentChapterNumber = day.startChapter;
    });
    _pageController = PageController(initialPage: 0);
  }

  void _selectDay(DayConfig day) {
    setState(() {
      _selectedDay = day;
      _currentChapterNumber = day.startChapter;
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
                  icon: const Icon(Icons.format_size),
                  onPressed: _showSettingsSheet,
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
