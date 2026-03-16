import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';

class WordSearchDelegate extends SearchDelegate {
  final List<WordModel> allWords;

  WordSearchDelegate({required this.allWords});

  @override
  String get searchFieldLabel => "So'z qidirish...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Bo'sh qidiruv
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blue.withOpacity(0.08)
                    : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_rounded,
                  size: 40,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade200),
            ),
            const SizedBox(height: 20),
            Text(
              "Turkcha yoki o'zbekcha so'z kiriting",
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.blueGrey.shade300,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    // Filtrlash
    final results = allWords.where((word) =>
    word.tr.toLowerCase().contains(query.toLowerCase()) ||
        word.uz.toLowerCase().contains(query.toLowerCase())).toList();

    // Topilmadi
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.orange.withOpacity(0.08)
                      : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded,
                    size: 40, color: Colors.orange.shade300),
              ),
              const SizedBox(height: 24),
              Text(
                "'$query' topilmadi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Imlo xatolarini tekshirib ko'ring yoki\nboshqa so'z kiritib ko'ring",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () => query = "",
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Qidiruvni tozalash"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Natijalar
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Natijalar soni
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
          child: Text(
            "${results.length} ta natija topildi",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: results.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final word = results[index];

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 210,
                        child: WordCard(word: word),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Harf badge
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            word.tr[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // So'z va tarjima
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              word.uz,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.blue.shade200
                                    : Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}