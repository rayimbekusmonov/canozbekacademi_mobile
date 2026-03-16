import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import '../widgets/word_card.dart';

class FlashcardsScreen extends StatefulWidget {
  final List<WordModel> words;
  final String title;

  const FlashcardsScreen({super.key, required this.words, required this.title});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFF0D47A1), const Color(0xFF1E88E5)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Text(
                  "${_currentIndex + 1} / ${widget.words.length}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / widget.words.length,
                      minHeight: 6,
                      backgroundColor: isDark ? Colors.white12 : Colors.blue.shade50,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFF9800)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kartochkalar
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.words.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                  child: Center(
                    child: WordCard(word: widget.words[index]),
                  ),
                );
              },
            ),
          ),

          // Boshqaruv tugmalari
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  isActive: _currentIndex > 0,
                  onTap: _currentIndex > 0
                      ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : null,
                  isDark: isDark,
                ),
                // Dots indicator
                Row(
                  children: List.generate(
                    widget.words.length > 10 ? 0 : widget.words.length,
                        (index) => Container(
                      width: index == _currentIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index == _currentIndex
                            ? const Color(0xFF0D47A1)
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  isActive: _currentIndex < widget.words.length - 1,
                  onTap: _currentIndex < widget.words.length - 1
                      ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : null,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isActive,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0D47A1)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}