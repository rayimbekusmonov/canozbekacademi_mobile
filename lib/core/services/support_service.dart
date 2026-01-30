import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SupportService {
  static const String telegramUsername = 'rayimbekusmonov';

  static Future<void> connectToSupport() async {
    // Avtomatik xabar shabloni
    String message = "Assalomu alaykum, Canozbek Academy ilovasi bo'yicha murojaatim bor.\n"
        "Platforma: ${Platform.isAndroid ? 'Android' : 'iOS'}\n"
        "Versiya: 1.0.0"; // Keyinchalik package_info_plus orqali avtomat qilsa bo'ladi

    // Telegram link formati
    final String url = "https://t.me/$telegramUsername?text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Telegramni ochib bo\'lmadi: $url';
    }
  }
}