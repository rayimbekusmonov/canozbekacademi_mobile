import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';
import 'quiz_screen.dart';

class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Xatolar bilan ishlash",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade400],
            ),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          final failedWords = provider.failedWords;

          if (failedWords.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // 1. TESTNI BOSHLASH TUGMASI
              _buildQuizStarter(context, failedWords),

              // 2. MA'LUMOT BANNERI
              _buildInfoBanner(),

              // 3. XATO SO'ZLAR RO'YXATI
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: failedWords.length,
                  itemBuilder: (context, index) {
                    final word = failedWords[index];

                    return Dismissible(
                      key: Key(word.tr),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        provider.removeFromMistakes(word.tr);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("'${word.tr}' yodlandi va o'chirildi! ✨"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 25),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 32),
                            SizedBox(height: 4),
                            Text("Yodladim",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      child: WordCard(word: word),
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

  Widget _buildQuizStarter(BuildContext context, List<WordModel> words) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          // TUZATILDI: unitNo parametri qo'shildi
          final mistakesUnit = UnitModel(
            unitNo: 0, // <--- Mana bu yerga ixtiyoriy raqam kiritildi
            unitName: "Xatolarim",
            level: "Mustahkamlash",
            words: words,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizScreen(unit: mistakesUnit)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade600]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                "Xatolar ustida testni boshlash",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade100),
          top: BorderSide(color: Colors.orange.shade100),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.swipe_left_rounded, color: Colors.orange.shade800, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "So'zni yodlab bo'lgach, uni chapga surib ro'yxatdan o'chiring.",
              style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.done_all_rounded, size: 80, color: Colors.green.shade400),
          ),
          const SizedBox(height: 24),
          const Text(
            "Hammasi ajoyib!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          const SizedBox(height: 10),
          const Text(
            "Sizda hozircha xatolar mavjud emas.\nBilim olishda davom eting!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Asosiy ekranga qaytish", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}