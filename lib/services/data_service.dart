import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class DataService {
  static Future<List<Chapter>> loadPsalms() async {
    final String jsonString = await rootBundle.loadString('assets/psalms.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final chaptersData = jsonData['chapters'] as List?;
    if (chaptersData != null) {
      return chaptersData.map((c) => Chapter.fromJson(c)).toList();
    }
    return [];
  }

  static Future<Map<String, List<DailyQuote>>> loadQuotes() async {
    final String jsonString = await rootBundle.loadString('assets/dayliyquote.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final schedule = jsonData['ethiopian_orthodox_psalter_schedule'] as Map<String, dynamic>;
    
    Map<String, List<DailyQuote>> quotesByDay = {};
    schedule.forEach((day, data) {
       var quotes = data['daily_quotes'] as List;
       quotesByDay[day] = quotes.map((q) => DailyQuote(psalm: q['psalm'], verses: q['verses'])).toList();
    });
    return quotesByDay;
  }
}
