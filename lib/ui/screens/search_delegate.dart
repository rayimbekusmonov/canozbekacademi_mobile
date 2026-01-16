import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';

class WordSearchDelegate extends SearchDelegate {
  final List<WordModel> allWords;

  WordSearchDelegate({required this.allWords});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = allWords.where((word) =>
    word.tr.toLowerCase().contains(query.toLowerCase()) ||
        word.uz.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final word = results[index];
        return ListTile(
          title: Text(word.tr, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(word.uz),
          onTap: () {
          },
        );
      },
    );
  }
}