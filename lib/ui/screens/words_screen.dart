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
      // Orqa fonni biroz yumshoqroq qilamiz
      backgroundColor: Colors.grey.shade100,

      body: CustomScrollView(
        slivers: [
          // Chiroyli kengayuvchi AppBar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
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

          // Yo'riqnoma qismi
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

          // So'zlar ro'yxati
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 80), // FAB tugmasi so'zni to'sib qo'ymasligi uchun
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

      // Quiz tugmasini pastga, ko'rinarli joyga o'tkazamiz
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(unitWords: unit.words),
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