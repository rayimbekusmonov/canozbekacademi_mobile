import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/word_model.dart';

class DictionaryService {
  Future<List<UnitModel>> loadDictionary() async {
    final String response = await rootBundle.loadString('assets/data/sample_dictionary.json');
    final List<dynamic> data = json.decode(response);

    return data.map((json) => UnitModel.fromJson(json)).toList();
  }
}