import 'package:canozbekacademi/ui/screens/units_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';

class HomeScreen extends StatelessWidget {
  final List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dream Language Turkcha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              // HomeScreen.dart ichidagi GridView itemBuilder ichiga joylang:
              onTap: () {
                final provider = Provider.of<DictionaryProvider>(context, listen: false);
                final filteredUnits = provider.getUnitsByLevel(levels[index]);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitsScreen(
                      units: filteredUnits,
                      level: levels[index],
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.blueAccent,
                child: Center(
                  child: Text(
                    levels[index],
                    style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}