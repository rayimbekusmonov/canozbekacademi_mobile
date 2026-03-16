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
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // print("Firebase ulanishda xato: $e");
  }

  // Notification — crash bo'lmasin
  try {
    await NotificationService.init();
    await NotificationService.scheduleDailyNotification();
  } catch (e) {
    // print("Notification xatosi: $e");
  }

  final dictionaryProvider = DictionaryProvider();
  await dictionaryProvider.init();
  await dictionaryProvider.checkAndUpdateStreak();

  runApp(
    MultiProvider(
      providers: [
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