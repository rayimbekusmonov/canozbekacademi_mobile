import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/word_model.dart';
import '../core/services/dictionary_service.dart';
import 'dart:convert';
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

  int _streakCount = 0;
  int get streakCount => _streakCount;

  Future<void> checkAndUpdateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisit = prefs.getString('last_visit_date');
    final savedStreak = prefs.getInt('streak_count') ?? 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastVisit != null) {
      final lastDate = DateTime.parse(lastVisit);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        // Kecha kirgan edi, streak davom etadi
        _streakCount = savedStreak + 1;
      } else if (difference == 0) {
        // Bugun allaqachon kirgan
        _streakCount = savedStreak;
      } else {
        // Uzilish bo'lgan (1 kundan ko'p), streak 1 dan boshlanadi
        _streakCount = 1;
      }
    } else {
      // Ilovaga birinchi marta kirishi
      _streakCount = 1;
    }

    // Ma'lumotlarni saqlaymiz
    await prefs.setString('last_visit_date', today.toIso8601String());
    await prefs.setInt('streak_count', _streakCount);

    // UI-ga o'zgarishni bildiramiz
    notifyListeners();
  }

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
      // UNIT KEY SHAKLLANTIRISH (QuizScreen bilan bir xil bo'lishi shart)
      String key = "${unit.level}_unit${unit.unitNo}";

      if (_unitScores.containsKey(key)) {
        completedInLevel++;
      }
    }

    double progress = completedInLevel / levelUnits.length;
    return progress;
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

    try {
      _allUnits = await _service.loadDictionary();
      await loadFavorites();
      await loadScores();
      await loadFailedWords();
      await loadSettings();
      _setDailyWord();

      // TTS boshlang'ich sozlamalari
      await _flutterTts.setLanguage("tr-TR");
      await _flutterTts.setSpeechRate(_speechRate);
    } catch (e) {
      print("Init xatosi: $e");
      // Ilova crash bo'lmasin, bo'sh holatda davom etsin
      _allUnits = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- AUDIO ---
  Future<void> speak(String text) async {
    try {
      if (text.isNotEmpty) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print("TTS xatosi: $e");
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

  List<WordModel> get failedWords {
    return allWords.where((word) => _failedWordTrs.contains(word.tr)).toList();
  }

  // --- TEST NATIJALARI ---
  Future<void> saveScore(String unitKey, int score) async {
    try {
      if (score > (_unitScores[unitKey] ?? 0)) {
        _unitScores[unitKey] = score;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('unit_scores', json.encode(_unitScores));
        notifyListeners();
      }
    } catch (e) {
      print("Score saqlashda xato: $e");
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

  void removeFromMistakes(String wordTr) {
    // Ro'yxatdan o'chiramiz
    _failedWordTrs.remove(wordTr);

    // Mahalliylashtirilgan xotirada (SharedPreferences) ham saqlab qo'yamiz
    _saveMistakes();

    // UI-ga "xato o'chirildi, qayta chiz!" deb xabar beramiz
    notifyListeners();
  }

  Future<void> _saveMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('failed_words', _failedWordTrs.toList());
  }


// Xatolar ro'yxatiga qo'shish (Quiz paytida xato qilinsa chaqiriladi)
  void addToMistakes(String wordTr) {
    if (!_failedWordTrs.contains(wordTr)) {
      _failedWordTrs.add(wordTr);
      _saveMistakes(); // SharedPreferences-ga saqlash
      notifyListeners();
    }
  }
}