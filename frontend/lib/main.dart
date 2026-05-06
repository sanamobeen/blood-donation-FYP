import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'splash_screen.dart';
import 'menu_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

void main() {
  runApp(const BloodDonationApp());
}

class BloodDonationApp extends StatelessWidget {
  const BloodDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) {
        return MaterialApp(
          title: 'Blood Donor',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red.shade900,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red.shade900,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: mode,
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            // Handle deep linking for password reset
            // Supports: blooddonation://reset-password?email=xxx&token=xxx
            if (settings.name?.contains('reset-password') == true) {
              // Extract query parameters from settings.name
              final uri = Uri.parse(settings.name!);
              final email = uri.queryParameters['email'] ?? '';
              final token = uri.queryParameters['token'];

              if (email.isNotEmpty && token != null) {
                return MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(
                    email: email,
                    token: token,
                  ),
                );
              }
            }

            // Default routes
            return MaterialPageRoute(
              builder: (context) {
                switch (settings.name) {
                  case '/menu':
                    return const MenuPage();
                  case '/login':
                    return const LoginPage();
                  case '/register':
                    return const RegisterPage();
                  default:
                    return const SplashScreen();
                }
              },
            );
          },
          routes: {
            '/menu': (context) => const MenuPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
          },
        );
      },
    );
  }
}
