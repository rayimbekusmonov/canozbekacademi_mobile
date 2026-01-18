import 'package:canozbekacademi/ui/screens/units_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import 'favorites_screen.dart';
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            icon: const Icon(Icons.cloud_upload, color: Colors.white70),
            onPressed: () async {
              await context.read<DictionaryProvider>().syncAllDataToFirestore();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Barcha ma'lumotlar serverga yuklandi!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: WordSearchDelegate(
                  allWords: Provider.of<DictionaryProvider>(context, listen: false).allWords,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50, // Orqa fonni biroz ochroq qilamiz
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1, // Kartochka bo'yi va eni nisbati
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              return GestureDetector(
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
                child: Hero(
                  tag: levels[index], // Animatsiya uchun
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: levelColors[index],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: levelColors[index][1].withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Bezak uchun burchakdagi aylana
                        Positioned(
                          right: -20,
                          top: -20,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                levels[index],
                                style: const TextStyle(
                                  fontSize: 42,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                "Daraja",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}