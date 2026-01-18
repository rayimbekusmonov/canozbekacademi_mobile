import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import '../widgets/word_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<DictionaryProvider>().favoriteWords;

    return Scaffold(
      appBar: AppBar(title: Text("Mening lug'atim")),
      body: favorites.isEmpty
          ? Center(child: Text("Hali so'zlar qo'shilmagan"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) => WordCard(word: favorites[index]),
      ),
    );
  }
}