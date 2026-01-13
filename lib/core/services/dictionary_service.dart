import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/word_model.dart';

class DictionaryService {
  Future<List<UnitModel>> loadDictionary() async {
    List<UnitModel> allLoadedUnits = [];
    List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1'];

    for (String level in levels) {
      for (int i = 1; i <= 7; i++) {
        try {
          String path = 'assets/data/${level}_unit$i.txt';
          String jsonString = await rootBundle.loadString(path);
          Map<String, dynamic> jsonData = jsonDecode(jsonString);

          allLoadedUnits.add(UnitModel.fromJson(jsonData));
        } catch (e) {
          print("Fayl yuklanmadi: ${level}_unit$i.txt");
        }
      }
    }
    return allLoadedUnits;
  }
}