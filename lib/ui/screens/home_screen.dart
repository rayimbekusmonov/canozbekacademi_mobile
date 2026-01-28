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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // YON MENYU QO'SHILDI
      drawer: _buildDrawer(context),

      appBar: AppBar(
        elevation: 0,
        // centerTitle: true orqali nomni markazga olamiz
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
        // AppBar-da faqat zaruriy Sync tugmasini qoldirish mumkin yoki uni ham menyuga olish mumkin
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: Colors.white70),
            onPressed: () async {
              await context.read<DictionaryProvider>().syncAllDataToFirestore();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ma'lumotlar sinxronizatsiya qilindi!")),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade50),
        child: Column(
          children: [
            // Kun so'zi bo'limi
            _buildDailyWordCard(),

            // Xatolar bo'limi
            _buildMistakesCard(),

            // Darajalar ro'yxati (Grid)
            _buildLevelsGrid(),
          ],
        ),
      ),
    );
  }

  // --- DRAWER (YON MENYU) ---
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
              child: Icon(Icons.school, size: 40, color: Colors.blue),
            ),
            accountName: const Text("Canozbek Academy", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("Til o'rganish markazi"),
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
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("v 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text("Kun so'zi", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 14)),
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
                        Text(dailyWord.tr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text(dailyWord.uz, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MistakesScreen())),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade700]),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_outlined, color: Colors.white, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Xatolar ustida ishlash", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Sizda ${provider.failedWordTrs.length} ta xato so'z bor", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.9, // Overlow xatosini oldini olish uchun biroz kattartirildi
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
                      boxShadow: [BoxShadow(color: levelColors[index][1].withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Stack(
                      children: [
                        Positioned(right: -20, top: -20, child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withValues(alpha: 0.1))),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(currentLevel, style: const TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold)),
                              const Text("Daraja", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 15),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(height: 4),
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
      ),
    );
  }
}