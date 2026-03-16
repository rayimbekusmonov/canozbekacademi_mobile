import 'package:canozbekacademi/ui/screens/settings_screen.dart';
import 'package:canozbekacademi/ui/screens/statistics_screen.dart';
import 'package:canozbekacademi/ui/screens/units_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/support_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        elevation: 0,
        title: InkWell(
          onTap: () {
            showSearch(
              context: context,
              delegate: WordSearchDelegate(allWords: context.read<DictionaryProvider>().allWords),
            );
          },
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Canozbek Academy — Qidirish",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [Colors.blue.shade800, Colors.blue.shade500],
            ),
          ),
        ),
        actions: [
          Consumer<DictionaryProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 24),
                    const SizedBox(width: 2),
                    Text(
                      "${provider.streakCount}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopInfoCard(context),
          Expanded(child: _buildLevelsGrid(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildTopInfoCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final dailyWord = provider.dailyWord;
        final hasMistakes = provider.failedWordTrs.isNotEmpty;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              if (dailyWord != null)
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
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
                            Text(dailyWord.uz, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.speak(dailyWord.tr),
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.blue),
                        style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),

              if (hasMistakes)
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MistakesScreen())),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_fix_high_rounded, size: 18, color: isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "${provider.failedWordTrs.length} ta xatoni tuzatamizmi?",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 13
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isDark ? Colors.amber.shade300 : Colors.amber.shade800),
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

  Widget _buildLevelsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 1.0 : 0.95;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: childAspectRatio,
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
                  boxShadow: [BoxShadow(color: levelColors[index][1].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  children: [
                    Positioned(right: -10, top: -10, child: CircleAvatar(radius: 30, backgroundColor: Colors.white.withOpacity(0.1))),
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

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.black, Colors.blueGrey.shade900]
                        : [Colors.blue.shade900, Colors.blue.shade600]
                )
            ),
            currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school_rounded, size: 40, color: Colors.blue)
            ),
            accountName: const Text("Canozbek Academy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("Bilim — qudratdir!"),
          ),

          // Mavjud elementlar
          _drawerItem(context, Icons.favorite, "Sevimli so'zlar",
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))),
          _drawerItem(context, Icons.bar_chart_rounded, "Statistika",
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()))),
          _drawerItem(context, Icons.settings, "Sozlamalar",
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),

          // --- MANA BU YANGI BO'LIM (MUROJAAT) ---
          const Divider(), // Ajratuvchi chiziq
          _drawerItem(
            context,
            Icons.headset_mic_rounded,
            "Murojaat va yordam",
                () async {
              Navigator.pop(context);
              final success = await SupportService.connectToSupport();
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Telegram ilovasi topilmadi")),
                );
              }
            },
          ),
          // ---------------------------------------

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code_rounded, size: 16, color: Colors.blue.shade400),
                    const SizedBox(width: 8),
                    const Text("Developed by Rayimbek",
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Versiya 1.0.0", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade400),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () { Navigator.pop(context); onTap(); },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text("Bilim olishdan to'xtamang!",
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text("© 2026 Canozbek Academy",
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }
}