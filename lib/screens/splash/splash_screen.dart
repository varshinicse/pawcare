import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../auth/login_screen.dart';
import '../ecosystem_tabs_hub.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Check existing session after splash animation
    _navigationTimer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final hasSession = await authProvider.checkSession();

      if (!mounted) return;
      if (hasSession) {
        Provider.of<PetProvider>(context, listen: false).loadPets();
        Provider.of<EcosystemProvider>(context, listen: false).loadEcosystemData();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const EcosystemTabsHub(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.clayPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.clayPrimary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Text(
                    'PawCare',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 36,
                      color: AppColors.inkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your AI-Based Pet Care Companion',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.softTaupe,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
