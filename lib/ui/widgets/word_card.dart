import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart';

class WordCard extends StatelessWidget {
  final WordModel word;
  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DictionaryProvider>(context);
    final bool isFav = provider.isFavorite(word.tr);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: _buildCard(
          title: word.tr,
          subtitle: "TURKCHA",
          color: Colors.blue.shade700,
          textColor: Colors.white,
          isFront: true,
          isFav: isFav,
          onFavTap: () => provider.toggleFavorite(word.tr),
          onSpeakTap: () => provider.speak(word.tr),
        ),
        back: _buildCard(
          title: word.uz,
          subtitle: "O'ZBEKCHA",
          color: Theme.of(context).cardColor,
          textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.blue.shade900,
          example: word.example,
          isFront: false,
          isFav: isFav,
          onFavTap: () => provider.toggleFavorite(word.tr),
          onSpeakTap: () => provider.speak(word.tr),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    String? example,
    required bool isFront,
    required bool isFav,
    required VoidCallback onFavTap,
    required VoidCallback onSpeakTap,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  subtitle,
                  style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5
                  )
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              if (example != null && example.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Divider(color: Colors.blueGrey.withOpacity(0.2), height: 1),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, size: 16, color: textColor.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        example,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Audio tugmasi
        if (isFront)
          Positioned(
            top: 12,
            right: 12,
            child: Tooltip(
              message: "Talaffuzni eshitish",
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onSpeakTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.volume_up, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),

        // Favorit tugmasi
        Positioned(
          top: 12,
          left: 12,
          child: Tooltip(
            message: isFav ? "Favoritlardan o'chirish" : "Favoritlarga qo'shish",
            child: InkWell(
              onTap: onFavTap,
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isFront
                    ? Colors.white.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.05),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : (isFront ? Colors.white : Colors.blue.shade700),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}