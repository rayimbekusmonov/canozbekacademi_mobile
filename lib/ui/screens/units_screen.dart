import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';
import 'words_screen.dart';

class UnitsScreen extends StatelessWidget {
  final List<UnitModel> units;
  final String level;

  const UnitsScreen({super.key, required this.units, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$level Darajasi - Unitlar')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: units.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final unit = units[index];
          return ListTile(
            tileColor: Colors.blueGrey.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('${unit.unitNo}-Ünite', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(unit.unitName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordsScreen(unit: unit),
                ),
              );
            },
          );
        },
      ),
    );
  }
}