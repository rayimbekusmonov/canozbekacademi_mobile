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
      // lib/ui/screens/favorites_screen.dart ichidagi body qismi:

      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoriteWords;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 100,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sevimli so'zlar hali yo'q",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "So'zlarni favoritga qo'shish uchun\nyurakcha tugmasini bosing",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              return WordCard(word: favorites[index]);
            },
          );
        },
      ),
    );
  }
}