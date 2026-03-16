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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String _selectedOption = "";
  late List<WordModel> _currentWords;
  List<String> _options = [];
  List<WordModel> _wrongWords = [];

  late AnimationController _questionController;
  late Animation<Offset> _questionSlide;
  late Animation<double> _questionFade;

  @override
  void initState() {
    super.initState();

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _questionSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _questionController, curve: Curves.easeOut));
    _questionFade = Tween<double>(begin: 0.0, end: 1.0).animate(_questionController);

    _startNewQuiz();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _startNewQuiz() {
    List<WordModel> shuffled = List.from(widget.unit.words)..shuffle();
    _currentWords = shuffled.take(20).toList();
    _wrongWords = [];
    _generateOptions();
  }

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

    int needed = 3.clamp(0, allWords.length);
    options.addAll(allWords.take(needed).map((w) => w.uz));
    options.shuffle();

    setState(() {
      _options = options;
      _isAnswered = false;
      _selectedOption = "";
    });

    _questionController.reset();
    _questionController.forward();
  }

  void _checkAnswer(String option) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedOption = option;
      if (option == _currentWords[_currentIndex].uz) {
        _score++;
      } else {
        _wrongWords.add(_currentWords[_currentIndex]);
        context.read<DictionaryProvider>().addToMistakes(_currentWords[_currentIndex].tr);
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
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
    Color mainColor = percent >= 70
        ? const Color(0xFF4CAF50)
        : (percent >= 40 ? const Color(0xFFFF9800) : const Color(0xFFEF5350));

    String emoji = percent >= 90
        ? "🏆"
        : percent >= 70
        ? "🎉"
        : percent >= 40
        ? "💪"
        : "📖";

    String message = percent >= 90
        ? "Ajoyib natija!"
        : percent >= 70
        ? "Yaxshi ish!"
        : percent >= 40
        ? "Yomon emas, davom eting!"
        : "Ko'proq mashq qiling!";

    final provider = context.read<DictionaryProvider>();
    String unitKey = "${widget.unit.level}_unit${widget.unit.unitNo}";
    provider.saveScore(unitKey, _score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji va foiz
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "$percent%",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: mainColor,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$_score / ${_currentWords.length} to'g'ri",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                ),

                // Xato so'zlar
                if (_wrongWords.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.close_rounded, size: 16, color: Colors.red.shade300),
                      const SizedBox(width: 6),
                      Text(
                        "Xato qilingan so'zlar (${_wrongWords.length})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _wrongWords.length,
                      itemBuilder: (context, index) {
                        final word = _wrongWords[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(isDark ? 0.1 : 0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  word.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 14,
                                  color: isDark ? Colors.white24 : Colors.grey.shade300),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  word.uz,
                                  style: TextStyle(color: Colors.blue.shade400, fontSize: 14),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                if (_wrongWords.isEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "🎯 Mukammal natija!",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Chiqish"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _resetQuiz();
                        },
                        child: const Text("Qayta urinish",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWords[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_currentIndex + 1) / _currentWords.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.unit.unitName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFF0D47A1), const Color(0xFF1E88E5)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  "${_currentIndex + 1}/${_currentWords.length}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark ? Colors.white12 : Colors.blue.shade50,
                      valueColor: AlwaysStoppedAnimation(
                        progress < 0.5
                            ? Colors.blue
                            : progress < 0.8
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "$_score",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Savol qismi
          Expanded(
            child: SlideTransition(
              position: _questionSlide,
              child: FadeTransition(
                opacity: _questionFade,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "TARJIMASINI TOPING",
                        style: TextStyle(
                          color: isDark ? Colors.blue.shade200 : Colors.blue.shade300,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // So'z kartochkasi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1A237E), const Color(0xFF283593)]
                                : [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              currentWord.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (currentWord.example != null && currentWord.example!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                currentWord.example!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Variantlar
                      ..._options.asMap().entries.map((entry) =>
                          _buildOption(entry.value, entry.key)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option, int index) {
    bool isCorrect = option == _currentWords[_currentIndex].uz;
    bool isSelected = option == _selectedOption;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> labels = ['A', 'B', 'C', 'D'];

    Color bgColor;
    Color borderColor;
    Color labelBg;

    if (_isAnswered && isCorrect) {
      bgColor = Colors.green.withOpacity(isDark ? 0.15 : 0.08);
      borderColor = Colors.green;
      labelBg = Colors.green;
    } else if (_isAnswered && isSelected && !isCorrect) {
      bgColor = Colors.red.withOpacity(isDark ? 0.15 : 0.08);
      borderColor = Colors.red;
      labelBg = Colors.red;
    } else {
      bgColor = Theme.of(context).cardColor;
      borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
      labelBg = isDark ? Colors.white12 : Colors.grey.shade100;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // A, B, C, D label
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _isAnswered && (isCorrect || (isSelected && !isCorrect))
                    ? labelBg
                    : labelBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  index < labels.length ? labels[index] : "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isAnswered && (isCorrect || (isSelected && !isCorrect))
                        ? Colors.white
                        : (isDark ? Colors.white54 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (_isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
            if (_isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: Colors.red, size: 22),
          ],
        ),
      ),
    );
  }
}