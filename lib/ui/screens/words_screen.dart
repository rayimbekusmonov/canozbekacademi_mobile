import 'package:canozbekacademi/ui/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';

class WordsScreen extends StatelessWidget {
  final UnitModel unit;

  const WordsScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${unit.level} - ${unit.unitName}"),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen(unit: unit)),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "So'zning tarjimasini ko'rish uchun ustiga bosing",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: unit.words.length,
              itemBuilder: (context, index) {
                return WordCard(word: unit.words[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}