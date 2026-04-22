import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not3s/core/router/router.dart';
import 'package:not3s/core/styles/app_colors.dart';
import 'package:not3s/core/widgets/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Expanded(child: _HeroSection()),
              _ActionButtons(
                onGetStarted: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.auth,
                    arguments: 'register'),
                onLogin: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.auth),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _AppIcon(),
        const SizedBox(height: 20),
        Text(
          'not3s',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'your thoughts, captured',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.edit_note_rounded,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Get Started',
          onPressed: onGetStarted,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Login',
          onPressed: onLogin,
          variant: AppButtonVariant.outlined,
        ),
      ],
    );
  }
}
