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
  bool _notifEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await NotificationService.getSavedTime();
    final enabled = await NotificationService.isNotificationEnabled();
    setState(() {
      _notifHour = time['hour']!;
      _notifMinute = time['minute']!;
      _notifEnabled = enabled;
    });
  }

  Future<void> _pickNotificationTime() async {
    int tempHour = _notifHour;
    int tempMinute = _notifMinute;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              title: const Text("Eslatma vaqti",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Soat
                  _buildTimeColumn(
                    value: tempHour,
                    isDark: isDark,
                    onUp: () =>
                        setDialogState(() => tempHour = (tempHour + 1) % 24),
                    onDown: () => setDialogState(
                            () => tempHour = (tempHour - 1 + 24) % 24),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(":",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                  // Daqiqa
                  _buildTimeColumn(
                    value: tempMinute,
                    isDark: isDark,
                    onUp: () => setDialogState(
                            () => tempMinute = (tempMinute + 5) % 60),
                    onDown: () => setDialogState(
                            () => tempMinute = (tempMinute - 5 + 60) % 60),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Bekor"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("Saqlash",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _notifHour = tempHour;
        _notifMinute = tempMinute;
      });
      await NotificationService.setNotificationTime(tempHour, tempMinute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Eslatma vaqti: ${tempHour.toString().padLeft(2, '0')}:${tempMinute.toString().padLeft(2, '0')} ga o'zgartirildi",
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildTimeColumn({
    required int value,
    required bool isDark,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onUp,
          icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 30),
        ),
        Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D47A1),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onDown,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Sozlamalar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFF455A64), const Color(0xFF37474F)],
            ),
          ),
        ),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ========== OVOZ SOZLAMALARI ==========
              _buildSectionHeader(
                icon: Icons.record_voice_over_rounded,
                title: "Ovoz sozlamalari",
                color: Colors.blue,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildSettingsCard(
                isDark: isDark,
                child: Column(
                  children: [
                    // Tezlik ko'rsatkichi
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(Icons.speed_rounded,
                                color: isDark
                                    ? Colors.blue.shade200
                                    : Colors.blue.shade700,
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Talaffuz tezligi",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  _getSpeedLabel(provider.speechRate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              provider.speechRate.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.blue.shade200
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF0D47A1),
                          inactiveTrackColor: Colors.blue.withOpacity(0.15),
                          thumbColor: const Color(0xFF0D47A1),
                          overlayColor: Colors.blue.withOpacity(0.1),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: provider.speechRate,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (value) => provider.setSpeechRate(value),
                        ),
                      ),
                    ),

                    // Sinab ko'rish tugmasi
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: GestureDetector(
                        onTap: () => provider.speak("Merhaba, nasılsınız?"),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_rounded,
                                  size: 20,
                                  color: isDark
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                "Tezlikni sinab ko'rish",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ========== BILDIRISHNOMA SOZLAMALARI ==========
              _buildSectionHeader(
                icon: Icons.notifications_rounded,
                title: "Bildirishnoma",
                color: Colors.orange,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildSettingsCard(
                isDark: isDark,
                child: Column(
                  children: [
                    // Yoqish/O'chirish
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _notifEnabled
                                  ? Colors.orange.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              _notifEnabled
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              color: _notifEnabled ? Colors.orange : Colors.grey,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Kunlik eslatma",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  _notifEnabled
                                      ? "Har kuni eslatma keladi"
                                      : "Eslatmalar o'chirilgan",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notifEnabled,
                            activeColor: Colors.orange,
                            onChanged: (value) async {
                              setState(() => _notifEnabled = value);
                              await NotificationService.setNotificationEnabled(
                                  value);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Vaqt va test — faqat yoqilganda
                    if (_notifEnabled) ...[
                      Divider(
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                          height: 1),

                      // Vaqt tanlash
                      InkWell(
                        onTap: _pickNotificationTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                  Colors.orange.withOpacity(isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(Icons.access_time_rounded,
                                    color: isDark
                                        ? Colors.orange.shade200
                                        : Colors.orange.shade700,
                                    size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Eslatma vaqti",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Bosib o'zgartiring",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_notifHour.toString().padLeft(2, '0')}:${_notifMinute.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.orange.shade200
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ========== MA'LUMOTLAR BOSHQARUVI ==========
              _buildSectionHeader(
                icon: Icons.storage_rounded,
                title: "Ma'lumotlar boshqaruvi",
                color: Colors.red,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildSettingsCard(
                isDark: isDark,
                child: InkWell(
                  onTap: () =>
                      _confirmClear(context, provider.clearAllFailedWords),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(Icons.delete_sweep_rounded,
                              color: isDark
                                  ? Colors.red.shade200
                                  : Colors.red.shade700,
                              size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Xatolar ro'yxatini tozalash",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                "Barcha xato so'zlarni o'chirish",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Ilova haqida
              Center(
                child: Text(
                  "Can Özbek Academy · Versiya 1.0.0",
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ========== YORDAMCHI WIDGETLAR ==========

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
  }

  String _getSpeedLabel(double rate) {
    if (rate <= 0.3) return "Juda sekin";
    if (rate <= 0.5) return "Sekin";
    if (rate <= 0.7) return "Normal";
    if (rate <= 0.9) return "Tez";
    return "Juda tez";
  }

  void _confirmClear(BuildContext context, VoidCallback onClear) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.red.shade400, size: 24),
            const SizedBox(width: 10),
            const Text("Ishonchingiz komilmi?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
            "Barcha xato qilingan so'zlar ro'yxati butunlay o'chiriladi. Bu amalni qaytarib bo'lmaydi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () {
              onClear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Xatolar ro'yxati tozalandi"),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("O'chirish",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}