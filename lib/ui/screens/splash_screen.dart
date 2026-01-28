import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dictionary_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToHome();
    });
  }

  Future<void> _navigateToHome() async {
    // DictionaryProvider-dagi init() metodini chaqiramiz
    // Bu metod lug'at, favoritlar va sozlamalarni yuklaydi
    await Provider.of<DictionaryProvider>(context, listen: false).init();

    if (!mounted) return;

    // Yuklash tugagach, HomeScreen-ga o'tamiz
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o'rnida animatsiyali belgi
            const Hero(
              tag: 'logo',
              child: Icon(Icons.menu_book_rounded, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Canozbek Academy",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 50),
            // Yuklanish indikatori
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              "Ma'lumotlar yuklanmoqda...",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}