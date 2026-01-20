import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sozlamalar"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blueGrey, Colors.grey]),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "Ovoz sozlamalari",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("Talaffuz tezligi"),
                subtitle: Text("Hozirgi tezlik: ${provider.speechRate.toStringAsFixed(1)}"),
                trailing: const Icon(Icons.speed),
              ),
              Slider(
                value: provider.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) => provider.setSpeechRate(value),
              ),
              TextButton.icon(
                onPressed: () => provider.speak("Merhaba, nasılsınız?"), // Sinab ko'rish
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("Tezlikni sinab ko'rish"),
              ),
              const Divider(height: 40),
              const Text(
                "Ma'lumotlar boshqaruvi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text("Xatolar ro'yxatini tozalash"),
                onTap: () => _confirmClear(context, provider.clearAllFailedWords),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, VoidCallback onClear) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ishonchingiz komilmi?"),
        content: const Text("Barcha xato qilingan so'zlar ro'yxati o'chiriladi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Bekor qilish")),
          TextButton(
            onPressed: () {
              onClear();
              Navigator.pop(context);
            },
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}