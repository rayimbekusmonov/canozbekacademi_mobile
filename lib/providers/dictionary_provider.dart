import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/word_model.dart';
import '../core/services/dictionary_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart'; // TTS qo'shildi

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();
  final FlutterTts _flutterTts = FlutterTts(); // TTS obyekti shu yerda bir marta yaratiladi

  List<UnitModel> _allUnits = [];
  bool _isLoading = false;
  List<String> _favoriteWordTrs = []; // Yagona va asosiy ro'yxat

  List<UnitModel> get allUnits => _allUnits;
  bool get isLoading => _isLoading;
  List<String> get favoriteWordTrs => _favoriteWordTrs;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allUnits = await _service.loadDictionary();
    await loadFavorites(); // Favoritlarni yuklash

    // TTS sozlamalari
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.5);

    _isLoading = false;
    notifyListeners();
  }

  // TTS funksiyasi - endi hamma joyda shu ishlatiladi
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  // --- FAVORITES MANTIG'I (TUZATILDI) ---
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteWordTrs = prefs.getStringList('favorites_list') ?? [];
    notifyListeners();
  }

  bool isFavorite(String trWord) {
    return _favoriteWordTrs.contains(trWord);
  }

  Future<void> toggleFavorite(String wordTr) async {
    if (_favoriteWordTrs.contains(wordTr)) {
      _favoriteWordTrs.remove(wordTr);
    } else {
      _favoriteWordTrs.add(wordTr);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites_list', _favoriteWordTrs);
    notifyListeners();
  }

  List<WordModel> get favoriteWords {
    return allWords.where((word) => _favoriteWordTrs.contains(word.tr)).toList();
  }

  // --- QUIZ GENERATOR ---
  List<Map<String, dynamic>> generateQuiz(List<WordModel> unitWords) {
    List<Map<String, dynamic>> quizQuestions = [];
    List<WordModel> shuffledWords = List.from(unitWords)..shuffle();
    int limit = shuffledWords.length > 20 ? 20 : shuffledWords.length;

    for (int i = 0; i < limit; i++) {
      var word = shuffledWords[i];
      String correctAnswer = word.uz;
      List<String> options = [correctAnswer];

      // Noto'g'ri variantlarni takrorlanmasligini ta'minlaymiz
      List<WordModel> otherWords = allWords
          .where((w) => w.uz != correctAnswer)
          .toList();
      otherWords.shuffle();

      for (int j = 0; j < 3 && j < otherWords.length; j++) {
        options.add(otherWords[j].uz);
      }
      options.shuffle();

      quizQuestions.add({
        'question': word.tr,
        'correct': correctAnswer,
        'options': options,
      });
    }
    return quizQuestions;
  }

  // --- QIDIRUV VA FILTR ---
  List<UnitModel> getUnitsByLevel(String level) {
    return _allUnits.where((u) => u.level == level).toList();
  }

  List<WordModel> searchWords(String query) {
    if (query.isEmpty) return [];
    return allWords.where((word) =>
    word.tr.toLowerCase().contains(query.toLowerCase()) ||
        word.uz.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<WordModel> get allWords {
    List<WordModel> words = [];
    for (var unit in _allUnits) {
      words.addAll(unit.words);
    }
    return words;
  }

  // --- FIRESTORE SYNC ---
  Future<void> syncAllDataToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final List<String> fileNames = [
      'A1_unit1.txt', 'A1_unit2.txt', 'A1_unit3.txt', 'A1_unit4.txt',
      'A1_unit5.txt', 'A1_unit6.txt', 'A1_unit7.txt', 'A2_unit1.txt',
      'A2_unit2.txt', 'A2_unit3.txt', 'A2_unit4.txt', 'A2_unit5.txt',
      'A2_unit6.txt', 'A2_unit7.txt', 'B1_unit1.txt', 'B1_unit2.txt',
      'B1_unit3.txt', 'B1_unit4.txt', 'B1_unit5.txt', 'B1_unit6.txt',
      'B1_unit7.txt', 'B2_unit1.txt', 'B2_unit2.txt', 'B2_unit3.txt',
      'B2_unit4.txt', 'B2_unit5.txt', 'B2_unit6.txt', 'B2_unit7.txt',
      'C1_unit1.txt', 'C1_unit2.txt', 'C1_unit3.txt', 'C1_unit4.txt',
      'C1_unit5.txt', 'C1_unit6.txt', 'C1_unit7.txt',
    ];

    for (String fileName in fileNames) {
      try {
        final String response = await rootBundle.loadString('assets/data/$fileName');
        final Map<String, dynamic> data = json.decode(response);

        String level = data['level'] ?? 'A1';
        String unitNo = (data['unit_no'] ?? 0).toString();

        await firestore
            .collection('levels')
            .doc(level)
            .collection('units')
            .doc('unit_$unitNo')
            .set({
          'unit_name': data['unit_name'] ?? '',
          'unit_no': data['unit_no'] ?? 0,
          'level': level,
          'words': data['words'] ?? [],
        });
        debugPrint('✅ $fileName muvaffaqiyatli yuklandi');
      } catch (e) {
        debugPrint('❌ $fileName yuklashda xato: $e');
      }
    }
  }
}