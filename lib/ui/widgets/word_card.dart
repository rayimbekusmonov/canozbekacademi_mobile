import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart'; // Providerni qo'shdik
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart'; // Provider yo'lini tekshiring

class WordCard extends StatefulWidget {
  final WordModel word;
  const WordCard({super.key, required this.word});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    // DictionaryProvider ga ulanamiz
    final provider = Provider.of<DictionaryProvider>(context);
    final bool isFav = provider.isFavorite(widget.word.tr);

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: _buildCard(
          title: widget.word.tr,
          subtitle: "Turkcha",
          color: Colors.blue.shade700,
          textColor: Colors.white,
          isFront: true,
          isFav: isFav,
          onFavTap: () => provider.toggleFavorite(widget.word.tr),
        ),
        back: _buildCard(
          title: widget.word.uz,
          subtitle: "O'zbekcha",
          color: Colors.white,
          textColor: Colors.blue.shade900,
          example: widget.word.example,
          isFront: false,
          isFav: isFav,
          onFavTap: () => provider.toggleFavorite(widget.word.tr),
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
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (example != null) ...[
                const Divider(color: Colors.blueGrey, height: 30),
                Text(
                  example,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor.withOpacity(0.9), fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ],
            ],
          ),
        ),

        // Audio tugmasi (Faqat old tomonda)
        if (isFront)
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.white),
                onPressed: () => _speak(title),
              ),
            ),
          ),

        Positioned(
          top: 10,
          left: 10,
          child: CircleAvatar(
            backgroundColor: isFront ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
            child: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : (isFront ? Colors.white : Colors.blue),
              ),
              onPressed: onFavTap,
            ),
          ),
        ),
      ],
    );
  }
}