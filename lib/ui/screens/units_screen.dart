import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider qo'shildi
import '../../data/models/word_model.dart';
import '../../providers/dictionary_provider.dart'; // Provider-ni import qiling
import 'words_screen.dart';

class UnitsScreen extends StatelessWidget {
  final List<UnitModel> units;
  final String level;

  const UnitsScreen({super.key, required this.units, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$level Darajasi - Unitlar'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: units.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        // units_screen.dart faylidagi itemBuilder qismini quyidagicha almashtiring:

        itemBuilder: (context, index) {
          final unit = units[index];
          final String unitKey = "${unit.level}_unit${unit.unitNo}";

          return Consumer<DictionaryProvider>(
            builder: (context, provider, child) {
              final int? score = (provider as dynamic).unitScores != null
                  ? (provider as dynamic).unitScores[unitKey]
                  : null;

              return Card( // ListTile-ni Card-ga o'raymiz
                elevation: 2, // Soya effekti endi Card-da ishlaydi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  // tileColor: Colors.white, // Agar Card ishlatilsa bunga hojat yo'q
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      unit.unitNo.toString(),
                      style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    unit.unitName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("${unit.words.length} ta so'z"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: score >= 80 ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$score%",
                            style: TextStyle(
                              color: score >= 80 ? Colors.green.shade800 : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordsScreen(unit: unit),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}