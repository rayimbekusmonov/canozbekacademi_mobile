import 'package:canozbekacademi/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'providers/dictionary_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase-ni ishga tushirish
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Provayderni yaratish va ma'lumotlarni yuklash
  final dictionaryProvider = DictionaryProvider();
  await dictionaryProvider.init(); // JSON-larni yuklash va boshqa sozlamalar
  await dictionaryProvider.checkAndUpdateStreak(); // 🔥 Olovni yoqish aynan shu yerda
  await NotificationService.init();
  await NotificationService.scheduleDailyNotification();

  runApp(
    MultiProvider(
      providers: [
        // Yaratilgan tayyor obyektni MultiProvider-ga beramiz
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

      // YORUG'LIK REJIMIDAGI DIZAYN
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        cardColor: Colors.white,
      ),

      // TUNGI REJIM (DARK MODE)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E), // Tungi rejimda kartochkalar rangi
      ),

      themeMode: ThemeMode.system, // Telefon sozlamasiga qarab o'zi almashadi
      home: const SplashScreen(),
    );
  }
}