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
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          // Progress bar - foydalanuvchi qayerdaligini ko'rib turadi
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.words.length,
            backgroundColor: Colors.blue.shade100,
            color: Colors.orange,
            minHeight: 8,
          ),

          const Spacer(),

          // Kartochkalar (Swipe orqali o'tadigan qism)
          SizedBox(
            height: 400, // WordCard bo'yi
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.words.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: WordCard(word: widget.words[index]),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // Pastki boshqaruv tugmalari
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios,
                  onTap: _currentIndex > 0 ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } : null,
                ),
                Text(
                  "${_currentIndex + 1} / ${widget.words.length}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: _currentIndex < widget.words.length - 1 ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, VoidCallback? onTap}) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: onTap != null ? Colors.blue.shade800 : Colors.grey.shade300,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}