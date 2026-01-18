import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import '../widgets/word_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider-dan faqat favorit so'zlarni olamiz
    final favoriteWords = context.watch<DictionaryProvider>().favoriteWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mening lug'atim"),
        centerTitle: true,
      ),
      body: favoriteWords.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Hali so'zlar qo'shilmagan",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favoriteWords.length,
        padding: const EdgeInsets.only(bottom: 20),
        itemBuilder: (context, index) {
          final word = favoriteWords[index];
          return WordCard(word: word);
        },
      ),
    );
  }
}