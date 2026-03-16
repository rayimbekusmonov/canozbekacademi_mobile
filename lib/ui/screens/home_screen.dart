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

  final List<String> levelDescriptions = [
    'Boshlang\'ich',
    'Oddiy muloqot',
    'O\'rta daraja',
    'Murakkab mavzular',
    'Professional',
  ];

  final List<IconData> levelIcons = [
    Icons.rocket_launch_rounded,
    Icons.trending_up_rounded,
    Icons.auto_awesome_rounded,
    Icons.psychology_rounded,
    Icons.military_tech_rounded,
  ];

  final List<List<Color>> levelColors = [
    [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
    [const Color(0xFF00BCD4), const Color(0xFF006064)],
    [const Color(0xFFFF9800), const Color(0xFFE65100)],
    [const Color(0xFF7C4DFF), const Color(0xFF311B92)],
    [const Color(0xFFFF5252), const Color(0xFFB71C1C)],
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          // APPBAR
          _buildSliverAppBar(context, isDark),

          // KUN SO'ZI
          SliverToBoxAdapter(child: _buildDailyWordCard(context)),

          // XATOLAR BANNER
          SliverToBoxAdapter(child: _buildMistakesBanner(context)),

          // SECTION HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Darajalar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LEVELS GRID
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildLevelCard(context, index),
                childCount: levels.length,
              ),
            ),
          ),

          // FOOTER
          SliverToBoxAdapter(child: _buildFooter(context)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFF0D47A1), const Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: GestureDetector(
          onTap: () {
            showSearch(
              context: context,
              delegate: WordSearchDelegate(
                allWords: context.read<DictionaryProvider>().allWords,
              ),
            );
          },
          child: Container(
            height: 38,
            margin: const EdgeInsets.only(right: 70),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "So'z qidirish...",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Consumer<DictionaryProvider>(
          builder: (context, provider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${provider.streakCount}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyWordCard(BuildContext context) {
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final dailyWord = provider.dailyWord;
        if (dailyWord == null) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A237E), const Color(0xFF283593)]
                  : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              // Chap tomon — icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(isDark ? 0.3 : 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.today_rounded,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // O'rta — matn
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KUN SO'ZI",
                      style: TextStyle(
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dailyWord.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dailyWord.uz,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // O'ng tomon — audio tugma
              IconButton(
                onPressed: () => provider.speak(dailyWord.tr),
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMistakesBanner(BuildContext context) {
    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        if (provider.failedWordTrs.isEmpty) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MistakesScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_fix_high_rounded,
                      size: 18, color: Colors.orange.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${provider.failedWordTrs.length} ta xatoni tuzatamizmi?",
                    style: TextStyle(
                      color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.orange.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, int index) {
    final level = levels[index];

    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final progress = provider.getLevelProgress(level);
        final unitCount = provider.getUnitsByLevel(level).length;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitsScreen(
                units: provider.getUnitsByLevel(level),
                level: level,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: levelColors[index],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: levelColors[index][1].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Fon dekoratsiyasi
                Positioned(
                  right: -15,
                  top: -15,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.08),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: -20,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                ),

                // Asosiy kontent
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon va level
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(levelIcons[index],
                                color: Colors.white, size: 22),
                          ),
                          Text(
                            level,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Tavsif
                      Text(
                        levelDescriptions[index],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$unitCount ta unit",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    : [const Color(0xFF0D47A1), const Color(0xFF1E88E5)],
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 36, color: Color(0xFF0D47A1)),
            ),
            accountName: const Text("Can Özbek Academy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("Bilim — qudratdir!"),
          ),
          _drawerItem(context, Icons.favorite_rounded, "Sevimli so'zlar",
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))),
          _drawerItem(context, Icons.bar_chart_rounded, "Statistika",
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()))),
          _drawerItem(context, Icons.settings_rounded, "Sozlamalar",
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
          const Divider(),
          _drawerItem(context, Icons.headset_mic_rounded, "Murojaat va yordam",
                  () async {
                Navigator.pop(context);
                final success = await SupportService.connectToSupport();
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Telegram ilovasi topilmadi")),
                  );
                }
              }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code_rounded, size: 14, color: Colors.blue.shade400),
                    const SizedBox(width: 6),
                    const Text("Developed by Rayimbek",
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Versiya 1.0.0",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
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
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text("Bilim olishdan to'xtamang!",
              style: TextStyle(
                  color: Colors.blueGrey.shade400,
                  fontSize: 12,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text("© 2026 Can Özbek Academy",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                  fontSize: 10)),
        ],
      ),
    );
  }
}