import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

// Sening fayllaring (Yo'llarni (path) o'zingniki bilan tekshirib ol)
import 'providers/dictionary_provider.dart';
import 'ui/screens/splash_screen.dart'; // Splash orqali kiramiz
// import 'services/notification_service.dart';

void main() async {
  // 1. Flutter engine bilan bog'lanishni ta'minlash
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase-ni ishga tushirish (agar firebase bo'lsa)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase muvaffaqiyatli ulandi!");
  } catch (e) {
    print("Firebase ulanishda xato: $e");
  }

  // 3. Bildirishnoma xizmatini sozlash
  // Bu yerda biz ham init qilamiz, ham ruxsat so'raymiz
  await NotificationService.init();

  // Kunlik eslatmani rejalashtirish
  await NotificationService.scheduleDailyNotification();

  // 4. DictionaryProvider obyektini yaratish va ma'lumotlarni yuklash
  final dictionaryProvider = DictionaryProvider();
  await dictionaryProvider.init(); // JSON ma'lumotlarni yuklash
  await dictionaryProvider.checkAndUpdateStreak(); // Olovni (streak) tekshirish

  runApp(
    MultiProvider(
      providers: [
        // Tayyor dictionaryProvider obyektini butun ilovaga tarqatamiz
        ChangeNotifierProvider.value(value: dictionaryProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canozbek Academy',

      // YORUG' REJIM
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // TUNGI REJIM (DARK MODE)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
        ),
      ),

      // Telefon sozlamasiga qarab rejimni tanlash
      themeMode: ThemeMode.system,

      // Ilova SplashScreen bilan boshlanadi (Developed by Rayimbek deb chiqadi)
      home: const SplashScreen(),
    );
  }
}