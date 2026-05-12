import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiraTheme.warmBeige,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Text(
              'Mira',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: MiraTheme.miraRed,
                    fontSize: 64,
                    letterSpacing: -2,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'LEARN',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.w700,
                    color: MiraTheme.charcoal.withOpacity(0.5),
                  ),
            ),
            const Spacer(flex: 2),
            const CircularProgressIndicator(
              color: MiraTheme.miraRed,
              strokeWidth: 2,
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
