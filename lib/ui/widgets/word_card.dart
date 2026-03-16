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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      height: 200,
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: _buildFront(context, provider, isFav, isDark),
        back: _buildBack(context, provider, isFav, isDark),
      ),
    );
  }

  Widget _buildFront(BuildContext context, DictionaryProvider provider, bool isFav, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF283593)]
              : [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(isDark ? 0.2 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Fon dekoratsiyasi
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.03),
            ),
          ),

          // Asosiy kontent
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "TURKCHA",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // So'z
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 14, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(width: 6),
                    Text(
                      "Tarjimasini ko'rish uchun bosing",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Audio tugma
          Positioned(
            top: 12,
            right: 12,
            child: _buildIconButton(
              icon: Icons.volume_up_rounded,
              onTap: () => provider.speak(word.tr),
              bgColor: Colors.white.withOpacity(0.15),
              iconColor: Colors.white,
            ),
          ),

          // Favorit tugma
          Positioned(
            top: 12,
            left: 12,
            child: _buildIconButton(
              icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              onTap: () => provider.toggleFavorite(word.tr),
              bgColor: Colors.white.withOpacity(0.15),
              iconColor: isFav ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context, DictionaryProvider provider, bool isFav, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Fon dekoratsiyasi
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              Icons.translate_rounded,
              size: 80,
              color: isDark
                  ? Colors.blue.withOpacity(0.05)
                  : Colors.blue.withOpacity(0.04),
            ),
          ),

          // Asosiy kontent
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "O'ZBEKCHA",
                    style: TextStyle(
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjima
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word.uz,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0D47A1),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Misol
                if (word.example != null && word.example!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: isDark ? Colors.white30 : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            word.example!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Audio tugma
          Positioned(
            top: 12,
            right: 12,
            child: _buildIconButton(
              icon: Icons.volume_up_rounded,
              onTap: () => provider.speak(word.tr),
              bgColor: Colors.blue.withOpacity(isDark ? 0.15 : 0.08),
              iconColor: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
            ),
          ),

          // Favorit tugma
          Positioned(
            top: 12,
            left: 12,
            child: _buildIconButton(
              icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              onTap: () => provider.toggleFavorite(word.tr),
              bgColor: Colors.blue.withOpacity(isDark ? 0.15 : 0.08),
              iconColor: isFav
                  ? Colors.redAccent
                  : (isDark ? Colors.blue.shade200 : Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}