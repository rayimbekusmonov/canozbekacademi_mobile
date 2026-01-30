import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/word_model.dart';

// This function will be run in a separate isolate
Future<List<UnitModel>> _loadAndParseDictionary(List<String> levels) async {
  List<UnitModel> allLoadedUnits = [];
  for (String level in levels) {
    for (int i = 1; i <= 7; i++) {
      try {
        String path = 'assets/data/${level}_unit$i.txt';
        String jsonString = await rootBundle.loadString(path);
        Map<String, dynamic> jsonData = jsonDecode(jsonString);
        allLoadedUnits.add(UnitModel.fromJson(jsonData));
      } catch (e) {
        // Silently continue if a file for a unit doesn't exist
        continue;
      }
    }
  }
  return allLoadedUnits;
}

class DictionaryService {
  Future<List<UnitModel>> loadDictionary() async {
    List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    // Use compute to run the parsing in a separate isolate.
    return compute(_loadAndParseDictionary, levels);
  }
}