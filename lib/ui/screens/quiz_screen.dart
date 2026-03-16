import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart';

class QuizScreen extends StatefulWidget {
  final UnitModel unit;
  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String _selectedOption = "";
  late List<WordModel> _currentWords;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _startNewQuiz();
  }

  void _startNewQuiz() {
    List<WordModel> shuffled = List.from(widget.unit.words)..shuffle();
    _currentWords = shuffled.take(20).toList();
    _generateOptions();
  }

  // TESTNI QAYTA BOSHLASH METODI (Error bergan qism)
  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _startNewQuiz();
    });
  }

  void _generateOptions() {
    final correctWord = _currentWords[_currentIndex];
    List<String> options = [correctWord.uz];

    final provider = context.read<DictionaryProvider>();
    List<WordModel> allWords = provider.allWords
        .where((w) => w.uz != correctWord.uz)
        .toList()
      ..shuffle();

    int needed = 3.clamp(0, allWords.length); // Agar 3 tadan kam bo'lsa
    options.addAll(allWords.take(needed).map((w) => w.uz));
    options.shuffle();

    setState(() {
      _options = options;
      _isAnswered = false;
      _selectedOption = "";
    });
  }

  void _checkAnswer(String option) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedOption = option;
      if (option == _currentWords[_currentIndex].uz) {
        _score++;
      } else {
        // PROVAYDERDAGI YANGI METODNI CHAQIRISH
        context.read<DictionaryProvider>().addToMistakes(_currentWords[_currentIndex].tr);
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentIndex < _currentWords.length - 1) {
        setState(() {
          _currentIndex++;
          _generateOptions();
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    final int percent = ((_score / _currentWords.length) * 100).toInt();
    Color mainColor = percent >= 70 ? Colors.green : (percent >= 40 ? Colors.orange : Colors.red);

    // --- STATISTIKANI SAQLASH QISMI (SHU YERDA MO'JIZA YUZ BERADI) ---
    final provider = context.read<DictionaryProvider>();
    // Kalit so'zni shakllantiramiz (masalan: "A1_unit1")
    String unitKey = "${widget.unit.level}_unit${widget.unit.unitNo}";
    // Providerdagi saveScore metodini chaqiramiz
    provider.saveScore(unitKey, _score);
    // --------------------------------------------------------------

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(percent >= 70 ? Icons.emoji_events : Icons.psychology,
                  size: 80, color: mainColor),
              const SizedBox(height: 20),
              Text("$percent%",
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: mainColor)),
              Text("$_score / ${_currentWords.length} to'g'ri",
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialogni yopish
                        Navigator.pop(context); // QuizScreen-dan chiqish
                      },
                      child: const Text("Chiqish"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                      onPressed: () {
                        Navigator.pop(context); // Dialogni yopish
                        _resetQuiz(); // Testni qayta boshlash
                      },
                      child: const Text("Qayta urinish", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWords[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(widget.unit.unitName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _currentWords.length,
            backgroundColor: Colors.blue.shade50,
            color: Colors.orange,
            minHeight: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("TARJIMASINI TOPING", style: TextStyle(color: Colors.blue.shade300, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 15),
                  Text(currentWord.tr, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ..._options.map((option) => _buildOption(option)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    bool isCorrect = option == _currentWords[_currentIndex].uz;
    bool isSelected = option == _selectedOption;
    Color borderColor = _isAnswered ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey.shade200)) : Colors.grey.shade200;

    return GestureDetector(
      onTap: () => _checkAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _isAnswered && isCorrect ? Colors.green.shade50 : (_isAnswered && isSelected ? Colors.red.shade50 : Colors.white),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (_isAnswered && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
            if (_isAnswered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}