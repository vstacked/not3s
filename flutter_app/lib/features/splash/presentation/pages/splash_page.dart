import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not3s/core/router/router.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/core/styles/app_colors.dart';
import 'package:not3s/core/utils/injections.dart';
import 'package:not3s/core/utils/jwt_utils.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    _resolveInitialRoute();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resolveInitialRoute() async {
    // Minimum display time so the logo isn't a flash
    await Future.wait([
      sl<StorageService>().getToken().then(_navigate),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);
  }

  void _navigate(String? token) {
    if (!mounted) return;

    final destination =
        isTokenValid(token) ? AppRoutes.notes : AppRoutes.welcome;

    // Replace the entire back-stack so back-button never returns to splash
    Navigator.of(context).pushNamedAndRemoveUntil(
      destination,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: const Center(
          child: _SplashContent(),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'not3s',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
