import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';

class WordSearchDelegate extends SearchDelegate {
  final List<WordModel> allWords;

  WordSearchDelegate({required this.allWords});

  @override
  String get searchFieldLabel => "So'z qidirish...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.blueGrey),
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    // 1. Qidiruv maydoni bo'sh bo'lgandagi holat
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 100, color: Colors.blue.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              "Turkcha yoki o'zbekcha so'z kiriting",
              style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Natijalarni filtrlaymiz
    final results = allWords.where((word) =>
    word.tr.toLowerCase().contains(query.toLowerCase()) ||
        word.uz.toLowerCase().contains(query.toLowerCase())
    ).toList();

    // 2. SO'Z TOPILMAGANDAGI HOLAT (User-friendly)
    if (results.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: Colors.orange.shade300,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "'$query' topilmadi",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Imlo xatolarini tekshirib ko'ring yoki boshqa so'z kiritib ko'ring.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => query = "",
                child: const Text("Qidiruvni tozalash"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. NATIJALAR RO'YXATI
    return ListView.separated(
      itemCount: results.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final word = results[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              word.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              word.uz,
              style: TextStyle(color: Colors.blue.shade700),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              // WordCard-ni dialoq oyna sifatida ko'rsatish
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                  child: WordCard(word: word),
                ),
              );
            },
          ),
        );
      },
    );
  }
}