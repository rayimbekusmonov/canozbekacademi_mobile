import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart';
import 'words_screen.dart';

class UnitsScreen extends StatelessWidget {
  final List<UnitModel> units;
  final String level;

  const UnitsScreen({super.key, required this.units, required this.level});

  final Map<String, List<Color>> _levelGradients = const {
    'A1': [Color(0xFF2196F3), Color(0xFF0D47A1)],
    'A2': [Color(0xFF00BCD4), Color(0xFF006064)],
    'B1': [Color(0xFFFF9800), Color(0xFFE65100)],
    'B2': [Color(0xFF7C4DFF), Color(0xFF311B92)],
    'C1': [Color(0xFFFF5252), Color(0xFFB71C1C)],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _levelGradients[level] ?? [Colors.blue, Colors.blue.shade900];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "$level Darajasi",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.blueGrey.shade900, Colors.black]
                        : colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 60,
                      child: Text(
                        "${units.length} ta unit",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Progress banner
          SliverToBoxAdapter(
            child: Consumer<DictionaryProvider>(
              builder: (context, provider, child) {
                final progress = provider.getLevelProgress(level);
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : colors[0].withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Circular progress
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 5,
                              backgroundColor: isDark ? Colors.white12 : colors[0].withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation(colors[0]),
                            ),
                            Text(
                              "${(progress * 100).toInt()}%",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isDark ? Colors.white70 : colors[1],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Umumiy o'zlashtirish",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${provider.unitScores.keys.where((k) => k.startsWith(level)).length} / ${units.length} unit tugatilgan",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Unit list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final unit = units[index];
                  final String unitKey = "${unit.level}_unit${unit.unitNo}";

                  return Consumer<DictionaryProvider>(
                    builder: (context, provider, child) {
                      final int? score = provider.unitScores[unitKey];
                      final bool isCompleted = score != null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordsScreen(unit: unit),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isCompleted
                                  ? (score >= 80
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3))
                                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Unit raqami
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: isCompleted
                                      ? LinearGradient(
                                    colors: score >= 80
                                        ? [Colors.green.shade400, Colors.green.shade700]
                                        : [Colors.orange.shade400, Colors.orange.shade700],
                                  )
                                      : LinearGradient(colors: colors),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                                      : Text(
                                    "${unit.unitNo}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Unit nomi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      unit.unitName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${unit.words.length} ta so'z",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Score badge
                              if (score != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: score >= 80
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$score%",
                                    style: TextStyle(
                                      color: score >= 80 ? Colors.green.shade700 : Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isDark ? Colors.white24 : Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: units.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}