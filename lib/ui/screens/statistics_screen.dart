import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sizning natijalaringiz"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Umumiy progress aylanasi
              _buildOverallProgress(provider.averageScore),
              const SizedBox(height: 30),

              const Text(
                "Darajalar bo'yicha o'zlashtirish:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Har bir daraja uchun progress bar
              _buildLevelBar("A1 Darajasi", provider.getLevelProgress("A1"), Colors.blue),
              _buildLevelBar("A2 Darajasi", provider.getLevelProgress("A2"), Colors.teal),
              _buildLevelBar("B1 Darajasi", provider.getLevelProgress("B1"), Colors.orange),
              _buildLevelBar("B2 Darajasi", provider.getLevelProgress("B2"), Colors.purple),
              _buildLevelBar("C1 Darajasi", provider.getLevelProgress("C1"), Colors.red),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(double score) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue.shade700,
            ),
          ),
          Column(
            children: [
              Text(
                "${score.toInt()}%",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("O'rtacha natija", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBar(String label, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${(progress * 100).toInt()}%"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}