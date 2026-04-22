import 'package:flutter/material.dart';
import 'package:not3s/features/auth/presentation/pages/auth_page.dart';

abstract class AppRoutes {
  static const String auth = '/auth';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());

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
