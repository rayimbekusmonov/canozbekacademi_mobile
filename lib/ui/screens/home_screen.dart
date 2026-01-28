import 'package:canozbekacademi/ui/screens/settings_screen.dart';
import 'package:canozbekacademi/ui/screens/statistics_screen.dart';
import 'package:canozbekacademi/ui/screens/units_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import 'favorites_screen.dart';
import 'mistakes_screen.dart';
import 'search_delegate.dart';

class HomeScreen extends StatelessWidget {
  final List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  final List<List<Color>> levelColors = [
    [Colors.blue.shade400, Colors.blue.shade900],
    [Colors.teal.shade400, Colors.teal.shade900],
    [Colors.orange.shade400, Colors.orange.shade900],
    [Colors.deepPurple.shade400, Colors.deepPurple.shade900],
    [Colors.red.shade400, Colors.red.shade900],
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade500],
            ),
          ),
        ),
        title: const Text(
          'Canozbek Academy',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            tooltip: "Sinxronizatsiya",
            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white70),
            onPressed: () async {
              await context.read<DictionaryProvider>().syncAllDataToFirestore();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ma'lumotlar sinxronizatsiya qilindi!")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // KUN SO'ZI VA XATOLAR (Birlashtirilgan blok)
          _buildTopInfoCard(context),

          // DARAJALAR GRID
          Expanded(
            child: _buildLevelsGrid(),
          ),

          // FOOTER (Imzo bilan)
          _buildFooter(),
        ],
      ),
    );
  }

  // --- TOP INFO CARD (Daily Word + Mistakes) ---
  Widget _buildTopInfoCard(BuildContext context) {
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final dailyWord = provider.dailyWord;
        final hasMistakes = provider.failedWordTrs.isNotEmpty;

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              // Kun so'zi qismi
              if (dailyWord != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("KUN SO'ZI",
                                style: TextStyle(color: Colors.blue.shade300, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            const SizedBox(height: 8),
                            Text(dailyWord.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text(dailyWord.uz, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.speak(dailyWord.tr),
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.blue),
                        style: IconButton.styleFrom(backgroundColor: Colors.blue.shade50),
                      ),
                    ],
                  ),
                ),

              // Xatolar qismi (Alohida banner emas, nafis qator)
              if (hasMistakes)
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MistakesScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50, // Qizil o'rniga yumshoq sariq
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_fix_high_rounded, size: 18, color: Colors.amber.shade800),
                        const SizedBox(width: 10),
                        Text(
                          "${provider.failedWordTrs.length} ta xatoni tuzatamizmi?",
                          style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.amber.shade800),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- DARAJALAR GRID ---
  Widget _buildLevelsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.95,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return Consumer<DictionaryProvider>(
          builder: (context, provider, child) {
            final progress = provider.getLevelProgress(level);
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UnitsScreen(units: provider.getUnitsByLevel(level), level: level))),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(colors: levelColors[index], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: levelColors[index][1].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  children: [
                    Positioned(right: -10, top: -10, child: CircleAvatar(radius: 30, backgroundColor: Colors.white.withValues(alpha: 0.1))),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(level, style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)),
                          ),
                          const SizedBox(height: 5),
                          Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- YON MENYU (DRAWER) ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600])),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.school_rounded, size: 40, color: Colors.blue)),
            accountName: const Text("Canozbek Academy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("Bilim — qudratdir!"),
          ),
          _drawerItem(context, Icons.search, "So'z qidirish", () {
            showSearch(context: context, delegate: WordSearchDelegate(allWords: context.read<DictionaryProvider>().allWords));
          }),
          _drawerItem(context, Icons.favorite, "Sevimli so'zlar", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))),
          _drawerItem(context, Icons.bar_chart_rounded, "Statistika", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()))),
          _drawerItem(context, Icons.settings, "Sozlamalar", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code_rounded, size: 16, color: Colors.blue.shade800),
                    const SizedBox(width: 8),
                    const Text("Developed by Rayimbek", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 14)),
                  ],
                ),
                Text("Versiya 1.0.0", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () { Navigator.pop(context); onTap(); },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: Colors.blue.shade300),
              const SizedBox(width: 8),
              Text("Bilim olishdan to'xtamang!", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 4),
          Text("© 2026 Canozbek Academy", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
        ],
      ),
    );
  }
}