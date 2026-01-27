import 'package:canozbekacademi/ui/screens/quiz_screen.dart';
import 'package:canozbekacademi/ui/screens/flashcards_screen.dart'; // Importni unutgan bo'lsangiz
import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';

class WordsScreen extends StatelessWidget {
  final UnitModel unit;

  const WordsScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: "Flashcards rejimi",
                icon: const Icon(Icons.style_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardsScreen(
                        words: unit.words,
                        title: unit.unitName,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "${unit.level} - ${unit.unitName}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "So'zlar ro'yxati",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Jami: ${unit.words.length} ta so'z",
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Icon(Icons.touch_app, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100), // FAB-ga joy tashlaymiz
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return WordCard(word: unit.words[index]);
                },
                childCount: unit.words.length,
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(unit: unit),
            ),
          );
        },
        label: const Text("Testni boshlash", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.psychology),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }
}