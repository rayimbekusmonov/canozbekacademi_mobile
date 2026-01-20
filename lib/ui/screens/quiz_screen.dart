import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart';

class QuizScreen extends StatefulWidget {
  // List<WordModel> o'rniga butun UnitModel-ni qabul qilamiz
  final UnitModel unit;
  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> questions;
  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool isAnswered = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Unit ichidagi so'zlarni Provider-ga yuboramiz
    questions = Provider.of<DictionaryProvider>(context, listen: false)
        .generateQuiz(widget.unit.words);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void handleAnswer(String option) {
    if (isAnswered) return;

    setState(() {
      selectedOption = option;
      isAnswered = true;
      String correctAnswer = questions[currentIndex]['correct'];
      String questionWord = questions[currentIndex]['question']; // Turkcha so'z

      if (option == correctAnswer) {
        score++;
        // Agar avval xato qilgan bo'lsa va endi to'g'ri topsa, ro'yxatdan o'chirish mumkin (ixtiyoriy)
        // context.read<DictionaryProvider>().removeFailedWord(questionWord);
      } else {
        // Xato qilingan so'zni Providerga yuboramiz
        context.read<DictionaryProvider>().addFailedWord(questionWord);
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (currentIndex < questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentIndex++;
          selectedOption = null;
          isAnswered = false;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Test: ${currentIndex + 1}/${questions.length}"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / questions.length,
            backgroundColor: Colors.blue.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    currentQuestion['question'],
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                ...List.generate(currentQuestion['options'].length, (i) {
                  String option = currentQuestion['options'][i];
                  return _buildOptionButton(option, currentQuestion['correct']);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionButton(String option, String correct) {
    Color cardColor = Colors.white;
    Color textColor = Colors.black87;
    IconData? icon;

    if (isAnswered) {
      if (option == correct) {
        cardColor = Colors.green.shade400;
        textColor = Colors.white;
        icon = Icons.check_circle;
      } else if (option == selectedOption) {
        cardColor = Colors.red.shade400;
        textColor = Colors.white;
        icon = Icons.cancel;
      }
    }

    return GestureDetector(
      onTap: () => handleAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isAnswered && option == correct ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
            if (icon != null) Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showResultDialog() {
    int percent = ((score / questions.length) * 100).toInt();

    // UnitModel-dan level va unitNo ma'lumotlarini to'g'ridan-to'g'ri olamiz
    String unitKey = "${widget.unit.level}_unit${widget.unit.unitNo}";

    context.read<DictionaryProvider>().saveScore(unitKey, percent);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Test Yakunlandi!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "Siz ${questions.length} tadan $score ta to'g'ri topdingiz!",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Tugallash"),
          ),
        ],
      ),
    );
  }
}