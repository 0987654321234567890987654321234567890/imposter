import 'package:flutter/material.dart';
import 'player_setup_screen.dart';

const Color bgCharcoal = Color(0xFF1A1A1E);
const Color surfaceWhite = Color(0xFFF4EFE3);
const Color accentRed = Color(0xFFC4392B);
const Color accentGreen = Color(0xFF2C6E5C);
const Color mutedGrey = Color(0xFF8A8578);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imposter Game',
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        scaffoldBackgroundColor: bgCharcoal,
        colorScheme: ColorScheme.dark(
          primary: accentRed,
          secondary: accentGreen,
          surface: surfaceWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: bgCharcoal,
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: accentRed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search, size: 90, color: mutedGrey),
            const Text(
              'IMPOSTER',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Who\'s lying?',
              style: TextStyle(fontSize: 22, color: Colors.white70),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 260,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    _buildRoute(const PlayerSetupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('PLAY'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _buildRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
