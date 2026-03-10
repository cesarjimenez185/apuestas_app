import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        } else if (!authProvider.isLoading) {
          return const LoginScreen();
        }
        
        return const Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Color(0xFF22C55E),
                ),
                SizedBox(height: 24),
                Text(
                  'BetFoot',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22C55E),
                  ),
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  color: Color(0xFF22C55E),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
