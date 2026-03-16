import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  final List<Map<String, dynamic>> _levelData = const [
    {'name': 'A1', 'label': 'Boshlang\'ich', 'color': 0xFF2196F3},
    {'name': 'A2', 'label': 'Oddiy muloqot', 'color': 0xFF00BCD4},
    {'name': 'B1', 'label': 'O\'rta daraja', 'color': 0xFFFF9800},
    {'name': 'B2', 'label': 'Murakkab', 'color': 0xFF7C4DFF},
    {'name': 'C1', 'label': 'Professional', 'color': 0xFFFF5252},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Statistika",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFF3F51B5), const Color(0xFF1A237E)],
            ),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Umumiy natija kartochkasi
              _buildOverallCard(context, provider, isDark),
              const SizedBox(height: 20),

              // Streak kartochkasi
              _buildStreakCard(context, provider, isDark),
              const SizedBox(height: 24),

              // Darajalar header
              Row(
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
                    "Darajalar bo'yicha",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Darajalar
              ..._levelData.map((data) => _buildLevelCard(
                context,
                provider,
                data['name'],
                data['label'],
                Color(data['color']),
                isDark,
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallCard(BuildContext context, DictionaryProvider provider, bool isDark) {
    final score = provider.averageScore;
    final completed = provider.completedUnitsCount;
    final total = provider.allUnits.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF283593)]
              : [const Color(0xFF3F51B5), const Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(
                  "${score.toInt()}%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "O'rtacha natija",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$completed / $total unit tugatilgan",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${provider.allWords.length} ta so'z bazada",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, DictionaryProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.orange.withOpacity(isDark ? 0.2 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${provider.streakCount} kunlik streak",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Har kuni kirib, streakni uzmang!",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
      BuildContext context,
      DictionaryProvider provider,
      String level,
      String label,
      Color color,
      bool isDark,
      ) {
    final progress = provider.getLevelProgress(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: color.withOpacity(isDark ? 0.1 : 0.08),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}