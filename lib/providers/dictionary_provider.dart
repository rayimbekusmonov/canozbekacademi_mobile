import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/word_model.dart';
import '../core/services/dictionary_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();

  List<UnitModel> _allUnits = [];
  bool _isLoading = false;

  List<UnitModel> get allUnits => _allUnits;
  bool get isLoading => _isLoading;

  late List<String> _favoriteWordTrs = [];
  List<String> get favoriteWordTrs => _favoriteWordTrs;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allUnits = await _service.loadDictionary();

    await loadFavorites();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteWordTrs = prefs.getStringList('favorites_list') ?? [];
    notifyListeners();
  }

  bool isFavorite(String trWord) {
    return _favoriteWordTrs.contains(trWord);
  }

  List<WordModel> get favoriteWords {
    return allWords.where((word) => _favoriteWordTrs.contains(word.tr)).toList();
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

  Future<void> syncAllDataToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final List<String> fileNames = [
      'A1_unit1.txt',
      'A1_unit2.txt',
      'A1_unit3.txt',
      'A1_unit4.txt',
      'A1_unit5.txt',
      'A1_unit6.txt',
      'A1_unit7.txt',
      'A2_unit1.txt',
      'A2_unit2.txt',
      'A2_unit3.txt',
      'A2_unit4.txt',
      'A2_unit5.txt',
      'A2_unit6.txt',
      'A2_unit7.txt',
      'B1_unit1.txt',
      'B1_unit2.txt',
      'B1_unit3.txt',
      'B1_unit4.txt',
      'B1_unit5.txt',
      'B1_unit6.txt',
      'B1_unit7.txt',
      'B2_unit1.txt',
      'B2_unit2.txt',
      'B2_unit3.txt',
      'B2_unit4.txt',
      'B2_unit5.txt',
      'B2_unit6.txt',
      'B2_unit7.txt',
      'C1_unit1.txt',
      'C1_unit2.txt',
      'C1_unit3.txt',
      'C1_unit4.txt',
      'C1_unit5.txt',
      'C1_unit6.txt',
      'C1_unit7.txt',
    ];

    for (String fileName in fileNames) {
      try {
        final String response = await rootBundle.loadString('assets/data/$fileName');
        final Map<String, dynamic> data = json.decode(response);

        String level = data['level']; // A1
        String unitNo = data['unit_no'].toString(); // 1

        await firestore
            .collection('levels')
            .doc(level)
            .collection('units')
            .doc('unit_$unitNo')
            .set({
          'unit_name': data['unit_name'],
          'unit_no': data['unit_no'],
          'level': level,
          'words': data['words'],
        });

        debugPrint('✅ $fileName muvaffaqiyatli yuklandi');
      } catch (e) {
        debugPrint('❌ $fileName yuklashda xato: $e');
        rethrow;
      }
    }
  }

  List<WordModel> get allWords {
    List<WordModel> words = [];
    for (var unit in _allUnits) {
      words.addAll(unit.words);
    }
    return words;
  }

  final List<String> _favoriteWords = []; // So'zlarning 'tr' variantini saqlaymiz

  Future<void> toggleFavorite(String wordTr) async {
    if (_favoriteWords.contains(wordTr)) {
      _favoriteWords.remove(wordTr);
    } else {
      _favoriteWords.add(wordTr);
    }
    // Lokal xotiraga saqlash
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteWords);
    notifyListeners();
  }
}