import 'package:canozbekacademi/ui/screens/quiz_screen.dart';
import 'package:canozbekacademi/ui/screens/flashcards_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';

class WordsScreen extends StatelessWidget {
  final UnitModel unit;

  const WordsScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: "Flashcards rejimi",
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.style_rounded, color: Colors.white, size: 20),
                  ),
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
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                unit.unitName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.blueGrey.shade900, Colors.black]
                        : [const Color(0xFF0D47A1), const Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Info banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${unit.words.length} ta so'z · Kartochkani bosib tarjimasini ko'ring",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // So'zlar
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 90),
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

      // Test tugmasi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(unit: unit),
            ),
          );
        },
        label: const Text("Testni boshlash",
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.psychology_rounded),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}