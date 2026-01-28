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
          _buildDailyWordCard(),
          _buildMistakesCard(),
          // Grid endi asosiy bo'shliqni egallaydi
          _buildLevelsGrid(),
          // Pastki qismdagi nafis imzo/footer
          _buildFooter(),
        ],
      ),
    );
  }

  // --- YON MENYU (DRAWER) ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade600],
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.school_rounded, size: 40, color: Colors.blue),
            ),
            accountName: const Text("Canozbek Academy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("Muvaffaqiyat kaliti — bilimda!"),
          ),
          _drawerItem(
            icon: Icons.search,
            text: "So'z qidirish",
            onTap: () {
              Navigator.pop(context);
              showSearch(
                context: context,
                delegate: WordSearchDelegate(
                  allWords: Provider.of<DictionaryProvider>(context, listen: false).allWords,
                ),
              );
            },
          ),
          _drawerItem(
            icon: Icons.favorite,
            text: "Sevimli so'zlar",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.bar_chart_rounded,
            text: "Statistika",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.settings,
            text: "Sozlamalar",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          // --- MENYU PASTIDAGI IMZO ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code_rounded, size: 16, color: Colors.blue.shade800),
                    const SizedBox(width: 8),
                    const Text(
                      "Developed by Rayimbek",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Versiya 1.0.0",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildDailyWordCard() {
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final dailyWord = provider.dailyWord;
        if (dailyWord == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text("KUN SO'ZI",
                      style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dailyWord.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text(dailyWord.uz, style: TextStyle(fontSize: 17, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.speak(dailyWord.tr),
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    style: IconButton.styleFrom(backgroundColor: Colors.blue.shade50),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMistakesCard() {
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        if (provider.failedWordTrs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MistakesScreen())),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade700]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_alt_outlined, color: Colors.white, size: 28),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text("Xatolar ustida ishlash (${provider.failedWordTrs.length})",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelsGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.95,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final String currentLevel = levels[index];
          return Consumer<DictionaryProvider>(
            builder: (context, provider, child) {
              final double progress = provider.getLevelProgress(currentLevel);
              return GestureDetector(
                onTap: () {
                  final filteredUnits = provider.getUnitsByLevel(currentLevel);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UnitsScreen(units: filteredUnits, level: currentLevel)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(colors: levelColors[index], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: levelColors[index][1].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: -10, top: -10, child: CircleAvatar(radius: 30, backgroundColor: Colors.white.withValues(alpha: 0.1))),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currentLevel, style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
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
      ),
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
              Text(
                "Bilim olishdan to'xtamang!",
                style: TextStyle(
                  color: Colors.blueGrey.shade400,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "© 2026 Canozbek Academy",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ],
      ),
    );
  }
}