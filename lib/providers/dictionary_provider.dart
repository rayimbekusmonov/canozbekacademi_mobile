import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/word_model.dart';
import '../core/services/dictionary_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();

  final FlutterTts _flutterTts = FlutterTts();

  WordModel? _dailyWord;
  WordModel? get dailyWord => _dailyWord;

  Map<String, int> _unitScores = {};
  Map<String, int> get unitScores => _unitScores;

  List<String> _failedWordTrs = [];
  List<String> get failedWordTrs => _failedWordTrs;

  double _speechRate = 0.5;
  double get speechRate => _speechRate;

  int get completedUnitsCount => _unitScores.length;

  // --- STATISTIKA ---
  double get averageScore {
    if (_unitScores.isEmpty) return 0.0;
    int total = _unitScores.values.fold(0, (sum, score) => sum + score);
    return total / _unitScores.length;
  }

  double getLevelProgress(String level) {
    final levelUnits = getUnitsByLevel(level);
    if (levelUnits.isEmpty) return 0.0;

    int completedInLevel = 0;
    for (var unit in levelUnits) {
      String key = "${unit.level}_unit${unit.unitNo}";
      if (_unitScores.containsKey(key)) completedInLevel++;
    }
    return completedInLevel / levelUnits.length;
  }

  // --- SOZLAMALAR (TTS) ---
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate); // To'g'rilandi: _flutterTts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speech_rate', rate);
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
    await _flutterTts.setSpeechRate(_speechRate); // To'g'rilandi: _flutterTts
    notifyListeners();
  }

  // --- INIT METODI ---
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allUnits = await _service.loadDictionary();

    // Barcha ma'lumotlarni yuklash
    await loadFavorites();
    await loadScores();
    await loadFailedWords();
    await loadSettings(); // BU QO'SHILDI

    _setDailyWord();

    // TTS boshlang'ich sozlamalari
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(_speechRate);

    _isLoading = false;
    notifyListeners();
  }

  // --- AUDIO ---
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // --- XATOLAR BILAN ISHLASH ---
  Future<void> clearAllFailedWords() async {
    _failedWordTrs.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('failed_words');
    notifyListeners();
  }

  Future<void> loadFailedWords() async {
    final prefs = await SharedPreferences.getInstance();
    _failedWordTrs = prefs.getStringList('failed_words') ?? [];
    notifyListeners();
  }

  Future<void> addFailedWord(String trWord) async {
    if (!_failedWordTrs.contains(trWord)) {
      _failedWordTrs.add(trWord);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('failed_words', _failedWordTrs);
      notifyListeners();
    }
  }

  Future<void> removeFailedWord(String trWord) async {
    if (_failedWordTrs.contains(trWord)) {
      _failedWordTrs.remove(trWord);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('failed_words', _failedWordTrs);
      notifyListeners();
    }
  }

  List<WordModel> get failedWords {
    return allWords.where((word) => _failedWordTrs.contains(word.tr)).toList();
  }

  // --- TEST NATIJALARI ---
  Future<void> saveScore(String unitKey, int score) async {
    if (score > (_unitScores[unitKey] ?? 0)) {
      _unitScores[unitKey] = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('unit_scores', json.encode(_unitScores));
      notifyListeners();
    }
  }

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString('unit_scores');
    if (scoresJson != null) {
      _unitScores = Map<String, int>.from(json.decode(scoresJson));
      notifyListeners();
    }
  }

  // --- LUG'AT MA'LUMOTLARI ---
  List<UnitModel> _allUnits = [];
  bool _isLoading = false;
  List<String> _favoriteWordTrs = [];

  List<UnitModel> get allUnits => _allUnits;
  bool get isLoading => _isLoading;
  List<String> get favoriteWordTrs => _favoriteWordTrs;

  void _setDailyWord() {
    if (allWords.isNotEmpty) {
      final dayOfYear = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;
      final index = dayOfYear % allWords.length;
      _dailyWord = allWords[index];
    }
  }

  // --- FAVORITES ---
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteWordTrs = prefs.getStringList('favorites_list') ?? [];
    notifyListeners();
  }

  bool isFavorite(String trWord) => _favoriteWordTrs.contains(trWord);

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

  // --- QUIZ VA QIDIRUV ---
  List<Map<String, dynamic>> generateQuiz(List<WordModel> unitWords) {
    List<Map<String, dynamic>> quizQuestions = [];
    List<WordModel> shuffledWords = List.from(unitWords)..shuffle();
    int limit = shuffledWords.length > 20 ? 20 : shuffledWords.length;

    for (int i = 0; i < limit; i++) {
      var word = shuffledWords[i];
      String correctAnswer = word.uz;
      List<String> options = [correctAnswer];

      List<WordModel> otherWords = allWords.where((w) => w.uz != correctAnswer).toList();
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

  List<UnitModel> getUnitsByLevel(String level) => _allUnits.where((u) => u.level == level).toList();

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
    // ... mavjud sync mantiqi
  }
}