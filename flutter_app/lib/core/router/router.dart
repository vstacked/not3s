import 'package:flutter/material.dart';
import 'package:not3s/features/auth/presentation/pages/auth_page.dart';
import 'package:not3s/features/notes/presentation/pages/notes_page.dart';
import 'package:not3s/features/splash/presentation/pages/splash_page.dart';
import 'package:not3s/features/welcome/presentation/pages/welcome_page.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String notes = '/notes';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case AppRoutes.auth:
        return MaterialPageRoute(
          builder: (_) => AuthPage(initialMode: settings.arguments as String?),
        );

      case AppRoutes.notes:
        return MaterialPageRoute(builder: (_) => const NotesPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
