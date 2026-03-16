import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import '../../core/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _notifHour = 20;
  int _notifMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationTime();
  }

  Future<void> _loadNotificationTime() async {
    final time = await NotificationService.getSavedTime();
    setState(() {
      _notifHour = time['hour']!;
      _notifMinute = time['minute']!;
    });
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notifHour, minute: _notifMinute),
      helpText: "Eslatma vaqtini tanlang",
      cancelText: "Bekor",
      confirmText: "Saqlash",
    );

    if (picked != null) {
      setState(() {
        _notifHour = picked.hour;
        _notifMinute = picked.minute;
      });
      await NotificationService.setNotificationTime(picked.hour, picked.minute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Eslatma vaqti: ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} ga o'zgartirildi",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sozlamalar"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ?  [Colors.blueGrey.shade900, Colors.black]
                  :  [const Color(0xFF455A64), const Color(0xFF37474F)],
            ),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // OVOZ SOZLAMALARI
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
                onPressed: () => provider.speak("Merhaba, nasılsınız?"),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("Tezlikni sinab ko'rish"),
              ),

              const Divider(height: 40),

              // BILDIRISHNOMA SOZLAMALARI
              const Text(
                "Bildirishnoma sozlamalari",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.notifications_active, color: Colors.orange),
                title: const Text("Kunlik eslatma vaqti"),
                subtitle: Text(
                  "${_notifHour.toString().padLeft(2, '0')}:${_notifMinute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.edit, color: Colors.blue),
                onTap: _pickNotificationTime,
              ),

              const Divider(height: 40),

              // MA'LUMOTLAR BOSHQARUVI
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