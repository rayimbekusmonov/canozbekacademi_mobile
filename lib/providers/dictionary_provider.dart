import 'package:flutter/material.dart';
import '../data/models/word_model.dart';
import '../core/services/dictionary_service.dart';

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();

  List<UnitModel> _allUnits = [];
  bool _isLoading = false;

  List<UnitModel> get allUnits => _allUnits;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allUnits = await _service.loadDictionary();

    _isLoading = false;
    notifyListeners();
  }

  List<UnitModel> getUnitsByLevel(String level) {
    return _allUnits.where((u) => u.level == level).toList();
  }

  List<WordModel> searchWords(String query) {
    List<WordModel> results = [];
    for (var unit in _allUnits) {
      results.addAll(unit.words.where((word) =>
      word.tr.toLowerCase().contains(query.toLowerCase()) ||
          word.uz.toLowerCase().contains(query.toLowerCase())
      ));
    }
    return results;
  }
}