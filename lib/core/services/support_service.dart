import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SupportService {
  static const String telegramUsername = 'rayimbekusmonov';

  static Future<bool> connectToSupport() async {
    try {
      String message = "Assalomu alaykum, Canozbek Academy ilovasi bo'yicha murojaatim bor.\n"
          "Platforma: ${Platform.isAndroid ? 'Android' : 'iOS'}\n"
          "Versiya: 1.0.0";

      final String url = "https://t.me/$telegramUsername?text=${Uri.encodeComponent(message)}";
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print("Telegram ochishda xato: $e");
      return false;
    }
  }
}