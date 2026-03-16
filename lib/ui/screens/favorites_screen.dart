import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import '../widgets/word_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Sevimli so'zlar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFFE91E63), const Color(0xFFC2185B)],
            ),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoriteWords;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.pink.withOpacity(0.1)
                          : Colors.pink.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 50,
                      color: isDark ? Colors.pink.shade200 : Colors.pink.shade200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Sevimli so'zlar hali yo'q",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "So'zlarni favoritga qo'shish uchun\nyurakcha tugmasini bosing",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Info banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.pink.withOpacity(0.1) : Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite_rounded,
                        size: 18, color: Colors.pink.shade300),
                    const SizedBox(width: 10),
                    Text(
                      "${favorites.length} ta sevimli so'z",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.pink.shade200 : Colors.pink.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    return WordCard(word: favorites[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}