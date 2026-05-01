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
}
