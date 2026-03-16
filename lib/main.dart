import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'providers/dictionary_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase + Crashlytics
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Barcha Flutter xatolarini Crashlytics ga yuborish
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    // Firebase ulanmasa ham ilova ishlayveradi
  }

  // 2. Notification
  try {
    await NotificationService.init();
    await NotificationService.scheduleDailyNotification();
  } catch (e) {
    // Notification xatosi ilovani buzmasin
  }

  // 3. Ma'lumotlarni yuklash
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

      home: const SplashScreen(),
    );
  }
}