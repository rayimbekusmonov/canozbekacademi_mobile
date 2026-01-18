import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart'; // WordCard-ni qo'shdik

class WordSearchDelegate extends SearchDelegate {
  final List<WordModel> allWords;

  WordSearchDelegate({required this.allWords});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    // Qidiruv natijalarini filtrlaymiz
    final results = allWords.where((word) =>
    word.tr.toLowerCase().contains(query.toLowerCase()) ||
        word.uz.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text("So'z topilmadi"),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) {
        final word = results[index];
        return ListTile(
          title: Text(word.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(word.uz),
          leading: const Icon(Icons.translate, color: Colors.blue),
          onTap: () {
            // So'z bosilganda WordCard-ni alohida oynada ko'rsatamiz
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: WordCard(word: word),
              ),
            );
          },
        );
      },
    );
  }
}