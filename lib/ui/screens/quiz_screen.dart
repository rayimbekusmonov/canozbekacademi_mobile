import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../../data/models/quiz_model.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final UnitModel unit;
  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  late List<Question> _questions;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    _questions = widget.unit.words.map((word) {
      // To'g'ri javob
      String correct = word.uz;

      // Noto'g'ri variantlarni tanlash
      List<String> others = widget.unit.words
          .where((w) => w.uz != correct)
          .map((w) => w.uz)
          .toList();
      others.shuffle();

      // 3 ta noto'g'ri + 1 ta to'g'ri javobni aralashtirish
      List<String> options = others.take(3).toList();
      options.add(correct);
      options.shuffle();

      return Question(
        questionText: word.tr,
        correctAnswer: correct,
        options: options,
      );
    }).toList();
    _questions.shuffle(); // Savollar ketma-ketligini aralashtirish
  }

  void _checkAnswer(String selected) {
    if (selected == _questions[_currentIndex].correctAnswer) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Natija"),
        content: Text("Siz ${widget.unit.words.length} tadan $_score ta to'g'ri topdingiz."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Tugallash"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text("${widget.unit.unitName} Testi")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length),
            const SizedBox(height: 50),
            Text("Bu so'zning tarjimasi nima?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(question.questionText, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ...question.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () => _checkAnswer(option),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}