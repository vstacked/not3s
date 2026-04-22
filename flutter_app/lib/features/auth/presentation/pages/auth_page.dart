import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not3s/core/styles/app_colors.dart';
import 'package:not3s/core/utils/injections.dart';
import 'package:not3s/core/widgets/app_button.dart';
import 'package:not3s/core/widgets/app_text_field.dart';
import 'package:not3s/features/auth/presentation/bloc/auth_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, this.initialMode});

  final String? initialMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<AuthBloc>();
        if (initialMode?.toLowerCase() == 'register') {
          bloc.add(const AuthModeChanged(mode: AuthMode.register));
        }
        return bloc;
      },
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _changeMode(AuthMode mode) {
    context.read<AuthBloc>().add(AuthModeChanged(mode: mode));
    _usernameController.clear();
    _passwordController.clear();
    FocusScope.of(context).unfocus();
  }

  void _submit(AuthMode mode) {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    if (mode == AuthMode.login) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(username: username, password: password),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(username: username, password: password),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              if (state.mode == AuthMode.register) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account created! Please log in.'),
                  ),
                );
                _changeMode(AuthMode.login);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/notes', (_) => false);
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorMessage = state is AuthFailure ? state.message : null;

            return SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    _AppLogo(mode: state.mode),
                    const SizedBox(height: 40),
                    _UsernameField(
                      controller: _usernameController,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      onSubmitted: (_) => _submit(state.mode),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: errorMessage),
                    ],
                    const SizedBox(height: 28),
                    AppButton(
                      label:
                          state.mode == AuthMode.login ? 'Login' : 'Register',
                      onPressed: () => _submit(state.mode),
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 24),
                    _ModeToggleLink(
                      mode: state.mode,
                      onTap: isLoading
                          ? null
                          : () => _changeMode(
                                state.mode == AuthMode.login
                                    ? AuthMode.register
                                    : AuthMode.login,
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'not3s',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        ),
        Text(
          mode == AuthMode.login
              ? 'your thoughts, captured'
              : 'create your account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: 'Username',
      enabled: enabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      prefixIcon:
          const Icon(Icons.person_outline, size: 20, color: AppColors.textHint),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hintText: 'Password',
      obscureText: _obscurePassword,
      enabled: widget.enabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: widget.onSubmitted,
      prefixIcon:
          const Icon(Icons.lock_outline, size: 20, color: AppColors.textHint),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: AppColors.textHint,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleLink extends StatelessWidget {
  const _ModeToggleLink({required this.mode, required this.onTap});

  final AuthMode mode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == AuthMode.login;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : 'Already have an account? ',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isLogin ? 'Register' : 'Login',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
