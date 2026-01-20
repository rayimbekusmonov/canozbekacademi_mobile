import 'package:canozbekacademi/ui/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart';
import '../widgets/word_card.dart';

class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Xatolar ustida ishlash"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade800, Colors.red.shade500],
            ),
          ),
        ),
      ),

      floatingActionButton: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          if (provider.failedWords.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              final tempUnit = UnitModel(
                level: "Xatolar",
                unitNo: 0,
                unitName: "Xatolar ustida ishlash",
                words: provider.failedWords, //
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(unit: tempUnit), //
                ),
              );
            },
            label: const Text("Xatolardan test topshirish", style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.play_arrow),
            backgroundColor: Colors.redAccent,
          );
        },
      ),

      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          final failedWords = provider.failedWords; //

          if (failedWords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "Tabriklaymiz! Hozircha xatolar yo'q.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.red.shade50,
                child: Text(
                  "O'chirmoqchi bo'lgan so'zingizni o'ngga yoki chapga suring ↔️",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: failedWords.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final word = failedWords[index];

                    return Dismissible(
                      key: Key(word.tr), // Har bir so'z uchun unikal kalit
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        provider.removeFailedWord(word.tr); //
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${word.tr} ro'yxatdan o'chirildi"),
                            backgroundColor: Colors.red.shade700,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      background: _buildDismissBackground(Alignment.centerLeft),
                      secondaryBackground: _buildDismissBackground(Alignment.centerRight),
                      child: WordCard(word: word), //
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground(Alignment alignment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: alignment,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
    );
  }
}